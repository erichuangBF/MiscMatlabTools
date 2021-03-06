% This function plots MPC prediction quality for each result group over a 4 hour prediction horizon
function plotMpcPredictQualityOriginal(resultsMatrix, lossMatrix, percentiles, saveDir)
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
%%
    numAlternatives = numel(fieldnames(resultsMatrix));
    if numel(fieldnames(resultsMatrix)) > 7
        error("Error. \n specified resultsMatrix argument has more than 7 results")
    end

    figure('Name',"MPC Prediction Quality");
    
    colors='bkrgycm';
    plots = [];
    resultNames = fieldnames(resultsMatrix);

    for option = 1:numAlternatives
        % get array of result names
        

        eval(strcat("resultStruct = resultsMatrix.", resultNames(option), ";"));
        
        numSubjects = length(resultStruct.results);

        horizon = length(resultStruct.results(1).controller.loop15Data(1).predictions); % 16, one per 15 min pred interval
        predictionQualityMatrix = zeros(numSubjects, horizon);

        for subject = 1:numSubjects
            pred = zeros(length(resultStruct.results(subject).controller.loop15Data),horizon);

            for predIndex = 1:length(resultStruct.results(subject).controller.loop15Data)
                pred(predIndex,:) = resultStruct.results(subject).controller.loop15Data(predIndex).predictions;
            end

            egv = resultStruct.results(subject).cgm.egvsMgDl.Data;
            egv = egv(1:3:end); % egv is available every 5 minutes, but predictions are available every 15 minutes; therefore you should skip some egv values to be able to produce the correct ratio.
            sigma = zeros(horizon,1); 
            mu = zeros(horizon,1); 

            for horizonIndex = 1:horizon
                predQuality = egv(horizonIndex+1:end)./pred(1:end-horizonIndex,horizonIndex);
                [sigma(horizonIndex), mu(horizonIndex)] = robustcov(log(predQuality)); % returns [variance, mean]
                % Lane: 
                % Here's how I use it: [s m]=robustcov(log(x)); 
                % gm=exp(m); gs=exp(sqrt(s)) this is for the univariate case; 
                % when x is multivariate then s is a covariance matrix and so 
                % the variances are along the diagonal gs=exp(sqrt(diag(s)))
            end

            MPCpredictionsMuStar = exp(mu);
            MPCpredictionsSigmaStar = exp(sigma);

            mpcQuality = zeros(1, length(MPCpredictionsSigmaStar));

            for predictionInterval = 1:length(MPCpredictionsMuStar)
                mpcQuality(predictionInterval) = MPCpredictionsMuStar(predictionInterval)/MPCpredictionsSigmaStar(predictionInterval);
            end

            predictionQualityMatrix(subject, :) = mpcQuality;

        end

        y = prctile(predictionQualityMatrix,percentiles,1)';
        x = (1:16)/4;
        tempPlot = semilogy(x,y(:,1),strcat(colors(option),'-.'),...
                 x,y(:,2),strcat(colors(option),'-'),...
                 x,y(:,3),strcat(colors(option),'--'));
        hold on
        plots = [plots tempPlot];
    end

    ylabel("MPC Prediction Quality (estimated/predicted)");
    xlabel("prediction horizon");
    yticks([1/2 2/3 1 5/4])
    semilogy([0 4],[1 1],'k')
    axis([0 4 1/2 5/4])
    yticklabels({'1/2' '2/3' '1' '5/4'})
    title("MPC Prediction Quality for z=5%, 50%, and 95%");

    % custom legend
    h = zeros(numAlternatives, 1);
    qualityLegend = strings([1,numAlternatives]);
    for alt = 1:numAlternatives
        eval(strcat('tempMeanLoss = mean(mean(lossMatrix(', num2str(alt), ')));'));
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
