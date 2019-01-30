% This function creates loss plots (containing n curves) for every subject
function plotLossOfEachSubjectOverTime(lossMatrix, numPlotsPerRow, optionNames, brCrIsf, saveDir)
% ehuang
% ARGUMENTS
%   lossMatrix: a 3D matrix of loss for each result/option, subject, time
%   numPlotsPerRow: number of plots to display in each row
%   optionNames: vector of name strings assocaited with each result group
%   brCrIsf: matrix containing BR, CR, and ISF of each subject
%     * must be consistent for each subject across all result groups
%   saveDir: [optional] specify a save directory for generated plot
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
%
%  %%% calculate BR, CR, and ISF
%     brCrIsf = getBrCrIsf(resultsMatrix);
% 
%  %%% Calculating Loss
%     lossMatrix = mpcPredictionLoss(7, resultsMatrix);
% 
%  %%% Plotting Loss of Each Subject
%     plotLossOfEachSubjectOverTime(lossMatrix, 3, optionNames, brCrIsf,...
%         "../Plots/");
%%

    figure('Name','Loss of Each Subject');
    
    % CHECKS
    if isempty(lossMatrix)|| isempty(optionNames)
        error("Error. \n arguments cannot be empty or zero-length")
    end
    
    % get number of subjects
    numSubjects = size(lossMatrix, 3);
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0, 0, 10, 2.5*(numSubjects/numPlotsPerRow)];
    
    % determine number of rows
    rowCount = ceil(numSubjects/numPlotsPerRow);
    
    for subject = 1:numSubjects
        subplot(rowCount,numPlotsPerRow,subject);
        
        optionsVector = "[";
        for option = 1:size(lossMatrix, 1)
            optionsVector = strcat(optionsVector, 'lossCol', num2str(option) ," ");
            eval(strcat('lossCol', num2str(option),'= lossMatrix(:,:,subject);'));
        end
        optionsVector = strcat(optionsVector, "]");
        
        eval(strcat('optionsVectorReal = ', optionsVector , ';'));
        
        
        tempTS = timeseries(optionsVectorReal','Name', strcat('Loss'));
        tempTS.TimeInfo.Units = 'weeks';
        tempTS = setuniformtime(tempTS,'Interval', 1, 'StartTime', 1);
        plot(tempTS);
        
        br = brCrIsf(subject, 1);
        cr = brCrIsf(subject, 2);
        isf = brCrIsf(subject, 3);

        title(strcat("Subject ",  num2str(subject), ...
                     ", br=", num2str(round(br)), ...
                     ", cr=", num2str(round(cr)), ...
                     ", isf =", num2str(round(isf))));


        legend(optionNames);
        axis([0 25 0 0.6])

        drawnow;
    end
    
    if exist('saveDir','var')
        if ~endsWith(saveDir, '/')
            saveDir = strcat(saveDir, '/', datestr(now,'yyyymmddHHMM'), ...
                '_subjectLossOverTime.png');
        else
            saveDir = strcat(saveDir, datestr(now,'yyyymmddHHMM'), ...
                '_subjectLossOverTime.png');
        end
        saveas(gcf,saveDir);
        disp(strcat('      * saved to', saveDir));
    end
end

