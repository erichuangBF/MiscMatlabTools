% This function returns 3D matrix of calculated loss for every result struct
function loss = mpcPredictionLoss(sampleIntervalDays, resultsMatrix)
% ehuang 
% ARGUMENTS
%   sampleIntervalDays: number of days to use as sample interval
%   resultsMatrix: matrix of vClinic result structs loaded by 
%     'loadVClinicResultsStructFromFile()' - see example
% 
% EXAMPLE
%  %%% specify files, names
%     files = ["../SimResults/191011_30DayForget/results_raw.mat" ...
%              "../SimResults/191011_NoForget/results.mat"];
% 
%     optionNames = ["Forget30Day", "ForgetNever"];
% 
%  %%% create struct of result structs
%     eval(strcat("resultsMatrix = struct('", strjoin(optionNames,...
%         "',{'placeholder'},'"), "',{'placeholder'});"));
% 
%  %%% load from mat files
%     for option = 1:length(files)
%         eval(strcat('resultsMatrix.', optionNames(option), ...
%             ' = loadVClinicResultsStructFromFile(files(', num2str(option),...
%             "), 'results');"));
%     end
%  %%% calculate loss
%     lossMatrix = mpcPredictionLoss(7, resultsMatrix);
%
%%


    % NEED TO IMPLEMENT CHECKS
        % subject counts are same
        % time durations are same
        % sampleIntervalDays is greater than or equal to 1
    
    HOURS_IN_DAY = 24;
    MINUTES_IN_HOUR = 60;
    ORIGINAL_INTERVAL_MINUTES = 5;
    
    % get array of result names
    resultNames = fieldnames(resultsMatrix);    
    % get number of result structs
    numResultStructs = length(resultNames);
    % get number of subjects
    eval(strcat("numSubjects = length(resultsMatrix.",resultNames(1),".results);"));
    % get number of time/index values within old time interval to collapse
    numberOfValuesWithinNewInterval = (MINUTES_IN_HOUR*HOURS_IN_DAY*sampleIntervalDays)/ORIGINAL_INTERVAL_MINUTES;
    % get number of egv values
    eval(strcat("egvValueCount = length(resultsMatrix.",resultNames(1),".results(1).cgm.egvsMgDl.data);"));
    % get the number of time index/values in TS data table AFTER resampling
    numTimeIndicies = floor(egvValueCount/numberOfValuesWithinNewInterval); 
    
    % create 3D return matrix to hold loss matricies
    loss = zeros(numResultStructs, numTimeIndicies, numSubjects);

    for option = 1:numResultStructs
        % create matrix of loss for all subjects for this option
        tempLossMatrix = zeros(numTimeIndicies, numSubjects);
        % get result for this option
        eval(strcat("thisResult = resultsMatrix.", resultNames(option), ".results;"));
        
        for subject = 1:numSubjects
            % get original EG values
            originalEGVS = thisResult(subject).cgm.egvsMgDl.data;
            % resample EG values to bigger time increment
            % by getting average of all values within every new interval
            scaledEGVS = arrayfun(@(i) nanmean(originalEGVS(i:i+numberOfValuesWithinNewInterval-1)),...
                1:numberOfValuesWithinNewInterval:length(originalEGVS)-numberOfValuesWithinNewInterval+1)';
            % calculate loss for every time index
            for timeIndex = 1:numTimeIndicies
                egvs = scaledEGVS(timeIndex);
                targetBG = thisResult(subject).controller.targetBloodGlucoseMgDl;
                tempLossMatrix(timeIndex, subject) = log(egvs./targetBG).^2;
            end
        end
        loss(option, :,:) = tempLossMatrix;
    end
end 