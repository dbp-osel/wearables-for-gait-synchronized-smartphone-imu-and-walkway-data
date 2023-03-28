%Sync All Data from Multiple Systems Based on Peak IMU Impulse

%SW Authors: Nyman*, Patwardhan, Kontson, & Watkinson  *corresponding author: edward.nyman[at]fda.hhs.gov 

%CC0 1.0 (https://creativecommons.org/publicdomain/zero/1.0/)

%This software and documentation (the "Software") were developed at the Food and Drug Administration (FDA) by employees of the Federal Government in the course of their official duties. Pursuant to Title 17, Section 105 of the United States Code, this work is not subject to copyright protection and is in the public domain. Permission is hereby granted, free of charge, to any person obtaining a copy of the Software, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, or sell copies of the Software or derivatives, and to permit persons to whom the Software is furnished to do so. FDA assumes no responsibility whatsoever for use by other parties of the Software, its source code, documentation or compiled executables, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. 
%Further, use of this code in no way implies endorsement by the FDA or confers any advantage in regulatory decisions. Although this software can be redistributed and/or modified freely, we ask that any derivative works bear some notice that they are derived from it, and any modified versions bear some notice that they have been modified. 

addpath(genpath('DATA')) %Raw Data Files
addpath(genpath('Synced Data')) %Export Location for Synced Data

IMU_FRAME_RATE = 100;
Walkway_FRAME_RATE = 100;
NUM_SUBJECTS =  20;
NUM_SENSOR_LOCATIONS = 2; 
NUM_PHONES = 2;

tic

for subjectNumber = 1:NUM_SUBJECTS

    for sensorLocation = 1:NUM_SENSOR_LOCATIONS

        switch sensorLocation
            case 1
                sensorLocationFolderName = 'iOSback_ANDROIDthigh';
            case 2
                sensorLocationFolderName = 'iOSthigh_ANDROIDback';

        end

        for degrees = 0:45:180
            tempdataIOS = [];
            tempdataAnd = [];

            for phoneNumber = 1:NUM_PHONES

                switch phoneNumber
                    case 1
                        phoneName = 'iPhone10';
                        dataFolderNameIMU = ['DATA/Subject0' ...
                            num2str(subjectNumber) '/' ...
                            sensorLocationFolderName '/Deg_' num2str(degrees) ...
                            '/IMU_iPhone10'];
                        dataFolderNamePhone = ['DATA/Subject0' ...
                            num2str(subjectNumber) '/' ...
                            sensorLocationFolderName '/Deg_' num2str(degrees) ...
                            '/iPhone10'];
                        dataFolderNameWalkway = ['DATA/Subject0' ...
                            num2str(subjectNumber) '/' ...
                            sensorLocationFolderName '/Deg_' num2str(degrees) ...
                            '/Walkway'];
                    case 2
                        phoneName = 'SamsungGalaxyS22';
                        dataFolderNameIMU = ['DATA/Subject0' ...
                            num2str(subjectNumber) '/' ...
                            sensorLocationFolderName '/Deg_' num2str(degrees) ...
                            '/IMU_SamsungGalaxyS22'];
                        dataFolderNamePhone = ['DATA/Subject0' ...
                            num2str(subjectNumber) '/' ...
                            sensorLocationFolderName '/Deg_' num2str(degrees) ...
                            '/SamsungGalaxyS22'];
                        dataFolderNameWalkway = ['DATA/Subject0' ...
                            num2str(subjectNumber) '/' ...
                            sensorLocationFolderName '/Deg_' num2str(degrees) ...
                            '/Walkway'];
                end
                
                fileNameIMU = dir(dataFolderNameIMU);
                fileNameIMU = fileNameIMU(3).name; %fileNameIMU(3).name
                fileID = fopen(fileNameIMU,'r');
                formatSpec = '%f%s%s%s%s%s%s%s%s%s%s%s%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%f%s%s%s%[^\n\r]';
                delimiter = ',';
                dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue', NaN,'HeaderLines', 5, 'ReturnOnError', false);
                fclose(fileID);
                PacketCounter = dataArray{:, 1};
                Acc_X = dataArray{:, 15};
                Acc_Y = dataArray{:, 16};
                Acc_Z = dataArray{:, 17};
                Gyro_X = dataArray{:, 21};
                Gyro_Y = dataArray{:, 22};
                Gyro_Z = dataArray{:, 23};

                fileNamePhoneAcc = [dataFolderNamePhone '/Accelerometer.csv'];
                PhoneAcc = readtable(fileNamePhoneAcc);
                
                fileNamePhoneGyro = [dataFolderNamePhone '/Gyroscope.csv'];
                PhoneGyro = readtable(fileNamePhoneGyro);
                PhoneGyro.Properties.VariableNames = {'t','sec_elapsed','z_gyro','y_gyro','x_gyro'};
                LimPhoneGyro = PhoneGyro(:,3:5);
                
                fileNameWalkway = dir(dataFolderNameWalkway);
                fileNameWalkway = fileNameWalkway(3).name;

                dataLines = [11, Inf];
                
                % Set up Import Options 
                opts = delimitedTextImportOptions("NumVariables", 8, "Encoding", "UTF-8");
                
                % Specify range and delimiter
                opts.DataLines = dataLines;
                opts.Delimiter = ";";
                
                % Specify column names and types
                opts.VariableNames = ["Timesec", "LeftFootPressure", "LeftFootPressure1", "LeftFootContact", "RightFootContact", "LeftFootActiveSensors", "RightFootActiveSensors", "SyncIn"];
                opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double"];
                
                % Specify file level properties
                opts.ExtraColumnsRule = "ignore";
                opts.EmptyLineRule = "read";
                
                % Import the walkway data
                WalkwayData = readtable(fileNameWalkway, opts);

                IMUTimeStamps = (1/IMU_FRAME_RATE)*(1:length(PacketCounter))';
                IMUY = Acc_Y;
                IMUX = Acc_X;
                IMUZ = Acc_Z;
                magIMU = sqrt(IMUY.^2 +IMUX.^2 +IMUZ.^2);
                
                [IMUYPeak, IMUPeakLocation]= max(magIMU);
                
                KeyIMU = horzcat(IMUTimeStamps, Acc_X, Acc_Y, Acc_Z, Gyro_X, Gyro_Y, Gyro_Z); %was PacketCounter instead of IMUTimeStamps
                SyncedIMU = KeyIMU(IMUPeakLocation:end,:);

                PhoneTimeStamps = PhoneAcc.seconds_elapsed;
                PhoneAccY = PhoneAcc.y;
                PhoneAccX = PhoneAcc.x;
                PhoneAccZ = PhoneAcc.z;
                magPhoneAcc = sqrt(PhoneAccY.^2 +PhoneAccX.^2 +PhoneAccZ.^2);
                
                [PhonePeak, PhonePeakLocation] = max(magPhoneAcc);
                PhoneTimeStamps = PhoneTimeStamps(PhonePeakLocation:end);
                PhoneTimeStamps = PhoneTimeStamps - PhoneTimeStamps(1);
                PeakPhone = magPhoneAcc(PhonePeakLocation:end);
                SyncedPhoneAcc = PhoneAcc(PhonePeakLocation:end,:);
                SyncedPhoneAcc.seconds_elapsed = SyncedPhoneAcc.seconds_elapsed - SyncedPhoneAcc.seconds_elapsed(1);
                
                SyncedPhoneGyro = PhoneGyro(PhonePeakLocation:end,:);
                SyncedLimPhoneGyro = LimPhoneGyro(PhonePeakLocation:end,:);
                
                WalkwayTimeStamps = WalkwayData.Timesec;
                WalkwayLeftFootContact = WalkwayData.LeftFootContact;
                WalkwayRightFootContact = WalkwayData.RightFootContact;
                WalkwayTimeStamps = WalkwayTimeStamps(IMUPeakLocation:end);
                %WalkwayTimeStamps = WalkwayTimeStamps - WalkwayTimeStamps(1);
                WalkwayLeftFootContact = WalkwayLeftFootContact(IMUPeakLocation:end);
                WalkwayRightFootContact = WalkwayRightFootContact(IMUPeakLocation:end);
                WalkwayLeftFootContact(isnan(WalkwayLeftFootContact))=0;
                WalkwayRightFootContact(isnan(WalkwayRightFootContact))=0;
                
                SyncedWalkway = horzcat(WalkwayTimeStamps, WalkwayLeftFootContact, WalkwayRightFootContact);
                SyncedWalkway = array2table(SyncedWalkway);

                
                %ensure trials end simultaneously 
                testhtW = height(SyncedWalkway);
                testhtPA = height(SyncedPhoneAcc);
                testhtPG = height(SyncedPhoneGyro);
                testhtI = length(SyncedIMU);
                compare = horzcat(testhtW,testhtPA,testhtPG,testhtI);
                minim = min(compare);
                SyncedPhoneAcc=SyncedPhoneAcc(1:minim,:);
                SyncedPhoneGyro=SyncedPhoneGyro(1:minim,:);
                SyncedWalkway=SyncedWalkway(1:minim,:);
                SyncedIMU=SyncedIMU(1:minim,:);
                SyncedLimPhoneGyro = SyncedLimPhoneGyro(1:minim,:);
                
                newfileNamePhoneAcc = [dataFolderNamePhone '/Synced_Accelerometer.csv'];

                newfileNamePhoneGyro = [dataFolderNamePhone '/Synced_Gyroscope.csv'];
                
                newfileNameWalkway = [dataFolderNameWalkway '/Synced_Walkway.csv'];
                
                newfileNameIMU = [dataFolderNameIMU '/Synced_IMU.csv'];
                
                SyncedIMU = array2table(SyncedIMU);
                
                if strcmp('iPhone10',phoneName)
                    tempdataIOS = horzcat(SyncedPhoneAcc,SyncedLimPhoneGyro,SyncedIMU(:,2:end));
                    tempdataIOS = tempdataIOS(:,2:end);
                end
                
                if strcmp('SamsungGalaxyS22',phoneName)
                    SyncedIMU.Properties.VariableNames = {'TimeStamp','AS_Acc_X', 'AS_Acc_Y', 'AS_Acc_Z', 'AS_Gyro_X', 'AS_Gyro_Y', 'AS_Gyro_Z'};
                    tempdataAnd = horzcat(SyncedPhoneAcc,SyncedLimPhoneGyro,SyncedIMU(:,2:end));
                    tempdataAnd = tempdataAnd(:,3:end);
                
                    testhtIOS = height(tempdataIOS);
                    testhtAND = height(tempdataAnd);
                    compare2 = horzcat(testhtIOS,testhtAND);
                    minim2 = min(compare2);
                    tempdataIOS=tempdataIOS(1:minim2,:);
                    tempdataAnd=tempdataAnd(1:minim2,:);
                    
                    tempdataIOS.Properties.VariableNames = {'sec_elapsed','ios_acc_z','ios_acc_y','ios_acc_x', 'ios_gyro_z','ios_gyro_y','ios_gyro_x','iimu_acc_x','iimu_acc_y','iimu_acc_z','iimu_gyro_x','iimu_gyro_y','iimu_gyro_z'};
                    tempdataAnd.Properties.VariableNames = {'and_acc_z','and_acc_y','and_acc_x', 'and_gyro_z','and_gyro_y','and_gyro_x','aimu_acc_x','aimu_acc_y','aimu_acc_z','aimu_gyro_x','aimu_gyro_y','aimu_gyro_z'};
                    
                    frames = array2table([1:minim2].');
                    frames.Properties.VariableNames = {'frame'};
                    
                    SyncedWalkway=SyncedWalkway(1:minim2,:);
                    SyncedWalkway.Properties.VariableNames = {'TimeStamp','leftfootcontact','rightfootcontact'};
                    
                    tempdatacombo = horzcat(frames,tempdataIOS(:,2:end),tempdataAnd,SyncedWalkway(:,2:end));

                    yval = tempdatacombo(1800:end,8); % imu_y accel data from reference IMU(XSens)
                    xval = tempdatacombo(1800:end,9);
                    zval = tempdatacombo(1800:end,10);
                    yval = table2array(yval);
                    xval = table2array(xval);
                    zval = table2array(zval);
                    x = sqrt(xval.^2 +yval.^2 +zval.^2);
                    xdata = x;
                    x = sqrt(x.*x);
                    x = x-9.81;
                    x = sqrt(x.*x);
                    x(x<1.5) = 1;
                    x(x>=1.5) = 0;
                    xx = diff(x);
        
                    xxabs = abs(xx);
                    holder = find(xxabs==1);
                    [M,I] = find(xxabs==1);
                    delta = diff(M); 
                    [M,I] = max(delta);
                    key = (holder(I))+1800+(round(M./2));
                  
                    split1 = tempdatacombo(1:key,:);
                    split2 = tempdatacombo(key+1:end,:);

                    newcombofilename_walk = ['./Synced Data/' 'S0' num2str(subjectNumber) '_' sensorLocationFolderName '_' num2str(degrees) 'deg_walk.csv'];
                    newcombofilename_obs = ['./Synced Data/' 'S0' num2str(subjectNumber) '_' sensorLocationFolderName '_' num2str(degrees) 'deg_obs.csv'];
                    newcombofilename = ['./Synced Data/' 'S0' num2str(subjectNumber) '_' sensorLocationFolderName '_' num2str(degrees) 'deg.csv'];

                    writetable(split1, newcombofilename_walk);
                    writetable(split2, newcombofilename_obs);
                    writetable(tempdatacombo, newcombofilename);

                end
            end
        end
    end
end
toc
