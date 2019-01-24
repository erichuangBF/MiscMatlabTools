% ehuang
function plotMeanLossHistogram(lossMatrix, optionNames, saveDir)
% FUNCTION
%    This function plots a histogram illustrating loss across subjects
% 
% ARGUMENTS
%   lossMatrix: a 3D matrix of loss for each result/option, subject, time
%   numPlotsPerRow: number of plots to display in each row
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
%  %%% Plotting Loss Histogram
%     plotMeanLossHistogram(lossMatrix, optionNames, "../Plots/");
%%
    figure('Name','Mean Loss vs Subject');

    meanLossOfEachAlt = zeros(size(lossMatrix, 3), size(lossMatrix, 1));

    for alt = 1:size(lossMatrix, 1)
        eval(strcat("meanLossOfEachAlt(:, ", num2str(alt), ") = mean(lossMatrix(", num2str(alt), ", :, :));"));
    end

    bar(meanLossOfEachAlt, 'grouped');
    hold on;

    ylabel("loss");
    xlabel("subject");
    title(strcat("Mean Loss vs Subject - Alt: ", optionNames(alt)));
    legend(optionNames);
    axis([0 size(lossMatrix, 3) 0 0.35])
    drawnow;

    if exist('saveDir','var')
        if ~endsWith(saveDir, '/')
            saveDir = strcat(saveDir, '/', datestr(now,'yyyymmddHHMM'), ...
                '_meanLossHistogram.png');
        else
            saveDir = strcat(saveDir, datestr(now,'yyyymmddHHMM'), ...
                '_meanLossHistogram.png');
        end
        saveas(gcf,saveDir);
        disp(strcat('      * saved to', saveDir));
    end
end