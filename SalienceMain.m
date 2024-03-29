% SCRIPT TO RUN SALIENCE-VALUE EXPERIMENT
% by Arkady Konovalov (arkady.konovalov@gmail.com)
% Version Sep 27 2023

% Within subjects conditions (data.condition) description:
% 1: Salience plus - brighter patches give more points
% 2: Salience minus - darker patches give more points
% 1: Orientation left - left-tilted patches give more points
% 2: Orientation right - right-tilted patches give more points

% Between subjects conditions (data.valuecondition) description:
% 1: 1/2/3/4 points are assigned to 4 patches
% 2: 0/1 points for guessing the correct patch

% Clear the workspace and the screen
sca;
close all;
clearvars;

% EYE-TRACKING
eyeTracking = false; % set to true if want eye-tracking

%
temp = dir('data/csv/*.csv'); % check how many csv files in the datafolder
sessID = size(temp,1) + 1; % assign session ID

% assign conditions
if rem(sessID,2) == 0
    valuecondition = 1;  % value scale (1 - 2 - 3 - 4 points for correct answer)
    convertionRate = 500; % in points
else
    valuecondition = 2; % binary reward (1 point for a correct answer)
    convertionRate = 150; % in points
end

% payment parameters
showupFee = 7; % in pounds

testTrials = 0;  % put number of trials > 0 to run for only that number of trials


% EXPERIMENT PARAMETERS

% Stimuli parameters
sMean = 90;
sStep = 8;

% tilts and contrasts
tiltsSet = [sMean-sStep*3/2 sMean-sStep/2 sMean+sStep/2  sMean+sStep*3/2]; % set of tilts 1 -  4
contrastsSet = [sMean-sStep*3/2 sMean-sStep/2 sMean+sStep/2  sMean+sStep*3/2];  % set of contrasts 1 - 4

maxRT = 2;  % maximal response time
maxRTC = 5;  % maximal response time for calibration
timeITI = 1; % fixation cross time
timeFeedback = 0.5; % how long is feedback shown?

% Set up Psychtoolbox
PsychDefaultSetup(2);

% Skeep sync tests (they don't work properly on Macs)
Screen('Preference', 'SkipSyncTests', 1);
%FlushEvents;
%HideCursor; % could be useful for the final version

% Set up the screen
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
[wPtr, rect] = PsychImaging('OpenWindow', screenNumber, black);

% Set up the keyboard
KbName('UnifyKeyNames');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');

% Set up the frame size and color
frameSize = 5;  % in pixels
frameColor = [1, 1, 1];
frameColorCorrect = [0.2, 1, 0.2];
frameColorWrong = [1, 0.2, 0.2];

% Set up the text
Screen('TextSize', wPtr, 60);
Screen('TextColor', wPtr, white);

% Reward positions on the screen
yReward = rect(4)*3/4;
xRewardLeft = rect(3)/4;
xRewardRight = rect(3)*3/4;

% Initial stimulus params for the gabor patch:
gaborSize = 323;
res = 1*[gaborSize gaborSize]; % size
phase = 0;  % the phase of the gabors sine grating in degrees.
sc = 50.0; % the spatial constant of the gaussian hull function of the gabor, ie.  the "sigma" value in the exponential function.
freq = .1; % its spatial frequency in cycles per pixel.
aspectratio = 1.0;  % aspect ratio

% Create areas on the left and right centers of the screen
leftRect = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)/4, rect(4)/2);
rightRect = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*3/4, rect(4)/2);

% Create a row of areas to display 4 patches
infoRect1 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)/5, rect(4)/2);
infoRect2 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*2/5, rect(4)/2);
infoRect3 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*3/5, rect(4)/2);
infoRect4 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*4/5, rect(4)/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN TASK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up the dataframe
data = CreateData(tiltsSet,contrastsSet, valuecondition);
data.session_id = sessID*ones(size(data,1),1);

if testTrials == 0
    numTrials = size(data,1);
else
    numTrials = testTrials;
end

