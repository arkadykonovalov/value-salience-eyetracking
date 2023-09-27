function SalienceTutorial(wPtr,rect, tiltsSet,contrastsSet, condition,convertionRate)
% This function runs the tutorial for the SALIENCE-VALUE EXPERIMENT
    
    % waiting time
    waitTime = 1;

    % Set up the keyboard
    KbName('UnifyKeyNames');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');

    % Initial stimulus params for the gabor patch:
    gaborSize = 323;
    res = 1*[gaborSize gaborSize]; % size 
    phase = 0;  % the phase of the gabors sine grating in degrees.
    sc = 50.0; % the spatial constant of the gaussian hull function of the gabor, ie.  the "sigma" value in the exponential function.
    freq = .1; % its spatial frequency in cycles per pixel.
    aspectratio = 1.0;  % aspect ratio
    gabortex = CreateProceduralGabor(wPtr, gaborSize, gaborSize, 0, [0 0 0 0.0]);
    
    leftRect = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)/4, rect(4)/2);
    rightRect = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*3/4, rect(4)/2);
    
    infoRect1 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)/5, rect(4)/2);
    infoRect2 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*2/5, rect(4)/2);
    infoRect3 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*3/5, rect(4)/2);
    infoRect4 = CenterRectOnPoint([0, 0, res(1), res(2)], rect(3)*4/5, rect(4)/2);

    % Set up the frame size and color
    frameSize = 5;  % in pixels
    frameColor = [1, 1, 1];

    Screen('TextSize', wPtr, 30);

    % screen 1
    DrawFormattedText(wPtr,['Press any key to start the tutorial for the experiment,' '\n\n' 'and to continue from page to page.'],...
        'center','center');
    Screen('Flip',wPtr);
    WaitSecs(waitTime);
    KbWait([],2);
      
    % screen 2
    DrawFormattedText(wPtr,['Please read the instructions carefully.' '\n\n' ' You will not be able to return to previous screens.'],...
        'center','center');
    Screen('Flip',wPtr);
    WaitSecs(waitTime);
    KbWait([],2);

    % screen 3
    DrawFormattedText(wPtr,['Today your task will be simple.' '\n\n' ' In each trial, you need to choose between two patches:'],...
        'center',rect(4)*1.5/6);

    Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tiltsSet(1), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);

    Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);

    Screen('Flip',wPtr);
    WaitSecs(waitTime);
    KbWait([],2);

     % screen 2
    DrawFormattedText(wPtr,['To do this, you just need to press left or right arrow key.' '\n\n' ' Try this now.'],...
        'center',rect(4)*1.5/6);

    Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tiltsSet(1), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);

    Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);

    Screen('Flip',wPtr);
    WaitSecs(waitTime);

    %Wait for a response
    response = 0;

    while ~response
        [keyIsDown, secs, keyCode] = KbCheck;
       
        if keyIsDown
           if keyCode(leftKey)
                response = 1;
                selectedRect = leftRect;
               
            elseif keyCode(rightKey)
                response = 2;
                selectedRect = rightRect;
                
            end
        end
    end

    % Draw Gabors again
    Screen('DrawTexture', wPtr, gabortex, [], leftRect, 90+tiltsSet(1), [], [], [], [],...
        kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);
    Screen('DrawTexture', wPtr, gabortex, [], rightRect, 90+tiltsSet(2), [], [], [], [],...
        kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);

    % Draw a frame around the selected Gabor
    frameRect = selectedRect + [-frameSize, -frameSize, frameSize, frameSize];
    Screen('FrameRect', wPtr, frameColor, frameRect, frameSize);

    Screen('Flip', wPtr);

    WaitSecs(3*waitTime);

    % screen 4
     DrawFormattedText(wPtr,['How to determine which patch to choose?' '\n\n' ' First, the patches can have 4 slightly different possible orientations as shown below (look carefully):'],...
        'center',rect(4)*1.5/6);

     Screen('DrawTexture', wPtr, gabortex, [], infoRect1, 90+tiltsSet(4), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
     Screen('DrawTexture', wPtr, gabortex, [], infoRect2, 90+tiltsSet(3), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
     Screen('DrawTexture', wPtr, gabortex, [], infoRect3, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
     Screen('DrawTexture', wPtr, gabortex, [], infoRect4, 90+tiltsSet(1), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);

     Screen('Flip',wPtr);

     % % take a screenshot
     % current_display = Screen('GetImage',wPtr);
     % imwrite(current_display, 'screenshot1.png');

     WaitSecs(waitTime);
     KbWait([],2);

      % screen 5
     DrawFormattedText(wPtr,['Second, they can have 4 possible slightly different brightness levels,' '\n\n' 'from dark to bright as shown below (look carefully):'],...
        'center',rect(4)*1.5/6);

     Screen('DrawTexture', wPtr, gabortex, [], infoRect1, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(1), aspectratio, 0, 0, 0]);
     Screen('DrawTexture', wPtr, gabortex, [], infoRect2, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(2), aspectratio, 0, 0, 0]);
     Screen('DrawTexture', wPtr, gabortex, [], infoRect3, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(3), aspectratio, 0, 0, 0]);
     Screen('DrawTexture', wPtr, gabortex, [], infoRect4, 90+tiltsSet(2), [], [], [], [],...
         kPsychDontDoRotation, [phase+180, freq, sc, contrastsSet(4), aspectratio, 0, 0, 0]);

     Screen('Flip',wPtr);
    
     % % take a screenshot
     % current_display = Screen('GetImage',wPtr);
     % imwrite(current_display, 'screenshot2.png');

     WaitSecs(waitTime);
     KbWait([],2);

     % screen 6

     if condition == 1

         DrawFormattedText(wPtr,['Each patch can be worth 1, 2, 3, or 4 points,'...
             '\n\n' 'You will play 4 blocks of trials, and in each block the values of the patches'...
             '\n\n' 'will depend on either orientation or brightness.'],...
             'center','center');

     elseif condition == 2

         DrawFormattedText(wPtr,['Each patch can be worth 0 or 1 points.'...
             '\n\n' 'You will play 4 blocks of trials, and in each block the values of the patches'...
             '\n\n' 'will depend on either orientation or brightness.'],...
             'center','center');

     end

     Screen('Flip',wPtr);
     WaitSecs(waitTime);
     KbWait([],2);


     DrawFormattedText(wPtr,[ 'In one block, brighter patches will be more valuable.'...
         '\n\n' 'In another block, darker patches will be more valuable.'...
         '\n\n' 'In the other two blocks, the value will depend only on the orientation.'...
         '\n\n' 'Before each block, you will be explicitly told which patches are more valuable.'], ...
     'center','center');
     Screen('Flip',wPtr);
     WaitSecs(waitTime);
     KbWait([],2);

    % screen 6
    DrawFormattedText(wPtr,['Each block will last about 10-15 minutes.'...
        '\n\n' 'In each trial, you must respond within 2 seconds, or you will receive no points.'...
        '\n\n' 'When you choose a patch, you will immediately see how many points you got.'...
        '\n\n' 'At the end of the experiment, the sum of your points will be converted to your money bonus,'....
        '\n\n' 'with ' num2str(convertionRate) ' points = 1 extra pound.'...
        '\n\n' 'If you have any questions, ask the experimenter now.'...
        '\n\n' 'Good luck!'],...
        'center','center');
    Screen('Flip',wPtr);
    WaitSecs(waitTime);
    KbWait([],2);
end