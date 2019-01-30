% This function plots MPC prediction quality for each result group over a 4 hour prediction horizon
function plotMpcPredictQuality(resultsMatrix, lossMatrix, percentiles, saveDir)
% ehuang
% ARGUMENTS
%   resultsMatrix: matrix of vClinic result structs loaded by 
%     'loadVClinicResultsStructFromFile()' - see example
%   lossMatrix: a 3D matrix of loss for each result/option, subject, time
%   percentiles: vector of nth percentiles of MPC predict quality to plot
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
%  %%% Plotting MPC Prediction Quality
%     plotMpcPredictQuality(resultsMatrix, lossMatrix, [5 50 95], "../Plots/");
    numAlternatives = numel(fieldnames(resultsMatrix));
    if numel(fieldnames(resultsMatrix)) > 7
        error("Error. \n specified resultsMatrix argument has more than 7 results")
    end

    figure('Name',"MPC Prediction Quality");
    clf
    colors='brgykcm';
    
    x = (1:16)/4;
    resultNames = fieldnames(resultsMatrix);

    for option = 1:numAlternatives
        eval(strcat("resultStruct = resultsMatrix.", resultNames(option), ";"));
        numSubjects = length(resultStruct.results);

        horizon = length(resultStruct.results(1).controller.loop15Data(1).predictions); % 16, one per 15 min pred interval
        
        timeIndexCount = length(resultStruct.results(1).controller.loop15Data);
       
        predictionQualityMatrix = zeros(numSubjects, timeIndexCount, horizon);
        
        for subject = 1:numSubjects
            prediction = zeros(timeIndexCount,horizon);
            
            for timeIndex = 1:timeIndexCount
                % 16 hour prediction horizon for every time index
                prediction(timeIndex,:) = resultStruct.results(subject).controller.loop15Data(timeIndex).predictions;
            end

            egv = resultStruct.results(subject).cgm.egvsMgDl.Data;
            % egv is available every 5 minutes, but predictions are available every 15 minutes
            % therefore you should skip some egv values to be able to produce the correct ratio.
            egv = egv(1:3:end);

%             sigma = zeros(horizon,1);
%             mu = zeros(horizon,1);
            
            for horizonIndex = 1:horizon % to 16
                predQual = egv(horizonIndex+1:end)./prediction(1:end-horizonIndex,horizonIndex);
                
                pad = NaN(timeIndexCount-length(predQual), 1); % each horizon will have one less element
                
                predictionQualityMatrix(subject, :, horizonIndex) = vertcat(predQual, pad);
            end
        end
        
        % collapse predictionQualityMatrix by averaging across subjects
        meanPredictionQualityMatrix = squeeze(nanmean(predictionQualityMatrix, 1));
        
        
        muStars = zeros(horizon, 1);
        sigmaStars = zeros(horizon, 1);
        
        for horizonIndex = 1:horizon
            thisPredQualityVector = meanPredictionQualityMatrix(:, horizonIndex);
            thisPredQualityVector = thisPredQualityVector(~isnan(thisPredQualityVector));
            
            % get rid of trailing zeros
%             truncatedPredQualityVector = thisPredQualityVector(1:find(thisPredQualityVector,1,'last'));

%             [sigma(horizonIndex), mu(horizonIndex)] = ...
%                 robustcov(log(thisPredQualityVector));
                
            muStars(horizonIndex) = exp(nanmean(log(thisPredQualityVector)));
            sigmaStars(horizonIndex) = exp(nanstd(log(thisPredQualityVector)));
                
        end
        
%         muStars = exp(mu);
%         sigmaStars = exp(sqrt(sigma));
        
        quantiles=norminv(percentiles);
        
        x = (1:16)/4;
        y = muStars.*(sigmaStars.^quantiles);
        
        semilogy(x,y(:, 1),strcat(colors(option),'-.'),...
                 x,y(:, 2),strcat(colors(option),'-'),...
                 x,y(:, 3),strcat(colors(option),'--'));
        hold on;

    end
    
%     title(strcat("MPC Prediction Quality for z=", ,"%, 50%, and 95%"));
    
    
    
    
    
    
    ylabel("actual/predicted");
    xlabel("prediction horizon");
    yticks([1/2 2/3 1 5/4 13/4])
    plot([0 4],[1 1],'k')
    axis([0 4 1/2 13/4])
    yticklabels({'1/2' '2/3' '1' '5/4' '7/3' '13/4'})
    drawnow;

    % custom legend
    h = zeros(numAlternatives, 1);
    qualityLegend = strings([1,numAlternatives]);
    for alt = 1:numAlternatives
        tempMeanLoss = mean(mean(lossMatrix(num2str(alt))));
        qualityLegend(alt) = strcat(resultNames(alt), ", loss=", num2str(tempMeanLoss, '%5.3f'));
        eval(strcat("h(", num2str(alt), ") = plot(NaN,NaN,'", colors(alt), "');"));
    end

    legend(h, qualityLegend, 'Location','southwest');
    drawnow;

    
    if exist('saveDir','var')
        if ~endsWith(saveDir, '/')
            saveDir = strcat(saveDir, '/', datestr(now,'yyyymmddHHMM'), ...
                '_mpcPredictQuality.png');
        else
            saveDir = strcat(saveDir, datestr(now,'yyyymmddHHMM'), ...
                '_mpcPredictQuality.png');
        end
        saveas(gcf,saveDir);
        disp(strcat('      * saved to', saveDir));
    end
end
