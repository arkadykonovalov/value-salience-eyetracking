function data = CreatePsychometric(sMean,sStep) 
% THIS FUNCTION CREATES THE DATA FRAME WITH RANDOM ORDER OF CONDITIONS AND
% TRIALS

contrasts = [sMean-sStep*3/2 sMean-sStep*5/4 sMean-sStep/2 sMean-sStep/4 sMean+sStep/4 sMean+sStep/2 sMean+sStep*5/4  sMean+sStep*3/2]; 

% Create grids
[T, C] = meshgrid(contrasts, contrasts);

% Reshape grids into column vectors
first_pairs = T(:);
second_pairs = C(:);

% Display the pairs
pairs = [first_pairs, second_pairs];

% Randomize row order and create 4 blocks
temp_randomized = [];
numRows = size(pairs, 1);
randomIndices = randperm(numRows);
temp_randomized = [pairs(randomIndices, :) [1:size(pairs,1)]' ]; 


% Converting into a dataframe
data = array2table(temp_randomized,'VariableNames',{'contrast_left',...
    'contrast_right','trial'});

% Adding variables
data.choice = -999*ones(size(data,1),1);
data.accuracy = -999*ones(size(data,1),1);
data.payoff = -999*ones(size(data,1),1);
data.rt = -999*ones(size(data,1),1);
data.onset = -999*ones(size(data,1),1);
data.response = -999*ones(size(data,1),1);

end