clear all;

addpath('/Users/konovala/Documents/toolboxes/edf-converter-master'); % adding toolbox to path

id = 6;
block = 4;

filename = fullfile(['/Users/konovala/Drive/RESEARCH/Valuation_salience/experiment/code/data/edf/ak' num2str(id) '_' num2str(block) '.edf']);

datafile = ['/Users/konovala/Drive/RESEARCH/Valuation_salience/experiment/code/data/csv/data_' num2str(id) '.csv'];
data = readtable(datafile);

% remove non-response trials
data = data(data.choice > 0,:);

% convert the file using toolbox
edf = Edf2Mat(filename); 


x = edf.Samples.posX(:,1); % extracts x coordinate
y = edf.Samples.posY(:,1); % extracts y coordinate
y = 1080 - y; %reverse y
time = edf.Samples.time; % extracts time stamp
time = time - time(1); % reference time to beginning

% resample to 1000 hz
x = x(1:2:end,:);
y = y(1:2:end,:);
time = time(1:2:end,:);

data_table = [x y time]; % put X and Y and time  in one table

% check basic distributions
plotHeatmap(edf); % plot heatmap using toolbox for quick look
hist(x,50);
hist(y,50);

timestamps_of_choice = data.onset_et(data.block == block,:); % when choice starts
timestamps_of_response = data.response_et(data.block == block,:); % when subject presses a button
timestamps_of_feedback = data.feedback_onset_et(data.block == block,:); % when subject gets the outcome
timestamps_of_ITI = data.ITI_onset_et(data.block == block,:); % when subject gets ITI cross

% Create dummy variable for choice stage, response stage, and outcome stage

%Create dummies for the start of each stage 
onset_dummy = ismember(time,timestamps_of_choice); 
response_dummy = ismember(time, timestamps_of_response);    
feedback_dummy = ismember(time, timestamps_of_feedback);
ITI_dummy = ismember(time, timestamps_of_ITI);

% Table to check it worked
t = table(time, onset_dummy, response_dummy, feedback_dummy, ITI_dummy);

% Cumulatively sum dummies so they indicate stage number for the beginning
% of each stage
onset_stage_no = cumsum(t.onset_dummy).*(t.onset_dummy ~=0); 
response_stage_no = cumsum(t.response_dummy).*(t.response_dummy ~=0);
feedback_stage_no = cumsum(t.feedback_dummy).*(t.feedback_dummy ~=0);
ITI_stage_no = cumsum(t.ITI_dummy).*(t.ITI_dummy ~=0);

% Table for checking
t2 = table(time, onset_stage_no, response_stage_no, feedback_stage_no, ITI_stage_no);

% Loop to create stage dummies. Each iteration produces a logical vector 
% relating to a single stage, displaying 1 when the condition 
% (time greater than or equal to onset, and less than response) is met

% retrieve the number of valid trials
sums = table2array(sum(t,1));
Ntrials = sums(1,2);

choice_stage = zeros(length(time),Ntrials);
response_stage = zeros(length(time),Ntrials);
outcome_stage = zeros(length(time),Ntrials);
ITI_stage = zeros(length(time),Ntrials);

for n = 1:Ntrials
    choice_stage(:,n) = t2.time >= t2.time(onset_stage_no == n) & t2.time < t2.time(response_stage_no == n);
    response_stage(:,n) = t2.time >= t2.time(response_stage_no == n) & t2.time < t2.time(feedback_stage_no == n);
    outcome_stage(:,n) = t2.time >= t2.time(feedback_stage_no == n) & t2.time < t2.time(ITI_stage_no == n);
    if n < Ntrials
        ITI_stage(:,n) = t2.time >= t2.time(ITI_stage_no == n) & t2.time < t2.time(onset_stage_no == n+1);
    end
end

choice_stage_dummy = sum(choice_stage, 2);
response_stage_dummy = sum(response_stage, 2);
outcome_stage_dummy = sum(outcome_stage, 2);
ITI_stage_dummy = sum(ITI_stage, 2);

% this table now has stage dummies for each stage
t3 = table(time, choice_stage_dummy, response_stage_dummy, outcome_stage_dummy, ITI_stage_dummy);

% plotting distributions of X coordinate for specific stages
tiledlayout(2,2)

nexttile
hist(x(logical(choice_stage_dummy)),50)
title('Choice')

nexttile
hist(x(logical(response_stage_dummy)),50)
title('Response')

nexttile
hist(x(logical(outcome_stage_dummy)),50)
title('Outcome')

nexttile
hist(x(logical(ITI_stage_dummy)),50)
title('ITI')