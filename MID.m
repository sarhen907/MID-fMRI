function MID(isscan, record_id)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI Monetary Incentive Delay (MID) Task. 

% Author: Sarah Hennessy, 2018

% Modeled after the MID task from the ABCD study, which was modeled after
% (Knutson, 2000)


% Each trial consisted of four events:

% 1.First, subjects are presented with an incentive cue (2000 ms) of five
% possible values (gain of $0.20, $5.00; loss of $0.20, $5.00; or no change
% $0). All participants begin with $1.
% 
% 2. This is followed by a 2000 ms anticipation delay (fixation cross).
% 
% 3. Next, a target appears. Initial target wait time is determined by
% performance in practice round (10 trials) outside of scanner (2 of each cue type). During
% experiment, target appears for a for a variable length of time
% dynamically manipulated and individually based such that overall success
% rate is approximately 60% during which subjects make a button press
% response in an attempt to gain or avoid losing the money. Subjects are
% instructed to respond to neutral targets despite the lack of incentive
% value.
% 
% 4. A feedback message informs them of the trial outcome.
% 
% The incentive trial is presented contiguously in a random order, with
% equal probability for each type of cue.
% 
% Reaction times (RT) and hit rates will be collected for each trial type
% to examine effects of reward-related and loss-avoidant speeding of RTs.
% Hit rates will be used to confirm experimental manipulation to maintain
% approximately 60% success.
% 
% Two runs of the task will be performed, each lasting 5 minutes for a
% total of twenty trials per condition (100 total trials,10 minutes).


% For a complete task design/ pictures please contact Sarah or Priscilla or
% go to the Server > School Study > Tasks > Task Designs > fMRI.doc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ADDITIONAL NOTES TO ADMINISTRATOR:
% 1. participants should be informed that it is real money and they will
% collect whatever they earn 
% 2. participants should be informed that the time changes on the target
% and thus PRESS AS FAST AS POSSIBLE for optimal outcomes
% 3. participants should be informed to try their best to press for neutral
% trials too, even though they won't gain or lose money.
%4. THE PRACTICE RUN MUST BE DONE BEFORE THE EXPERIMENT, in order to
%retrieve personalized timing files. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
record_id = input('Enter subject name: ', 's');
donepractice = input('\n STOP! have you run the practice trials with this participant?? (y/n):  ','s');
if donepractice == 'y'
    fprintf('\n please make sure that your subject names match, before beginning.\n\n');
else
    fprintf('\n please run the practice round by entering ''0'' in the next prompt. \n\n');
end

isscan = input('practice = 0, run = 1:2 : ');

Screen('Preference', 'SkipSyncTests', 1);
global thePath; rand('state',sum(100*clock));


% Add this at top of new scripts for maximum portability due to unified
% names on all systems:
KbName('UnifyKeyNames');


%set up paths
thePath.start = pwd;                                % starting directory
thePath.data = fullfile(thePath.start, 'data');     % path to Data directory
thePath.scripts = fullfile(thePath.start, 'scripts');
thePath.stims = fullfile(thePath.start, 'stimuli');

addpath(thePath.scripts)
addpath(thePath.stims)

[keyIsDown, keyTime] = KbCheck(-1);


%Set up variables
timedout = false;
rt = 0;
rtvector = [];
accvector = [];
keypressed = 0;
corrString = [];
text_feedback = [];
cue_name = [];
exp_message = [];

%text preferences
text_size = 40;

%SHUFFLE ORDERS

rng('default')
rng('shuffle')

%LOAD IN STIM ORDERS 
if isscan == 0
    orderfile = sprintf([pwd '/stimorderspractice.txt']);
else
    orderfile = sprintf([pwd '/stimorders.txt']);
end

format = '%d';
%label the dif orders 
[A] = textread(orderfile, format);
%choose the correct order letter

orderlist = Shuffle(A);

%LOAD IN ITI ORDERS
if isscan == 0
    itifile = sprintf([pwd '/ititimeorderspractice.txt']);
else
    itifile = sprintf([pwd '/ititimeorders.txt']);
end

format1 = '%.1f';
[Ax] = textread(itifile, format1);

itiorder = Shuffle(Ax);


