fd = FreezingDetector();
fd.getGyFromFile('freezing1.txt');
fd.filter();
fd.findPeriods();
fd.findPeriodLength();
fd.findAmplitudes();
fd.detectFreezing();
fd.plotFreezing();