% Run the tutorial
SalienceTutorial(wPtr,rect, tiltsSet,contrastsSet, valuecondition, convertionRate);

% start the eye tracker

if eyeTracking
    status = Eyelink('initialize');
    et = EyelinkInitDefaults(wPtr);
    et0 = 0;

    EyelinkInit(0);
    Eyelink('command', 'calibration_type = HV5');

end


% Loop through the trials
for trial = 1:numTrials

    % BLOCK START INFORMATION SCREEN
    if data.btrial(trial) == 1


        % calibrate the eye tracker
        if eyeTracking

            EyelinkDoTrackerSetup(et);
            etfilename = ['ak' num2str(sessID) '_' num2str(data.block(trial)) '.edf'];
            status=Eyelink('OpenFile',etfilename);
            Eyelink('startrecording');

            % record  starting time (eye-tracker timing)
            evt = Eyelink('NewestFloatSample');
            et0 = evt.time;

            eye_used = Eyelink('eyeavailable'); % get eye that's tracked

        end

        Screen('TextColor', wPtr, white);
        Screen('TextSize', wPtr, 30);

        gabortex = CreateProceduralGabor(wPtr, gaborSize, gaborSize, 0, [0 0 0 0.0]);

        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, ['BLOCK ' num2str(data.block(trial))], 'center', 'center');
        Screen('Flip', wPtr);
        WaitSecs(3);

        Screen('FillRect', wPtr, black);

        if data.condition(trial) == 1

            Screen('DrawTexture', wPtr, gabortex, [], infoRect1, 90+tiltsSet(2), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect2, 90+tiltsSet(2), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect3, 90+tiltsSet(4), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(3), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect4, 90+tiltsSet(4), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(4), aspectratio, 0, 0, 0]);
            
            if valuecondition == 1
                DrawFormattedText(wPtr, 'In this block, brighter patches give more points.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Tilt does not matter.', 'center', rect(4)*2/6);
            elseif valuecondition == 2
                DrawFormattedText(wPtr, 'In this block, choose a brighter patch to get a point.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Tilt does not matter.', 'center', rect(4)*2/6);
                DrawFormattedText(wPtr, 'Shown left to right: patches from darkest to brightest.', 'center', rect(4)*4/6);
            end

        elseif data.condition(trial) == 2


            Screen('DrawTexture', wPtr, gabortex, [], infoRect1, 90+tiltsSet(3), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(4), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect2, 90+tiltsSet(3), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(3), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect3, 90+tiltsSet(1), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect4, 90+tiltsSet(1), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);

            if valuecondition == 1
                DrawFormattedText(wPtr, 'In this block, darker patches give more points.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Tilt does not matter.', 'center', rect(4)*2/6);
            elseif valuecondition == 2
                DrawFormattedText(wPtr, 'In this block, choose a darker patch to get a point.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Tilt does not matter.', 'center', rect(4)*2/6);
                DrawFormattedText(wPtr, 'Shown left to right: patches from brightest to darkest.', 'center', rect(4)*4/6);
            end

        elseif data.condition(trial) == 3


            Screen('DrawTexture', wPtr, gabortex, [], infoRect1, 90+tiltsSet(1), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect2, 90+tiltsSet(2), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect3, 90+tiltsSet(3), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(3), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect4, 90+tiltsSet(4), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(3), aspectratio, 0, 0, 0]);

            if valuecondition == 1
                DrawFormattedText(wPtr, 'In this block, patches tilted more to the left give more points.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Brightness does not matter.', 'center', rect(4)*2/6);
            elseif valuecondition == 2
                 DrawFormattedText(wPtr, 'In this block, choose a patch tilted more to the left to get a point.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Brightness does not matter.', 'center', rect(4)*2/6);
                DrawFormattedText(wPtr, 'Shown left to right: patches from most right-tilted to most left-tilted.', 'center', rect(4)*4/6);
            end

        elseif data.condition(trial) == 4


            Screen('DrawTexture', wPtr, gabortex, [], infoRect1, 90+tiltsSet(4), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(4), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect2, 90+tiltsSet(3), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(4), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect3, 90+tiltsSet(2), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
            Screen('DrawTexture', wPtr, gabortex, [], infoRect4, 90+tiltsSet(1), [], [], [], [],...
                kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);

             if valuecondition == 1
                DrawFormattedText(wPtr, 'In this block, patches tilted more to the right give more points.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Brightness does not matter.', 'center', rect(4)*2/6);
            elseif valuecondition == 2
                DrawFormattedText(wPtr, 'In this block, choose a patch tilted more to the right to get a point.', 'center', rect(4)*1.5/6);
                DrawFormattedText(wPtr, 'Brightness does not matter.', 'center', rect(4)*2/6);
                DrawFormattedText(wPtr, 'Shown left to right: patches from most left-tilted to most right-tilted.', 'center', rect(4)*4/6);
            end

        end

        if valuecondition == 1
            DrawFormattedText(wPtr, '1', rect(3)*1/5, rect(4)*4/6);
            DrawFormattedText(wPtr, '2', rect(3)*2/5, rect(4)*4/6);
            DrawFormattedText(wPtr, '3', rect(3)*3/5, rect(4)*4/6);
            DrawFormattedText(wPtr, '4', rect(3)*4/5, rect(4)*4/6);
        end

        DrawFormattedText(wPtr, 'Press any key when you are ready', 'center', rect(4)*5/6);

        Screen('Flip', wPtr);
        WaitSecs(3);
        KbWait;
        Screen('TextSize', wPtr, 60);

        % Draw the fixation before the trials start
        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, 'Get ready.', 'center', 'center');
        Screen('Flip', wPtr);
        WaitSecs(2);

        % Draw the fixation before the trials start
        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, '+', 'center', 'center');
        Screen('Flip', wPtr);
        WaitSecs(timeITI);

        %record block starting time
        t0 = GetSecs;


    end


    tilts = [data.tilt_left(trial) data.tilt_right(trial)];
    contrasts = [data.contrast_left(trial) data.contrast_right(trial)];
    rewards = [data.reward_left(trial) data.reward_right(trial)];

    % Build a procedural gabor texture for a gabor with a support of
    % gaborSize x gaborSize pixels, and a RGB color offset of 0 (black background)
    gabortex = CreateProceduralGabor(wPtr, gaborSize, gaborSize, 0, [0 0 0 0.0]);

    % Draw the stimuli
    Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tilts(1), [], [], [], [],...
        kPsychDontDoRotation, [phase+180, freq, sc, contrasts(1), aspectratio, 0, 0, 0]);

    Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tilts(2), [], [], [], [],...
        kPsychDontDoRotation, [phase+180, freq, sc, contrasts(2), aspectratio, 0, 0, 0]);
    Screen('Flip', wPtr);

    % record stimuli onset time
    data.onset(trial) = GetSecs - t0;

    if eyeTracking
        evt = Eyelink('newestfloatsample');
        data.onset_et(trial) = evt.time - et0;
    end

    % Wait for a response
    response = 0;
    timer = 0;
    while ~response && timer < maxRT
        [keyIsDown, secs, keyCode] = KbCheck;
        timer = GetSecs -  data.onset(trial) - t0;

        if keyIsDown

            % record response time
            data.rt(trial) = GetSecs - data.onset(trial) - t0;
            data.response(trial) = GetSecs - t0;

            if eyeTracking
                evt = Eyelink('newestfloatsample');
                data.response_et(trial) = evt.time - et0;
            end

            if keyCode(leftKey)
                response = 1;
                selectedRect = leftRect;
                xReward = xRewardLeft;
                reward = rewards(1);

                % was the choice correct?
                if data.reward_left(trial) >= data.reward_right(trial)
                    data.accuracy(trial) = 1;
                else
                    data.accuracy(trial) = 0;
                end

            elseif keyCode(rightKey)
                response = 2;
                selectedRect = rightRect;
                xReward = xRewardRight;
                reward = rewards(2);

                % was the choice correct?
                if data.reward_left(trial) <= data.reward_right(trial)
                    data.accuracy(trial) = 1;
                else
                    data.accuracy(trial) = 0;
                end
            end
        end
    end

    if response > 0
        % Draw Gabors again
        Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tilts(1), [], [], [], [],...
            kPsychDontDoRotation, [phase+180, freq, sc, contrasts(1), aspectratio, 0, 0, 0]);
        Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tilts(2), [], [], [], [],...
            kPsychDontDoRotation, [phase+180, freq, sc, contrasts(2), aspectratio, 0, 0, 0]);

        % Draw reward
        DrawFormattedText(wPtr, int2str(reward), xReward, yReward);

        % Draw a frame around the selected Gabor
        frameRect = selectedRect + [-frameSize, -frameSize, frameSize, frameSize];
        Screen('FrameRect', wPtr, frameColor, frameRect, frameSize);

        Screen('Flip', wPtr);

        % Record feedback timing
        data.feedback_onset(trial) = GetSecs - t0;

        if eyeTracking
            evt = Eyelink('newestfloatsample');
            data.feedback_onset_et(trial) = evt.time - et0;
        end

    elseif response == 0
        % NO RESPONSE
        response = -999;
        reward = 0;

        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, 'TOO LATE', 'center', 'center');
        Screen('Flip', wPtr);
    end

    WaitSecs(timeFeedback);


    % Draw the fixation cross during the inter-trial interval
    Screen('FillRect', wPtr, black);
    DrawFormattedText(wPtr, '+', 'center', 'center');
    Screen('Flip', wPtr);

    if eyeTracking
        evt = Eyelink('newestfloatsample');
        data.ITI_onset_et(trial) = evt.time - et0;
    end


    % Record the response and payoff
    fprintf('Trial %d: %d\n', trial, response);

    data.choice(trial) = response;
    data.payoff(trial) = reward;

    % Save data
    save(['data/mat/data_' int2str(sessID) '.mat'],'data');

    % Wait for a short inter-trial interval

    if eyeTracking
        %the following section gets eye position data from the eye
        %tracker and makes the subject stare at the cross for timeITI
        timeonfix = 0;
        fixstart = GetSecs;
        while timeonfix < timeITI
            evt = Eyelink('NewestFloatSample');
            % mx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array (Why?)
            % my = evt.gy(eye_used+1);
            mx = evt.gx(1); % +1 as we're accessing MATLAB array (Why?)
            my = evt.gy(1);

            if mx<0.4*rect(3) || mx>0.6*rect(3) || my<0.35*rect(4) || my>0.65*rect(4)
                fixstart = GetSecs;
            end

            timeonfix=GetSecs-fixstart;

        end
    else
        WaitSecs(timeITI);
    end


    % end of block
    % write end run in eye tracker + stop recording

    if data.btrial(trial) == 256

        Screen('FillRect', wPtr, black);
        DrawFormattedText(wPtr, 'The block is over. Transferring data...', 'center', 'center');
        Screen('Flip', wPtr);

        if eyeTracking
            Eyelink('stoprecording');
            Eyelink('closefile');
            status = Eyelink('receivefile',etfilename);

            % move eye tracker file to the right location (/data/edf/)
            copyfile(etfilename,['data/edf/' etfilename]);
            delete(etfilename);
        end
    end


end

if eyeTracking
    Eyelink('shutdown');
end

writetable(data,['data/csv/data_' int2str(sessID) '.csv']);

% Final screen
Screen('FillRect', wPtr, black);

payment = round(sum(data.payoff)/convertionRate);
DrawFormattedText(wPtr,['This is the end of the experiment.' '\n\n' ' Your total bonus in points is ' num2str(sum(data.payoff)) '.'...
    '\n\n' 'Your bonus payment is in pounds is ' num2str(payment) '.' ...
    '\n\n' 'Your total payment is ' num2str(payment + showupFee) '.'],...
    'center','center');
Screen('Flip',wPtr);
WaitSecs(15);
KbWait;



% Close the screen and clear the workspace
sca;