% ehuang
function brCrIsf = getBrCrIsf(resultsMatrix)
% FUNCTION
% Returns a 2D matrix of BR, CR, and ISF values for each subject where each 
%     row represents a subject
% Fails if these values are inconsistent across results
% 
% ARGUMENTS
% resultsMatrix: matrix of vClinic result structs loaded by 
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
%
%  %%% calculate BR, CR, and ISF
%     brCrIsf = getBrCrIsf(resultsMatrix);
%
%%
    % get array of result names
    resultNames = fieldnames(resultsMatrix);    
    % get number of result structs
    numResultStructs = length(resultNames);
    % get number of subjects
    eval(strcat("numSubjects = length(resultsMatrix.",resultNames(1),".results);"));
    
    brCrIsf = zeros(numSubjects, 3);
    
    % get first results struct
    eval(strcat("firstResult = resultsMatrix.", resultNames(1), ".results;"));
    for subject = 1:numSubjects
        br = firstResult(subject).subject.totalDailyBasalRateUnits.programmed;
        cr = firstResult(subject).subject.carbRatioGramPerUnit.programmed;
        isf = firstResult(subject).subject.insulinSensitivityMgPerDlPerUnit.programmed;
        brCrIsf(subject, :) = [br cr isf];
    end
   
    if numResultStructs > 1
       % check if there are discrepancies
        for resultNo = 2:numResultStructs
            eval(strcat("thisResult = resultsMatrix.", resultNames(resultNo), ","));
            for subjectNo = 1:numSubjects
                thisSubject = thisResult.results(subjectNo).subject;
                br = thisSubject.totalDailyBasalRateUnits.programmed;
                cr = thisSubject.carbRatioGramPerUnit.programmed;
                isf = thisSubject.insulinSensitivityMgPerDlPerUnit.programmed;
                if br ~= brCrIsf(subjectNo, 1) || ...
                        cr ~= brCrIsf(subjectNo, 2) || ...
                        isf ~= brCrIsf(subjectNo, 3)
                    error("Error. \n subjects differ between results")
                end
            end
        end
    end
end