%Set up log files
if isscan == 0
    %set up practice log
    practicelogfilename = sprintf('%s_practice_MID_run%d.txt',record_id, isscan); %creates or appends information to log file
    fprintf('Opening practice logfile: %s\n',practicelogfilename); %prints string to screen, '%s' is the string identifier ('logfilename')
    practicelogfile = fopen([pwd '/data/practice/', practicelogfilename],'a');
    fprintf (practicelogfile, 'trial \t record_id \t trial_onset \t trial_length \t stim_onset \t stim_length \t fix_onset \t fix_length \t target_onset \t target_length \t fix2_onset \t fix2_length \t fb_onset \t fb_length \t condition\t accuracy \t rt \t earned\t level\n');
    
    %target set log (to draw for experiment target_wait time)
    targetwaitsetname = sprintf('%s_targetwaitset%d.txt',record_id,isscan); %creates target wait set file to put avg reactiontime in
    fprintf('opening target wait file: %s\n', targetwaitsetname);
    targetwaitset = fopen([pwd '/data/targetwait/', targetwaitsetname],'a');
  
else
    findperf = sprintf('%s_targetwaitset%d.txt',record_id,0);
    logfilename = sprintf('%s_MID_run%d.txt',record_id, isscan); %creates or appends information to log file
    fprintf('Opening experiment logfile: %s\n',logfilename); %prints string to screen, '%s' is the string identifier ('logfilename')
    logfile = fopen([pwd '/data/', logfilename],'a');
    fprintf (logfile, 'trial \t record_id \t trial_onset \t trial_length \t stim_onset \t stim_length \t fix_onset \t fix_length \t target_onset \t target_length \t fix2_onset \t fix2_length \t fb_onset \t fb_length \t condition\t accuracy \t rt \t earned\t level\n');
end

%SET TARGET WAIT DURATION
if isscan == 0
   %starting targetwait
    target_wait = 0.325;
else
     %set target wait to the performance from the practice round
    target_wait = textread([pwd '/data/targetwait/', findperf],'%.8f');
end



%Define feedback duration
fb_dur = 2 - target_wait;

Screen('CloseAll')

timeStart = []; %trial starts 

%%%SET UP SCREEN PARAMETERS
screens = Screen('Screens');

screenNumber = max(screens); 
HideCursor;
[Screen_X, Screen_Y]=Screen('WindowSize',0);

% USE THESE LINES FOR SET SCREEN
%screenRect = [0 0 1024 768];
%[Window, Rect] = Screen('OpenWindow', screenNumber, 0, [0 0 1024 768]);%, screenRect);
[Window, Rect] = Screen('OpenWindow', screenNumber);%, screenRect);

Screen('TextSize',Window,text_size);
Screen('FillRect', Window, 0);  % 0 = black background

% LOAD STIMULI
fprintf('\n loading stimuli...')

win_high_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'Winhigh'), 'png'));
win_low_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'WinLow'), 'png'));
lose_high_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'LoseHigh'), 'png'));
lose_low_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'LoseLow'), 'png'));
neutral_cue = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'Neutral'), 'png'));
win_target = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'WinTarget'), 'png'));
lose_target = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'LoseTarget'), 'png'));
neutral_target = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'NeutralTarget'), 'png'));
fix1 = Screen('MakeTexture', Window, imread(fullfile(thePath.stims,'fix1'), 'jpg'));

% INSTRUCTIONS
img = Screen ('MakeTexture', Window, imread ('stimuli/instruct1.png')); %read the image file for the instructions
Screen ('DrawTexture', Window, img); %write to buffer
fprintf('\nPress any key to continue');
Screen(Window, 'Flip'); %plot on screen

KbWait(-1);

WaitSecs(0.5);
img = Screen ('MakeTexture', Window, imread ('stimuli/instruct2.png')); %read the image file for the instructions
Screen ('DrawTexture', Window, img); %write to buffer
fprintf('\nPress any key to continue');
Screen(Window, 'Flip'); %plot on screen
KbWait(-1);
WaitSecs(0.5);

img = Screen ('MakeTexture', Window, imread ('stimuli/instruct3.png')); %read the image file for the instructions
Screen ('DrawTexture', Window, img); %write to buffer
fprintf('\nPress any key to continue');
Screen(Window, 'Flip'); %plot on screen
KbWait(-1);
WaitSecs(0.5);

img = Screen ('MakeTexture', Window, imread ('stimuli/instruct3a.png')); %read the image file for the instructions
Screen ('DrawTexture', Window, img); %write to buffer
fprintf('\nPress any key to continue');
Screen(Window, 'Flip'); %plot on screen
KbWait(-1);
WaitSecs(0.5);

img = Screen ('MakeTexture', Window, imread ('stimuli/instruct4.png')); %read the image file for the instructions
Screen ('DrawTexture', Window, img); %write to buffer
fprintf('\nPress any key to continue to trigger screen');
Screen(Window, 'Flip'); %plot on screen
KbWait(-1);
WaitSecs(0.5);

%WAIT FOR SCANNER to send trigger (5)
fprintf('\nwaiting for scanner trigger...\n');

