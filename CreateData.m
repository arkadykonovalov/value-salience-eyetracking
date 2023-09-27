function data = CreateData(tilts, contrasts, valuecondition)
% THIS FUNCTION CREATES THE DATA FRAME WITH RANDOM ORDER OF CONDITIONS AND
% TRIALS

% Conditions description:
% 1: Salience plus
% 2: Salience minus
% 1: Orientation left
% 2: Orientation right

% conditions
conditions = randperm(4);

% Create grids
[T, C] = meshgrid(tilts, contrasts);

% Reshape grids into column vectors
tilts_pairs = T(:);
contrasts_pairs = C(:);

% Display the pairs
pairs = [tilts_pairs, contrasts_pairs];

temp = [];
for i = 1:size(pairs,1)
    for j = 1:size(pairs,1)
        temp = [temp; pairs(i,:) pairs(j,:)];
    end
end

% Randomize row order and create 4 blocks
temp_randomized = [];
for i = 1:4
    numRows = size(temp, 1);
    randomIndices = randperm(numRows);
    temp_randomized = [temp_randomized; temp(randomIndices, :) i.*ones(size(temp,1),1) ...
        [1:size(temp,1)]' conditions(i).*ones(size(temp,1),1) ];
end

% Converting into a dataframe
data = array2table(temp_randomized,'VariableNames',{'tilt_left','contrast_left','tilt_right',...
    'contrast_right','block','btrial','condition'});

% Adding variables
data.valuecondition = valuecondition*ones(size(data,1),1);
data.trial = [1:size(data,1)]';
data.choice = -999*ones(size(data,1),1);
data.accuracy = -999*ones(size(data,1),1);
data.payoff = -999*ones(size(data,1),1);
data.rt = -999*ones(size(data,1),1);
data.onset = -999*ones(size(data,1),1);
data.response = -999*ones(size(data,1),1);
data.feedback_onset = -999*ones(size(data,1),1);

data.onset_et = -999*ones(size(data,1),1);
data.response_et = -999*ones(size(data,1),1);
data.feedback_onset_et = -999*ones(size(data,1),1);
data.ITI_onset_et = -999*ones(size(data,1),1);

data.reward_left = zeros(size(data,1),1);
data.reward_right = zeros(size(data,1),1);

if valuecondition == 1

    for i = 1:4
        data.reward_left(data.condition==1 & data.contrast_left == contrasts(i),:) = i;
        data.reward_right(data.condition==1 & data.contrast_right == contrasts(i),:) = i;

        data.reward_left(data.condition==2 & data.contrast_left == contrasts(i),:) = 5 - i;
        data.reward_right(data.condition==2 & data.contrast_right == contrasts(i),:) = 5 - i;

        data.reward_left(data.condition==3 & data.tilt_left == tilts(i),:) = i;
        data.reward_right(data.condition==3 & data.tilt_right == tilts(i),:) = i;

        data.reward_left(data.condition==4 & data.tilt_left == tilts(i),:) = 5 - i;
        data.reward_right(data.condition==4 & data.tilt_right == tilts(i),:) = 5 - i;
    end

elseif valuecondition == 2

    data.reward_left(data.condition==1 & data.contrast_left >= data.contrast_right,:) = 1;
    data.reward_right(data.condition==1 & data.contrast_left <= data.contrast_right,:) = 1;

    data.reward_left(data.condition==2 & data.contrast_left <= data.contrast_right,:) = 1;
    data.reward_right(data.condition==2 & data.contrast_left >= data.contrast_right,:) = 1;

    data.reward_left(data.condition==3 & data.tilt_left >= data.tilt_right,:) = 1;
    data.reward_right(data.condition==3 & data.tilt_left <= data.tilt_right,:) = 1;

    data.reward_left(data.condition==4 & data.tilt_left <= data.tilt_right,:) = 1;
    data.reward_right(data.condition==4 & data.tilt_left >= data.tilt_right,:) = 1;

end

end