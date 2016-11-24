classdef GetFeatures
    properties
        frequency;
        data;
        file;
    end
    
    methods
        function gf = GetFeatures(file)
            gf.frequency = 33;
            gf.data = {};
            gf.fileName = file;
        end

        function result = dataParse(gf)
            M = csvread(filename);

            Ax = M(:, 1);
            Ay = M(:, 2);
            Az = M(:, 3);
            Gx = M(:, 4);
            Gy = M(:, 5);
            Gz = M(:, 6);
        end

        function result = getAccelerations(gf)
            result = zeros(size(gf.data));
            result(3:end-2,:) = (gf.data(1:end-4,:) - 2*gf.data(3:end-2,:) + gf.data(5:end,:)) / (2/gf.frequency)^2;
                
            % extrapolate samples at beginning and end
            result(1:2,:) = repmat(result(3,:), 2, 1);
            result(end-1:end,:) = repmat(result(end-2,:), 2, 1);
        end
        
        function result = getPitchAngle(gf)         
            m2 = gf.data(:,4:6); % marker 2 position
            m3 = gf.data(:,7:9); 
            dm = m3-m2;
            hor = sum(dm(:,1:2).^2,2).^.5;
            ver = dm(:,3);
            result = atan(ver ./ hor);
        end

        function plotAcceleration(gf)
            acceleration = gf.getAccelerations();
            time = (1:size(acceleration,1)) / gf.frequency;
            plot(time, acceleration(:,1:3)) %marker 1 (ankle)
            xlabel('Time (s)')
            ylabel('Ankle acceleration (m/ss)')
            legend('AP', 'ML', 'Vert')
        end
        
        function plotPitchAngle(gf)
            pitchAngle = gf.getPitchAngle();
            time = (1:length(pitchAngle)) / gf.frequency;
            plot(time, pitchAngle)
            xlabel('Time (s)')
            ylabel('Pitch angle (rad)')
        end

        function plotTrial(gf)            
            figure            

            gf.data = dataParse(gf.fileName);

            subplot(2,1,1)
            gf.plotAcceleration()

            subplot(2,1,2)
            gf.plotPitchAngle()
        end
    end
end
