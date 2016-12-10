classdef FreezingDetector < handle
    properties
        Gy;
        Gyave;
        amplitudes;
        periods;
        indicesOfSigPeriods;
    end
    methods
        % constructor
        function fd = FreezingDetector(fd)
            fd.Gy = [];
            fd.Gyave = [];
            fd.amplitudes = [];
            fd.periods = [];
            fd.indicesOfSigPeriods = [];
        end
        
        function append(fd,currentGy)
            fd.Gy(end + 1) = currentGy;
            if length(Gy) > 5/0.03
                fd.Gy = fd.Gy([2:end]);
            end
        end
        
        function getGyFromFile(fd,file)
            M = csvread(file);
            fd.Gy = M(:, 5);
        end
        
        function filter(fd)
            fd.Gyave = zeros(size(fd.Gy / 131.0));
            fd.Gyave(1) = fd.Gy(1) / 131.0;
            fd.Gyave(2) = fd.Gy(2) / 131.0;
            for index = 3:size(fd.Gy)
                fd.Gyave(index) = (fd.Gy(index-2) / 131.0+fd.Gy(index-1) / 131.0)/2;
            end

            for index = 1:size(fd.Gyave)
                fd.Gyave(index) = fd.Gyave(index) - fd.Gyave(1);
            end

            for index = 2:size(fd.Gyave)
                if abs(fd.Gyave(index-1) - fd.Gyave(index)) < 20
                    fd.Gyave(index) = fd.Gyave(index - 1);
                end
            end
        end
        
        function findPeriods(fd)
            zerosIndices = [];
            zerosIndices(1) = 1;
            for index = 2:size(fd.Gyave)
                if fd.Gyave(index) == 0
                    zerosIndices(end+1) = index;
                elseif fd.Gyave(index) * fd.Gyave(index-1) < 0
                    zerosIndices(end+1) = index;
                end
            end

            fd.indicesOfSigPeriods = [];
            for index = 2:length(zerosIndices)
                if (zerosIndices(index) - zerosIndices (index-1)) > 1 % if a period exists save the two indexs the border the period
                    fd.indicesOfSigPeriods(end+1) = zerosIndices(index-1);
                    fd.indicesOfSigPeriods(end+1) = zerosIndices(index);
                end
            end
        end
        
        function findPeriodLength(fd)
            fd.periods = [];
            for index = 4:4:length(fd.indicesOfSigPeriods)
                fd.periods(end+1) = fd.indicesOfSigPeriods(index) - fd.indicesOfSigPeriods(index-3);
            end
        end
        
        function findAmplitudes(fd)
            maxVals = [];
            absfd.Gyave = abs(fd.Gyave);
            for index = 2:2:length(fd.indicesOfSigPeriods)
                maxIndex = fd.indicesOfSigPeriods(index-1);
                for i = fd.indicesOfSigPeriods(index-1):fd.indicesOfSigPeriods(index)
                    if absfd.Gyave(i) > absfd.Gyave (maxIndex)
                        maxIndex = i;
                    end
                end
                maxVals(end+1) = absfd.Gyave(maxIndex);
            end

            fd.amplitudes = [];
            for index = 2:2:length(maxVals)
                fd.amplitudes(end+1) = maxVals(index) + maxVals(index-1);
            end
        end
        
        function detectFreezing(fd)
            count = 0;
            for index = 1:length(fd.amplitudes)
                if fd.amplitudes(index) < 100 && fd.periods(index) < 20
                    count = count + 1;
                end
                if count > 3
                    disp('freezing')
                    count = 0;
                end
            end
        end
        
        function plotFreezing(fd)
            time = 1:size(fd.Gy);
            time = time.*0.03;
            figure
            plot(time, fd.Gyave),xlabel('Time (s)'), ylabel('Gy Filtered');
        end 
    end
end