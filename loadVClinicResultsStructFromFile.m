% ehuang
function returnedResult = loadVClinicResultsStructFromFile(resultPath)
% FUNCTION
% Loads a result struct from a vClinic(.mat file) file
%
% ARGUMENTS
% resultPath: file path containing vclinic result mat file
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
%%

if isempty(resultPath)
    error("Error. \n argument cannot be empty")
end

if ~isa(resultPath,'string')
    error("Error. \n argument must be of type 'string'")
end

returnedResult = load(resultPath, 'results');

end