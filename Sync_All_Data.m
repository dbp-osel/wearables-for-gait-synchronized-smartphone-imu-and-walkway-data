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

IMU_FRAME_RATE = 100;
Walkway_FRAME_RATE = 100;
NUM_SUBJECTS = 20;
NUM_SENSOR_LOCATIONS = 2; 
NUM_PHONES = 2;

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
                fileNameIMU = fileNameIMU(3).name;
                fileID = fopen(fileNameIMU,'r');
                formatSpec = '%f%s%s%s%s%s%s%s%s%s%s%s%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%f%s%s%s%[^\n\r]';
                delimiter = ',';
                dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue', NaN,'HeaderLines', 5, 'ReturnOnError', false);
                fclose(fileID);
                PacketCounter = dataArray{:, 1};
                Acc_Y = dataArray{:, 15};
                Acc_X = dataArray{:, 16}*-1;
                Acc_Z = dataArray{:, 17};
                Gyro_Y = dataArray{:, 21};
                Gyro_X = dataArray{:, 22}*-1;
                Gyro_Z = dataArray{:, 23};

                fileNamePhoneAcc = [dataFolderNamePhone '/AccelerometerUncalibrated.csv'];
                PhoneAcc = readtable(fileNamePhoneAcc);
                
                if strcmp('iPhone10',phoneName)
                    PhoneAcc{:,3:end} = PhoneAcc{:,3:end}.*-9.80665;
                end
                
                fileNamePhoneGyro = [dataFolderNamePhone '/Gyroscope.csv'];
                PhoneGyro = readtable(fileNamePhoneGyro);
                PhoneGyro.Properties.VariableNames = {'t','sec_elapsed','z_gyro','y_gyro','x_gyro'};
                PhoneGyro.sec_elapsed = PhoneGyro.sec_elapsed - PhoneGyro.sec_elapsed(1);
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
                opts.VariableNamesLine = 10; 
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
                
                [IMUPeak, IMUPeakLocation]= max(magIMU);
                
                KeyIMU = horzcat(IMUTimeStamps, Acc_X, Acc_Y, Acc_Z, Gyro_X, Gyro_Y, Gyro_Z);
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
                SyncedPhoneAcc = SyncedPhoneAcc(2:end,:);
                SyncedPhoneAcc.seconds_elapsed = SyncedPhoneAcc.seconds_elapsed - SyncedPhoneAcc.seconds_elapsed(1);
                
                SyncedPhoneGyro = PhoneGyro(PhonePeakLocation:end,:);
                SyncedLimPhoneGyro = LimPhoneGyro(PhonePeakLocation:end,:);

                %resample smartphone data
                samprt_phone = mean(diff(SyncedPhoneAcc.seconds_elapsed));
                [p,q] = rat((samprt_phone*10000)/100);
                resampled_SyncedPhoneAcc_z = resample(SyncedPhoneAcc.z,p,q);
                resampled_SyncedPhoneAcc_y = resample(SyncedPhoneAcc.y,p,q);
                resampled_SyncedPhoneAcc_x = resample(SyncedPhoneAcc.x,p,q);
                resampled_SyncedPhoneAcc_seconds = (0:0.01:(numel(resampled_SyncedPhoneAcc_z)/100)).';
                rs_SyncedPhoneAcc = horzcat(resampled_SyncedPhoneAcc_seconds(1:end-1),resampled_SyncedPhoneAcc_z,resampled_SyncedPhoneAcc_y, resampled_SyncedPhoneAcc_x);
                rs_SyncedPhoneAcc = array2table(rs_SyncedPhoneAcc);

                resampled_SyncedLimPhoneGyro_z = resample(SyncedLimPhoneGyro.z_gyro,p,q);
                resampled_SyncedLimPhoneGyro_y = resample(SyncedLimPhoneGyro.y_gyro,p,q);
                resampled_SyncedLimPhoneGyro_x = resample(SyncedLimPhoneGyro.x_gyro,p,q);
                rs_SyncedLimPhoneGyro = horzcat(resampled_SyncedLimPhoneGyro_z,resampled_SyncedLimPhoneGyro_y, resampled_SyncedLimPhoneGyro_x);
                rs_SyncedLimPhoneGyro = array2table(rs_SyncedLimPhoneGyro);

                WalkwayTimeStamps = WalkwayData.Time_sec__;
                WalkwayLeftFootContact = WalkwayData.LeftFootContact;
                WalkwayRightFootContact = WalkwayData.RightFootContact;
                WalkwayTimeStamps = WalkwayTimeStamps(IMUPeakLocation:end);
                WalkwayTimeStamps = WalkwayTimeStamps - WalkwayTimeStamps(1);
                WalkwayLeftFootContact = WalkwayLeftFootContact(IMUPeakLocation:end);
                WalkwayRightFootContact = WalkwayRightFootContact(IMUPeakLocation:end);
                WalkwayLeftFootContact(isnan(WalkwayLeftFootContact))=0;
                WalkwayRightFootContact(isnan(WalkwayRightFootContact))=0;
                
                SyncedWalkway = horzcat(WalkwayTimeStamps, WalkwayLeftFootContact, WalkwayRightFootContact);
                SyncedWalkway = array2table(SyncedWalkway);

                %ensure trials end simultaneously 
                testhtW = height(SyncedWalkway);
                testhtPA = height(rs_SyncedPhoneAcc);
                testhtI = height(rs_SyncedLimPhoneGyro);
                compare = horzcat(testhtW,testhtPA,testhtI);
                minim = min(compare);
                rs_SyncedPhoneAcc=rs_SyncedPhoneAcc(1:minim,:);
                rs_SyncedLimPhoneGyro = rs_SyncedLimPhoneGyro(1:minim,:);
                SyncedWalkway=SyncedWalkway(1:minim,:);
                SyncedIMU=SyncedIMU(1:minim,:);
                
                newfileNamePhoneAcc = [dataFolderNamePhone '/Synced_Accelerometer.csv'];

                newfileNamePhoneGyro = [dataFolderNamePhone '/Synced_Gyroscope.csv'];
                
                newfileNameWalkway = [dataFolderNameWalkway '/Synced_Walkway.csv'];
                
                newfileNameIMU = [dataFolderNameIMU '/Synced_IMU.csv'];
                
                SyncedIMU = array2table(SyncedIMU);
                
                if strcmp('iPhone10',phoneName)
                    tempdataIOSPre = horzcat(rs_SyncedPhoneAcc,rs_SyncedLimPhoneGyro,SyncedIMU(:,2:end),SyncedWalkway(:,2:end));
                    tempdataIOS = tempdataIOSPre(:,1:end);

                end
                
                if strcmp('SamsungGalaxyS22',phoneName)
                    SyncedIMU.Properties.VariableNames = {'TimeStamp','AS_Acc_X', 'AS_Acc_Y', 'AS_Acc_Z', 'AS_Gyro_X', 'AS_Gyro_Y', 'AS_Gyro_Z'};
                    tempdataAndPre = horzcat(rs_SyncedPhoneAcc,rs_SyncedLimPhoneGyro,SyncedIMU(:,2:end),SyncedWalkway(:,2:end));
                    tempdataAnd = tempdataAndPre(:,2:end);
                    
                    [fli, flvi] = find(tempdataIOS.SyncedWalkway2+tempdataIOS.SyncedWalkway3==2);
                    if isempty(fli)
                        fli=161;
                    end
                    if fli(1) < 161
                        fli=161;
                    end
                    startfli = fli(1)-160;
                    tempdataIOS = tempdataIOS(startfli:end,:);

                    [fla, flva] = find(tempdataAnd.SyncedWalkway2+tempdataAnd.SyncedWalkway3==2);
                    if isempty(fla)
                        fla=161;
                    end
                    if fla(1) < 161
                        fla=161;
                    end
                    startfla = fla(1)-160;
                    tempdataAnd = tempdataAnd(startfla:end,:);

                    testhtIOS = height(tempdataIOS);
                    testhtAND = height(tempdataAnd);
                    compare2 = horzcat(testhtIOS,testhtAND);
                    minim2 = min(compare2);
                    tempdataIOS=tempdataIOS(1:minim2,:);
                    tempdataAnd=tempdataAnd(1:minim2,:);
                    
                    tempdataIOS.Properties.VariableNames = {'time','ios_acc_z','ios_acc_y','ios_acc_x', 'ios_gyro_z','ios_gyro_y','ios_gyro_x','iimu_acc_x','iimu_acc_y','iimu_acc_z','iimu_gyro_x','iimu_gyro_y','iimu_gyro_z', 'ILeftSWW', 'IRightSWW'};
                    tempdataAnd.Properties.VariableNames = {'and_acc_z','and_acc_y','and_acc_x', 'and_gyro_z','and_gyro_y','and_gyro_x','aimu_acc_x','aimu_acc_y','aimu_acc_z','aimu_gyro_x','aimu_gyro_y','aimu_gyro_z', 'leftfootcontact', 'rightfootcontact'};
                    
                    frames = array2table([1:minim2].');
                    frames.Properties.VariableNames = {'frame'};
                    
                    tempdatacombo = horzcat(frames,tempdataIOS(:,2:end-2),tempdataAnd);

                    contactcombo = tempdatacombo.leftfootcontact+tempdatacombo.rightfootcontact;
                    contactcombo(contactcombo<=1.99) = 0;
                    contactcombo(contactcombo>1.99) = 1;
                    [J,K] = find(contactcombo>0.99);
                    if isempty(K)
                        first = 1;
                    else
                        first = J(1);
                    end
                    if first<1
                        first = 1;
                    end

                    leftsteps = diff(tempdatacombo.leftfootcontact);
                    rightsteps = diff(tempdatacombo.rightfootcontact);
                    holdleft = find(leftsteps==1);
                    holdright = find(rightsteps==1);
                    ts = length(holdleft) + length(holdright);
                    avgsteps = round(ts./8);

                    yval1 = tempdatacombo(first:end,8);
                    yval2 = tempdatacombo(first:end,20);
                    xval1 = tempdatacombo(first:end,9);
                    xval2 = tempdatacombo(first:end,21);
                    zval1 = tempdatacombo(first:end,10);
                    zval2 = tempdatacombo(first:end,22);
                    
                    yval1 = table2array(yval1);
                    xval1 = table2array(xval1);
                    zval1 = table2array(zval1);

                    yval2 = table2array(yval2);
                    xval2 = table2array(xval2);
                    zval2 = table2array(zval2);

                    yval = (yval1+yval2)./2;
                    xval = (xval1+xval2)./2;
                    zval = (zval1+zval2)./2;

                    x = sqrt(xval.^2 +yval.^2 +zval.^2);
                    x = abs(x);
                    x = x-9.81;
                    xdata = x;
                    x(x<1.5) = 1; 
                    x(x>=1.5) = 0;
                    x = diff(x);
                    holder = find(x==1);
                    [M,I] = find(x==1);
                    delta = diff(M); 
                    [M,I] = max(delta);
                    splitpt = first+holder(I)+round(M./3);

                    split1 = tempdatacombo(1:splitpt,:);
                    split2 = tempdatacombo(splitpt+1:end,:);

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
