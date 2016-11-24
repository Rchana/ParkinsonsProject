filename = 'walking5.txt';
M = csvread(filename);
Ax = M(:, 1);
Ay = M(:, 2);
Az = M(:, 3);
Gx = M(:, 4);
Gy = M(:, 5);
Gz = M(:, 6);
time = 1:size(Ax);
time.*0.03;
pitchAngle = zeros(size(Ax));
aGx = Gx / 131.0;
aGy = Gy / 131.0;
aGz = Gz / 131.0;

Gyave = zeros(size(aGy));
Gyave(1) = aGy(1);
Gyave(2) = aGy(2);
for index = 3:size(Gy)
    Gyave(index) = (aGy(index-2)+aGy(index-1))/2;
end

for index = 1:size(Gyave)
    Gyave(index) = Gyave(index) - Gyave(1);
end

for index = 2:size(Gyave)
    if abs(Gyave(index-1) - Gyave(index)) < 20
        Gyave(index) = Gyave(index - 1);
    end
end

zerosIndices = [];
zerosIndices(1) = 1;
for index = 2:size(Gyave)
    if Gyave(index) == 0
        zerosIndices(end+1) = index;
    elseif Gyave(index) * Gyave(index-1) < 0
        zerosIndices(end+1) = index;
    end
end

indicesOfSigPeriods = [];
for index = 2:length(zerosIndices)
    if (zerosIndices(index) - zerosIndices (index-1)) > 1 % if a period exists save the two indexs the border the period
        indicesOfSigPeriods(end+1) = zerosIndices(index-1);
        indicesOfSigPeriods(end+1) = zerosIndices(index);
    end
end

periods = [];
for index = 4:4:length(indicesOfSigPeriods)
    periods(end+1) = indicesOfSigPeriods(index) - indicesOfSigPeriods(index-3);
end

maxVals = [];
absGyave = abs(Gyave);
for index = 2:2:length(indicesOfSigPeriods)
    maxIndex = indicesOfSigPeriods(index-1);
    for i = indicesOfSigPeriods(index-1):indicesOfSigPeriods(index)
        if absGyave(i) > absGyave (maxIndex)
            maxIndex = i;
        end
    end
    maxVals(end+1) = absGyave(maxIndex);
end

amplitudes = [];
for index = 2:2:length(maxVals)
    amplitudes(end+1) = maxVals(index) + maxVals(index-1);
end

count = 0;
for index = 1:length(amplitudes)
    if amplitudes(index) < 100 && periods(index) < 20
        count = count + 1;
    end
    if count > 5
        disp('freezing')
        count = 0;
    end
end

figure
plot(time, Gyave),xlabel('Time (s)'), ylabel('Gy Filtered');