DrawFormattedText(Window, 'Get Ready!', 'center', 'center', 255);
Screen('Flip', Window);
doneCode=KbName('6^');
%doneCode=KbName('5%'); 
    
    while 1
        [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
        if keyIsDown  
            index=find(keyCode);
            if (index==doneCode)
                timeStart = timeSecs; % Record start time 
                break;   
            end
        end
    end                           


%draw fixation
Screen('DrawTexture', Window, fix1);
Screen('Flip', Window);
WaitSecs(5);

%set variables
accuracy = []; %beginning accuracy
earned = 1; %beginning earnings
cuetype = []; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
DisableKeysForKbCheck(doneCode);
%BEGIN LOOPTY
for t = 1:length(orderlist)
keypressed = 0;

trialonset = GetSecs-timeStart;

fprintf('\nyou are on trial: %d', t);
 %MORE ORDER SETUP 
%Teach it what each number means in relationship to the images  

    
    if orderlist((t)) == 1
        Screen('DrawTexture',Window, win_high_cue);
        target = win_target;
        cuetype = 1;
        cuename = 'win_high';
        condition = 'win';
        size = 'large';

    elseif orderlist((t)) == 2
        Screen('DrawTexture',Window, win_low_cue);
        target = win_target;
        cuetype = 2;
        cuename = 'win_low';
        condition = 'win';
        size = 'small';

    elseif orderlist((t)) == 3
        Screen('DrawTexture',Window, lose_high_cue); 
        target = lose_target;
        cuetype = 3;
        cuename = 'lose_high';
        condition = 'lose';
        size = 'large';

    elseif orderlist ((t)) == 4
        Screen('DrawTexture',Window, lose_low_cue);
        target = lose_target;
        cuetype = 4;
        cuename = 'lose_low';
        condition = 'lose';
        size = 'small';

    elseif orderlist((t)) == 5
        Screen('DrawTexture',Window, neutral_cue);        
        target = neutral_target;
        cuetype = 5;
        cuename = 'neutral';
        condition = 'neutral';
        size = 'neutral';
    else
        fprintf('\nsomething went wrong\n');
    end


   
    Screen('Flip',Window);
    stimonset = GetSecs-timeStart;
    WaitSecs(2)
    stimoffset = GetSecs-timeStart;
    
    stimlength = stimoffset-stimonset;
    
   
    %Present fixation cross
    Screen('DrawTexture', Window, fix1);
    Screen('Flip', Window);
    fixonset = GetSecs-timeStart;
    WaitSecs(itiorder((t)));
    
    fixoffset = GetSecs-timeStart;
    fixlength = fixoffset-fixonset;
    
    %print cue
    fprintf('\n Cue presented: %s',cuename);
    
    
    %Present Target
    Screen('DrawTexture', Window, target);
    [vbl, timeStart2] = Screen('Flip', Window);
    targetonset = GetSecs-timeStart;
    
   

%WAIT FOR KEYPRESS OR FOR TIMEOUT
while 1
    if (GetSecs - timeStart2) > target_wait
        Screen('Flip', Window);
        targetoffset= GetSecs-timeStart;
        break;
    end
    
%     check if key is pressed
    [keyIsDown, keyTime, keyCode] = KbCheck(-1);
    if (keyIsDown)
        if find(keyCode) == KbName('1!') || find(keyCode) == KbName('2@') || find(keyCode) == KbName('3#') || find(keyCode) == KbName('4$')
            Screen('Flip', Window);
            targetoffset= GetSecs-timeStart;
            keypressed = 1;
            break; 
        end
    end
end

targetlength = targetoffset-targetonset;


%determine feedback for next screen
if keypressed == 1
    rt = (keyTime - timeStart2);
    accuracy = 1;
    if cuetype == 1
        text_feedback = 'You earned $5.00!';
        earned = earned + 5;
        
    elseif cuetype == 2
        text_feedback = 'You earned $0.20!';
        earned = earned + 0.20;
        
    elseif cuetype == 3
        text_feedback = 'You did not lose any money.';
        earned = earned;
        
    elseif cuetype == 4
        text_feedback = 'You did not lose any money.';
        earned = earned;
        
    elseif cuetype == 5
        earned = earned;
        text_feedback = 'You did not earn or lose any money.';
        
    end
elseif keypressed == 0
    accuracy =  0;
    if cuetype == 1
        text_feedback = 'You did not earn any money.';
        earned = earned;
        
    elseif cuetype == 2
        text_feedback = 'You did not earn any money.';
        earned = earned;
        
    elseif cuetype == 3
        text_feedback = 'You lost $5.00!';
        earned = earned - 5.00;
        
    elseif cuetype == 4
        text_feedback = 'You lost $0.20!';
        earned = earned - 0.20;
    elseif cuetype == 5
        earned = earned;
        text_feedback = 'You did not earn or lose any money.';
    end
    
end
    
    
%For printing whether subject answered correctly in the command window
if accuracy == 1
    corrString = 'correctly';
elseif accuracy == 0
    corrString = 'incorrectly';
end

%print response
fprintf('\n Participant responded: %s \n', corrString);

%draw actual feedback
DrawFormattedText(Window, text_feedback, 'center', 'center', 255);
Screen('Flip', Window);

fbonset = GetSecs- timeStart;
WaitSecs(fb_dur);

fboffset = GetSecs- timeStart;
fblength = fboffset-fbonset;


%add fixation cross to make up for time gained in early presses
if keypressed == 1
    Screen('DrawTexture',Window,fix1);
    Screen('Flip',Window);
    WaitSecs(target_wait-rt);
    fix2onset =  GetSecs- timeStart;
else
    %Present fixation
    Screen('DrawTexture', Window, fix1);
    Screen('Flip', Window);
    fix2onset =  GetSecs- timeStart;
end



% WaitSecs(itiorder((t)));

fix2offset =  GetSecs- timeStart;

tellme = fix2offset-targetonset;
fprintf('tell me time: %d', tellme);

fix2length = fix2offset-fix2onset; 

trialoffset =  GetSecs- timeStart;
triallength = trialoffset-trialonset;
 
%Calculate average (every 3 trials should change the target wait based on
%the subject's performance, starting with the first 6 trials) 
accvector = [accvector, accuracy];
avgaccuracy = mean(accvector); 
if t > 3
    if mod(t-2,3) == 1
        if avgaccuracy < 0.6
            target_wait = target_wait + 0.05;
            exp_message = 'target wait adjusted + .5';
           
        elseif avgaccuracy > 0.6
            target_wait = target_wait - 0.05;
            
            exp_message = 'target wait adjusted - 0.5';
            
            if target_wait < 0.15
                target_wait = 0.15;
            elseif target_wait > 0.5
                target_wait = 0.5;
            end
            
           
        elseif avgaccuracy == 0.6
            target_wait = target_wait;
            exp_message = 'target wait not adjusted';
            
        end
        fprintf('\nThe current accuracy is: %0.4f', avgaccuracy);
        
        %Let experimenter know if you're changing stuff
        fprintf('\n%s', exp_message);
    end
end

%Cap the length of target wait
if target_wait > 0.5
    target_wait = 0.5;
end



%Write to Log File
if isscan == 0               
    fprintf(practicelogfile, '\n%d\t%s\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%s\t%d\t%.8f\t%.2f\t%s\t',t,record_id, trialonset, triallength, stimonset, stimlength, fixonset, fixlength, targetonset,targetlength, fix2onset, fix2length, fbonset, fblength,condition, accuracy, rt, earned, size);
else
    fprintf(logfile, '\n%d\t%s\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%.8f\t%s\t%d\t%.8f\t%.2f\t%s\t',t,record_id, trialonset, triallength, stimonset, stimlength, fixonset, fixlength, targetonset,targetlength, fix2onset, fix2length,fbonset, fblength,condition, accuracy, rt, earned, size);
end

%Save all acc & RTs to vectors
if accuracy == 1
    rtvector = [rtvector, rt];
end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Write Wait Set info to Log File
%calculate mean and st of rts to use for target wait set
rtaverage = mean(rtvector);
rtsd = std(rtvector);

meanaccuracy = mean(accvector);

%calculate target wait (from practice FOR experiment)
performance = rtaverage + (2*rtsd);

%if it is the practice scan, add performance value to a txt file
if isscan == 0
    fprintf(targetwaitset, '\n%.8f',performance);
end

WaitSecs(2);

%PRINT earned + accuracy

fprintf('\n Total money earned: %.2f',earned);
fprintf('\n Average Accuracy: %.4f\n', meanaccuracy);
fprintf('\n Average RT on correct trials: %.8f\n', rtaverage);

%PRINT TOTAL MONEY EARNED
%participants always are told they ended up with 1 dollar minimum 

if earned < 1
    printedearned = 1;
else
    printedearned = earned;
end


DrawFormattedText(Window, sprintf( 'Great Job! You have earned:$%.2f',printedearned),'center', 0.5*Rect(4), 255);
DrawFormattedText(Window, 'This concludes the game', 'center', 0.8*Rect(4), 255);
Screen('Flip', Window);
WaitSecs(5);
Screen('Close All');

toc;
totaltime = toc/60;
fprintf('\n total time for this run was: %d minutes',totaltime);
sca;