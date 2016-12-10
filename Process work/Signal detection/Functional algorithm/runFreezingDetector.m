fd = FreezingDetector();
fd.getGyFromFile('freezing1.txt');

% construct Arduino object, serial communication on Port COM18
arduino=serial('COM3','BaudRate',9600);
% initiate communication
fopen(arduino);

% five times before you start detecting freezing
for i = 1:5
    % setting current Gy to number currently in serial monitor
    fd.append(fscanf(arduino,'%f'));
end

while (true) % settle on a condition for this
    % setting current Gy to number currently in serial monitor
    fd.append(fscanf(arduino,'%f'));
    fd.filter();
    fd.findPeriods();
    fd.findPeriodLength();
    fd.findAmplitudes();
    fd.detectFreezing();
end

% end communication with Arduino
fclose(arduino);