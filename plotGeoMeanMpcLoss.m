% This function plots the mean MPC loss for each option over time
function plotGeoMeanMpcLoss(optionNames, lossMatrix, saveDir)
% ehuang
% ARGUMENTS
%   lossMatrix: a 3D matrix of loss for each result/option, subject, time
%   optionNames: vector of name strings assocaited with each result group
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
%  %%% Calculating Loss
%     lossMatrix = mpcPredictionLoss(7, resultsMatrix);
% 
%  %%% Plotting Mean Loss
%     plotMeanMpcLoss(optionNames, lossMatrix, "../Plots/");
%%
    % CHECKS
    if isempty(lossMatrix)|| isempty(optionNames)
        error("Error. \n arguments cannot be empty or zero-length")
    end
    
    if length(optionNames) ~= size(lossMatrix, 1)
        error("Error. \n arguments have incompatible sizes")
    end
    
    for option = 1:length(optionNames)
        if ~isa(optionNames(option),'string') && ~isa(optionNames(option),'char')
            error("Error. \n arguments must be of type 'string'")
        end
    end
    
    figure('Name','Geo Mean Loss');
    
    meanLossArray = zeros(size(lossMatrix, 2), size(lossMatrix, 1));
    
    for resultSet = 1:size(lossMatrix, 1)
        meanLoss = geomean(lossMatrix(resultSet, :, :),3);
        meanLossArray(:, resultSet) = meanLoss;
    end
    
    lossVectorTS = timeseries(meanLossArray,'Name','Geo Mean Loss Across 27 Subjects over 180 Days');
    lossVectorTS = setuniformtime(lossVectorTS,'Interval', 1, 'StartTime', 1);
    lossVectorTS.TimeInfo.Units = 'weeks';
    plot(lossVectorTS);
    legend(optionNames);
    title('Geo Mean Loss');
    drawnow

    if exist('saveDir','var')
        if ~endsWith(saveDir, '/')
            saveDir = strcat(saveDir, '/', datestr(now,'yyyymmddHHMM'), ...
                '_geoMeanMpcLoss.png');
        else
            saveDir = strcat(saveDir, datestr(now,'yyyymmddHHMM'), ...
                '_geoMeanMpcLoss.png');
        end
        saveas(gcf,saveDir);
        disp(strcat('      * saved to', saveDir));
    end
end

