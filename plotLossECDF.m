% This function plots a the ECDF of each subject
function plotLossECDF(lossMatrix, optionNames, saveDir)
% ehuang
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
%  %%% Plotting Loss ECDF
%     plotLossECDF(lossMatrix, optionNames, "../Plots/");
%%
    figure('Name','ECDF of Subject Loss');
    colors='brgykcm';

    for alt = 1:size(lossMatrix, 1)
        % collapse loss matrix
        tempLoss = nanmean(squeeze(lossMatrix(alt, :, :)), 1);
       
        [f, x] = ecdf(permute(tempLoss, [3, 2, 1]));
        
        plot(x,f,strcat(colors(alt),'-'));
        hold on;
    end

    ylabel("% of Subjects");
    xlabel("Loss");
    title(strcat("ECDF of Subject Loss"));
    legend(optionNames, 'Location','northwest');
    drawnow;

    if exist('saveDir','var')
        if ~endsWith(saveDir, '/')
            saveDir = strcat(saveDir, '/', datestr(now,'yyyymmddHHMM'), ...
                '_meanLossECDF.png');
        else
            saveDir = strcat(saveDir, datestr(now,'yyyymmddHHMM'), ...
                '_meanLossECDF.png');
        end
        saveas(gcf,saveDir);
        disp(strcat('      * saved to', saveDir));
    end
end