%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSYCHOMETRIC CURVE CALIBRATION FOR CONTRAST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% data = CreatePsychometric(sMean,sStep); 
% numTrials = size(data,1);
% 
% for trial = 1:numTrials
% 
%     % BLOCK START INFORMATION SCREEN
%     if data.trial(trial) == 1
% 
%         % calibrate the eye tracker
%         if eyeTracking
%             et.calibrate();
%             et.openFile(['sv' num2str(round(sessID/100000)) '_' num2str(data.block(trial)) '.edf']);
%             et.startRecording();
%             et.setRecordingMessage(sprintf('Salience study subj %d run %d', sessID, data.block(trial))); % displays a message on the eyetracker recording screen
%         end
% 
%         % GET READY screen
%         Screen('FillRect', wPtr, black);
%         DrawFormattedText(wPtr, 'Get ready.', 'center', 'center');
%         Screen('Flip', wPtr);
%         WaitSecs(2);
% 
%         % Draw the fixation before the trials start
%         Screen('FillRect', wPtr, black);
%         DrawFormattedText(wPtr, '+', 'center', 'center');
%         Screen('Flip', wPtr);
%         WaitSecs(timeITI);
% 
%         %record block starting time
%         t0 = GetSecs;
% 
%     end
% 
% 
%     tilts = [0 0];
%     contrasts = [data.contrast_left(trial) data.contrast_right(trial)];
% 
%     % Build a procedural gabor texture for a gabor with a support of
%     % gaborSize x gaborSize pixels, and a RGB color offset of 0 (black background)
%     gabortex = CreateProceduralGabor(wPtr, gaborSize, gaborSize, 0, [0 0 0 0.0]);
% 
%     % Draw the stimuli
%     Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tilts(1), [], [], [], [],...
%          kPsychDontDoRotation, [phase+180, freq, sc, contrasts(1), aspectratio, 0, 0, 0]);
% 
%     Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tilts(2), [], [], [], [],...
%          kPsychDontDoRotation, [phase+180, freq, sc, contrasts(2), aspectratio, 0, 0, 0]);
%     Screen('Flip', wPtr);
% 
%     % record stimuli onset time
%     data.onset(trial) = GetSecs - t0;
% 
%     % Wait for a response
%     response = 0;
%     timer = 0;
%     while ~response && timer < maxRTC
%         [keyIsDown, secs, keyCode] = KbCheck;
%         timer = GetSecs -  data.onset(trial) - t0;
% 
%         if keyIsDown
% 
%             % record response time 
%             data.rt(trial) = GetSecs - data.onset(trial) - t0;
%             data.response(trial) = GetSecs - t0;
% 
%             if keyCode(leftKey)
%                 response = 1;
%                 selectedRect = leftRect;
% 
% 
%                 % was the choice correct?
%                 if data.contrast_left(trial) >= data.contrast_right(trial)
%                     data.accuracy(trial) = 1;
%                     reward = 1;
%                     frameColorTrial = frameColorCorrect;
%                 else 
%                     data.accuracy(trial) = 0;
%                     reward = 0;
%                     frameColorTrial = frameColorWrong;
%                 end
% 
%             elseif keyCode(rightKey)
%                 response = 2;
%                 selectedRect = rightRect;
%                 xReward = xRewardRight;
% 
%                 % was the choice correct?
%                  if data.contrast_left(trial) <= data.contrast_right(trial)
%                     data.accuracy(trial) = 1;
%                     reward = 1;
%                     frameColorTrial = frameColorCorrect;
%                 else 
%                     data.accuracy(trial) = 0;
%                     reward = 0;
%                     frameColorTrial = frameColorWrong;
%                 end
%             end
%         end
%     end
% 
%     if response > 0
%         % Draw Gabors again
%         Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tilts(1), [], [], [], [],...
%              kPsychDontDoRotation, [phase+180, freq, sc, contrasts(1), aspectratio, 0, 0, 0]);
%         Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tilts(2), [], [], [], [],...
%              kPsychDontDoRotation, [phase+180, freq, sc, contrasts(2), aspectratio, 0, 0, 0]);
% 
%         % Draw a frame around the selected Gabor
%         frameRect = selectedRect + [-frameSize, -frameSize, frameSize, frameSize];
%         Screen('FrameRect', wPtr, frameColorTrial, frameRect, frameSize);
% 
%         Screen('Flip', wPtr);
% 
%         % Record feedback timing
%         data.feedback_onset(trial) = GetSecs - t0;
% 
%     elseif response == 0
%         % NO RESPONSE
%         response = -999;
%         reward = 0;
% 
%         Screen('FillRect', wPtr, black);
%         DrawFormattedText(wPtr, 'TOO LATE', 'center', 'center');
%         Screen('Flip', wPtr);
%     end
% 
%     WaitSecs(timeFeedback);
% 
% 
%     % Draw the fixation cross during the inter-trial interval
%     Screen('FillRect', wPtr, black);
%     DrawFormattedText(wPtr, '+', 'center', 'center');
%     Screen('Flip', wPtr);
% 
%     % Record the response and payoff
%     fprintf('Trial %d: %d\n', trial, response);
% 
%     data.choice(trial) = response;
%     data.payoff(trial) = reward;
% 
%     % Save data
%     save(['pmdata/mat/data_' int2str(sessID) '.mat'],'data');
% 
%     % Wait for a short inter-trial interval
% 
%     if eyeTracking 
%         %the following section gets eyeposition data from the eye
%         %tracker and makes the subject stare at the cross for timeITI
%         timeonfix = 0;
%         fixstart = GetSecs;
%         while timeonfix < timeITI
%             evt = Eyelink('NewestFloatSample');
%             mx = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array (Why?)
%             my = evt.gy(eye_used+1);
% 
%             if mx<0.4*rect(3) || mx>0.6*rect(3) || my<0.35*rect(4) || my>0.65*rect(4)
%                 fixstart = GetSecs;
%             end
% 
%             timeonfix=GetSecs-fixstart;
% 
%         end
%     else
%         WaitSecs(timeITI);
%     end
% 
% 
%     % end of block
%     % write end run in eye tracker + close eye tracker
%     if data.trial(trial) == 64
%         if eyeTracking
%             et.stopRecording();
%             et.closeFile();
%             et.receiveFile();
%             % move eye tracker file to right location
% 
%         end
%     end
% end
% 
% writetable(data,['pmdata/csv/data_' int2str(sessID) '.csv']);

% sca;
