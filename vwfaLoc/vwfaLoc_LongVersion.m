function vwfaLoc_LongVersion(SUBJ_ID,NUM,RUN,varargin)

%% VWFA Localizer with Colors

%{

    The first number input should be the order (in time) that you are 
    running the experiment. It'll always go from 1 - 6. The second number 
    is the counterbalance number which can be anything.
 
 by Terri Scott
 5/26/14

 Ex. call:
 vwfaLoc_multiColor('SubjectA',1,6)
 or
 vwfaLoc_multiColor('SubjectA',1,6,'practice')

 Current runs last 560 seconds , or 172 TRs
 Practice run takes ~40s.


**** 11/29/2017 -- trigger is set as "5/%" for MRI *****
**** response keys set as "1", "2", or "3" *******


 How to run:
 vwfaLoc_multiColor(<SUBJ_ID can be any string>,<RUN should be 1 through 6
 in order>,<OPTIONAL: 'practice'>)

 You can press ESC to quit the script at any time. If you quit, the data
 will be saved but with an '_earlyEsc.csv'. 

 Script will throw an error if you try to run the same run twice, unless
 that run was escaped by the experimenter or if the script crashed.

 This is a VWFA localizer with 4 conditions: gridded words, scrambled
 gridded words, gridded object line drawings, and gridding line drawings of
 faces. Each stimulus gets a different, randomized, non-repeating
 background color.

 The task here is a one-back detection task. If the subject presses the
 response key any time during a repeat trial or the trial immediately
 after, the response will be counted as accurate and the RT is recorded. If
 the response key is pressed but the trial is not a repeat, the response
 time is also calculated but not included in the mean RT for the trial or 
 condition. Accuracies computed only take into account the number of 
 correct repeat detections, they do not look at false positives.

 Conditions are numbered 1:Word, 2:ScrambledWord, 3:LineDrawing, and
 4:Faces.

***** Also addedletters, jumbled nonwords, and false fonts ******

 Freesurfer style para files are created on all non-practice runs. If you
 re-run a run, the para file for that run will be overwritten.

%}

% 6/23/14 MAJOR EDIT!!! - TS
% The script will now take two numeric arguments, the first will be the run
% number (always in order from 1 to 6, and the second is the counterbalance
% order.

%% for testing

% SUBJ_ID = 'test';
% RUN = 1;

%% Optional practice run

practice = 0;

if strcmp('practice',varargin),
    practice = 1;
end

%% Initialize Variables

DATA_DIR = [pwd '/data_LongVersion'];
STIM_DIR = [pwd '/stimuli'];
SCREEN_NUM = max(Screen('Screens'));
FONT_SIZE = 100;
IMAGE_FORMAT = 'png';
IMAGES_PER_BLOCK = 24;
NUM_BLOCKS = 28; % If you change this you should change cb too. add 4 everytime a stimuli is added
if practice
    IMAGES_PER_BLOCK = 4;
    NUM_BLOCKS = 8; % If you change this you should change cb too.  
end
cb = [1,2,3,4,5,6,7,7,6,5,4,3,2,1,2,7,4,3,6,1,1,3,7,5,4,6,2,5]; 
if practice
    cb = [1,2,3,4,5,6,7,7,6,5,4,3,2,1];
end

REPEATS = 2;
if practice
    REPEATS = 1;
end

% Fixation cross setup
fixCrossDimPix = 20;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 2;

% Subject data file
file_to_save = ['vwfaLoc_' SUBJ_ID '_run' num2str(NUM) '_data.csv'];
if practice
    file_to_save = ['vwfaLoc_' SUBJ_ID '_run' num2str(NUM) '_practice.csv'];
end

% Key setup
KbName('UnifyKeyNames');
RESPONSE_KEYS = [KbName('1!'),KbName('1'),KbName('2@'),KbName('2'),KbName('3#'),KbName('3')];
TRIGGER_KEY1 = KbName('5%');
TRIGGER_KEY2 = KbName('+');
TRIGGER_KEY3 = KbName('=');
ESCAPE_KEY = KbName('ESCAPE');

% Durations
dur.stim = 0.500;
dur.fix_t = 0.1923;
dur.big_fix_t = dur.stim + dur.fix_t;
dur.breakScreen = 1.500;
dur.blockTime = 18;

% Colors
% bgColors = [0.886, 0.702, 0.706 ;
%             0.800, 0.765, 0.565 ;
%             0.659, 0.824, 0.451 ;
%             0.451, 0.851, 0.576 ;
%             0.459, 0.847, 0.741 ;
%             0.655, 0.776, 0.804 ;
%             0.804, 0.702, 0.835 ;
%             0.894, 0.678, 0.812 ];

% bgColors = [226, 179, 180 ;
%             204, 195, 144 ;
%             168, 210, 115 ;
%             115, 217, 147 ;
%             117, 216, 189 ;
%             167, 198, 205 ;
%             205, 179, 213 ;
%             228, 173, 207 ];
        
% Darker Colors  
bgColors = [176, 129, 130 ;
            154, 145, 94  ;
            118, 160, 65  ;
            65,  167, 97  ;
            67,  166, 139 ;
            117, 148, 155 ;
            155, 129, 163 ;
            178, 123, 157 ];
        
% rng('shuffle'); % Initialize the random number generator (NEW VERSIONS OF MATLAB)
randn('state',sum(100.*clock)); % Initialize the random number generator (OLD VERSIONS OF MATLAB)
        
%% Some checks to perform - Comment out these error messages if you need to. 

% Error message if data file already exists.
if exist([DATA_DIR filesep file_to_save],'file');
    
    error('myfuns:vwfaLoc_multiColor:DataFileAlreadyExists', ...
        'The data file already exists for this subject!');
end        

%% Generate Stimulus Order - counterbalanced orders

orders = { ...
    {'word_pngs_grid','scr_word_pngs_grid','line_pngs_grid','face_pngs_grid','letter_pngs_grid','nonwords_pngs_grid','nonletters_pngs_grid'}
    {'scr_word_pngs_grid','line_pngs_grid','face_pngs_grid','letter_pngs_grid','nonwords_pngs_grid','nonletters_pngs_grid','word_pngs_grid'}
    {'line_pngs_grid','face_pngs_grid','letter_pngs_grid','nonwords_pngs_grid','nonletters_pngs_grid','word_pngs_grid','scr_word_pngs_grid'}
    {'face_pngs_grid','letter_pngs_grid','nonwords_pngs_grid','nonletters_pngs_grid','word_pngs_grid','scr_word_pngs_grid','line_pngs_grid'}
    {'letter_pngs_grid','nonwords_pngs_grid','nonletters_pngs_grid','word_pngs_grid','scr_word_pngs_grid','line_pngs_grid','face_pngs_grid'}
    {'nonwords_pngs_grid','nonletters_pngs_grid','word_pngs_grid','scr_word_pngs_grid','line_pngs_grid','face_pngs_grid','letter_pngs_grid'}
    };

order_codes = [ ...
    1,2,3,4,5,6,7;
    2,3,4,5,6,7,1;
    3,4,5,6,7,1,2;
    4,5,6,7,1,2,3;
    5,6,7,1,4,3,2;
    6,7,1,2,3,4,5;
    ];

% Write a para file.
if ~practice
    fid = fopen([DATA_DIR filesep num2str(NUM) SUBJ_ID '_scrambled_v3.para'],'w+');
    t = 0.0;
    fprintf(fid,'%.2d\t%i\t%i\n',t,0,dur.blockTime);
    t = dur.blockTime + t;
    for cbI = 1:length(cb)/2
        fprintf(fid,'%.2d\t%i\t%i\n',t,order_codes(RUN,cb(cbI)),dur.blockTime);
        t = dur.blockTime + t;
    end
    fprintf(fid,'%.2d\t%i\t%i\n',t,5,dur.stim+dur.breakScreen);
    t = t + dur.stim+dur.breakScreen;
    fprintf(fid,'%.2d\t%i\t%i\n',t,0,dur.blockTime);
    t = dur.blockTime + t;
    for cbI = (length(cb)/2)+1:length(cb)
        fprintf(fid,'%.2d\t%i\t%i\n',t,order_codes(RUN,cb(cbI)),dur.blockTime);
        t = dur.blockTime + t;
    end
    fprintf(fid,'%.2d\t%i\t%i\n',t,0,dur.blockTime);
    fclose(fid);
end

a_list = randomizeCondOrder(orders{RUN}{1});
b_list = randomizeCondOrder(orders{RUN}{2});
c_list = randomizeCondOrder(orders{RUN}{3});
d_list = randomizeCondOrder(orders{RUN}{4});
e_list = randomizeCondOrder(orders{RUN}{5});
f_list = randomizeCondOrder(orders{RUN}{6});
g_list = randomizeCondOrder(orders{RUN}{7});

imageList = {};
repetitions = [];
condition_list = {};

for idxBlock = 1:length(cb)
    if cb(idxBlock) == 1,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; a_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,1)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; a_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,1)}];
            end
        end
        imageList = [imageList ; blockImages];
        a_list = a_list(IMAGES_PER_BLOCK+1:end);
    elseif cb(idxBlock) == 2,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; b_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,2)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; b_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,2)}];
            end
        end
        imageList = [imageList ; blockImages];
        b_list = b_list(IMAGES_PER_BLOCK+1:end);
    elseif cb(idxBlock) == 3,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; c_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,3)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; c_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,3)}];
            end
        end
        imageList = [imageList ; blockImages]; 
        c_list = c_list(IMAGES_PER_BLOCK+1:end);
    elseif cb(idxBlock) == 4,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; d_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,4)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; d_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,4)}];
            end
        end
        imageList = [imageList ; blockImages];
        d_list = d_list(IMAGES_PER_BLOCK+1:end);
    elseif cb(idxBlock) == 5,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; e_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,5)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; e_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,5)}];
            end
        end
        imageList = [imageList ; blockImages];
        e_list = e_list(IMAGES_PER_BLOCK+1:end);
    elseif cb(idxBlock) == 6,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; f_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,6)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; f_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,6)}];
            end
        end
        imageList = [imageList ; blockImages];
        f_list = f_list(IMAGES_PER_BLOCK+1:end);
    elseif cb(idxBlock) == 7,
        reps = nonRepeatingRand(IMAGES_PER_BLOCK,REPEATS);
        blockImages = {};
        for idxImage = 1:IMAGES_PER_BLOCK
            blockImages = [blockImages ; g_list(idxImage)];
            repetitions = [repetitions,0];
            condition_list = [condition_list ; {order_codes(RUN,7)}];
            if ismember(idxImage,reps),
                blockImages = [blockImages ; g_list(idxImage)];
                repetitions = [repetitions,1];
                condition_list = [condition_list ; {order_codes(RUN,7)}];
            end
        end
        imageList = [imageList ; blockImages];
        g_list = g_list(IMAGES_PER_BLOCK+1:end);
    end
end

%% Generate stimulus order - timings and block types

STIMULUS_SET = {};
t = 0;

for idxStim = 1:(IMAGES_PER_BLOCK+REPEATS)
    fixation_stim = struct();
    t2 = t + dur.big_fix_t;
    fixation_stim.start_time = t;
    fixation_stim.end_time = t2;
    t = t2;
    fixation_stim.type = 'fixation';
    STIMULUS_SET{end+1} = fixation_stim;
end

for idxStim = 1:(IMAGES_PER_BLOCK+REPEATS)*NUM_BLOCKS/2
    image_stim = struct();
    t2 = t + dur.big_fix_t;
    image_stim.start_time = t;
    image_stim.end_time = t2;
    t = t2;
    image_stim.type = 'image';
    STIMULUS_SET{end+1} = image_stim;
end

break_stim = struct();
t2 = t + dur.stim;
break_stim.start_time = t;
break_stim.end_time = t2;
t = t2;
break_stim.type = 'break';
STIMULUS_SET{end+1} = break_stim;

breakText_stim = struct();
t2 = t + dur.breakScreen;
breakText_stim.start_time = t;
breakText_stim.end_time = t2;
t = t2;
breakText_stim.type = 'breakText';
STIMULUS_SET{end+1} = breakText_stim;

for idxStim = 1:(IMAGES_PER_BLOCK+REPEATS)
    fixation_stim = struct();
    t2 = t + dur.big_fix_t;
    fixation_stim.start_time = t;
    fixation_stim.end_time = t2;
    t = t2;
    fixation_stim.type = 'fixation';
    STIMULUS_SET{end+1} = fixation_stim;
end

for idxStim = 1:(IMAGES_PER_BLOCK+REPEATS)*NUM_BLOCKS/2
    image_stim = struct();
    t2 = t + dur.big_fix_t;
    image_stim.start_time = t;
    image_stim.end_time = t2;
    t = t2;
    image_stim.type = 'image';
    STIMULUS_SET{end+1} = image_stim;
end

for idxStim = 1:(IMAGES_PER_BLOCK+REPEATS)
    fixation_stim = struct();
    t2 = t + dur.big_fix_t;
    fixation_stim.start_time = t;
    fixation_stim.end_time = t2;
    t = t2;
    fixation_stim.type = 'fixation';
    STIMULUS_SET{end+1} = fixation_stim;
end

final_stim = struct();
t2 = t;
final_stim.start_time = t;
final_stim.end_time = t2;
final_stim.type = 'end run';
STIMULUS_SET{end+1} = final_stim;

NUM_STIMULI = length(STIMULUS_SET);

colorIdx = nonRepeatingRand(size(bgColors,1),(NUM_STIMULI));
cI = 1; % Initialize the color count

%% Initialize Data Recorder

subjData = cell(size(imageList,1)+1,9);
subjData(1,:) = {'Subject','Run','Condition','Filename','Onset','Repeat','Response','RT','Accuracy'};
subjData(2:end,1) = {SUBJ_ID};
subjData(2:end,2) = {RUN};
subjData(2:end,4) = imageList;
subjData(2:end,3) = condition_list;

subjData(2:end,7) = {0};
subjData(2:end,8) = {NaN};
subjData(2:end,9) = {0};

flipTime = zeros(size(imageList,1),1);
RT_raw = zeros(size(imageList,1),1);

%% Initialize Window

clear screen
[wPtr, rect] = Screen('OpenWindow',SCREEN_NUM,1);
W = rect(RectRight); % Screen width
H = rect(RectBottom); % Screen height
black = BlackIndex(SCREEN_NUM);

%% Load images

for idxImage = 1:length(imageList)
    img = imread([STIM_DIR filesep imageList{idxImage}]);
    imageDisplay(idxImage) = Screen('MakeTexture',wPtr,img);
    imageSize = size(img);
    pos(idxImage,:) = [(W-imageSize(2))/2 (H-imageSize(1))/2 (W+imageSize(2))/2 (H+imageSize(1))/2];
end

iI = 1; % Initialize image count

getReady_img = imread([STIM_DIR filesep 'Race_flags.jpg']);
halfWay_img = imread([STIM_DIR filesep 'half_circle.jpg']);
done_img = imread([STIM_DIR filesep 'thumbs_up.jpg']);

getReady_disp = Screen('MakeTexture',wPtr,getReady_img);
halfWay_disp = Screen('MakeTexture',wPtr,halfWay_img);
done_disp = Screen('MakeTexture',wPtr,done_img);

getReady_pos = [(W-size(getReady_img,2))/2 ((H-size(getReady_img,1))/2)+H/8 (W+size(getReady_img,2))/2 ((H+size(getReady_img,1))/2)+H/8];
halfWay_pos = [(W-size(halfWay_img,2))/2 ((H-size(halfWay_img,1))/2)+H/8 (W+size(halfWay_img,2))/2 ((H+size(halfWay_img,1))/2)+H/8];
done_pos = [(W-size(done_img,2))/2 ((H-size(done_img,1))/2)+H/8 (W+size(done_img,2))/2 ((H+size(done_img,1))/2)+H/8];


%% Go to Start Screen

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(rect);

Screen('FillRect',wPtr,bgColors(colorIdx(cI),:));
cI = cI + 1;
Screen(wPtr, 'Flip');

HideCursor;

Screen('TextSize', wPtr , FONT_SIZE);
Screen('DrawTexture', wPtr, getReady_disp, [], getReady_pos);
DrawFormattedText(wPtr,'Get Ready!','center',yCenter-H/8-FONT_SIZE/2);
Screen(wPtr, 'Flip');

%% Wait for trigger

while 1
    [keyIsDown, ~, keyCode] = KbCheck(-1);
    if keyIsDown
        response = find(keyCode);
        if response == ESCAPE_KEY,
            Screen('CloseAll');
            fprintf('Experiment quit by pressing ESCAPE\n');
            ShowCursor
            break;
        elseif (response==TRIGGER_KEY1 || response==TRIGGER_KEY2 || response==TRIGGER_KEY3)
            break;
        end
    end
    WaitSecs('YieldSecs',0.0001);
end
EXPERIMENT_START_TIME = GetSecs();
tic

%% Start Experiment
try

N = 1;
current = 1;

while current <= NUM_STIMULI
    if GetSecs() - EXPERIMENT_START_TIME > STIMULUS_SET{N}.start_time
        current = N;
        switch STIMULUS_SET{current}.type
            case 'fixation'
                
                Screen('FillRect',wPtr,bgColors(colorIdx(cI),:));
                Screen('DrawLines', wPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
                Screen('Flip',wPtr);
                cI = cI + 1;
                                
            case 'image'

                Screen('FillRect',wPtr,bgColors(colorIdx(cI),:));
                Screen('DrawTexture', wPtr, imageDisplay(iI), [], pos(iI,:));
                flipTime(iI) = Screen('Flip', wPtr);
                subjData(iI+1,5) = {flipTime(iI) - EXPERIMENT_START_TIME};
                subjData(iI+1,6) = {repetitions(iI)};
                
                Screen('FillRect',wPtr,bgColors(colorIdx(cI),:));
                Screen('DrawLines', wPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
                did_subj_respond = 0;
                while GetSecs<(flipTime(iI)+dur.stim)
                    if did_subj_respond == 0,
                        did_subj_respond = getKeyResponse;
                    end
                    WaitSecs('YieldSecs', 0.0001);
                end
                Screen('Flip',wPtr);
                Screen('Close',imageDisplay(iI));
                
                cI = cI + 1;
                iI = iI + 1;
                              
            case 'break'

                Screen('FillRect',wPtr,bgColors(colorIdx(cI),:));
                Screen('DrawLines', wPtr, allCoords, lineWidthPix, black, [xCenter yCenter]);
                Screen('Flip',wPtr);
                cI = cI + 1;
                
            case 'breakText'

                Screen('FillRect',wPtr,bgColors(colorIdx(cI),:));
                DrawFormattedText(wPtr,'Halfway Done!','center',yCenter-H/8-FONT_SIZE/2);
                Screen('DrawTexture', wPtr, halfWay_disp, [], halfWay_pos);
                Screen('Flip',wPtr);
                cI = cI + 1; 
                did_subj_respond = 1;
                
            case 'end run'
                [sumMat,pctCorrect,meanRT] = summarizeResponses(subjData);
                
                allData = subjData;
                
                sumData = {};
                sumData(1,1:4) = {'Condition','Mean RT','Stddev','Accuracy'};
                sumData(2,1) = {'Words'};
                sumData(3,1) = {'Scr'};
                sumData(4,1) = {'Lines'};
                sumData(5,1) = {'Faces'};
                sumData(2:5,2:4) = num2cell(sumMat);
                
                subjData(end+2:end+6,1:4) = sumData;
                
                cell2csvMR([DATA_DIR filesep file_to_save], subjData, ',');
                save([DATA_DIR filesep file_to_save(1:end-4) '.mat'],'NUM','RUN','SUBJ_ID','allData','sumData');
                fprintf('Total Run Time in Seconds: %f\n', toc);
                fprintf('Subject got %.3f%% correct with avg. RT: %.4f seconds.\n',pctCorrect,meanRT);
                Screen('FillRect',wPtr,bgColors(colorIdx(1),:));
                DrawFormattedText(wPtr,'Done!','center',yCenter-H/8-FONT_SIZE/2);
                Screen('DrawTexture', wPtr, done_disp, [], done_pos);
                Screen('Flip',wPtr);
                WaitSecs('YieldSecs', 1);
                Screen('CloseAll');
                ShowCursor
                return;
        end
        
        N = N + 1;       
        
    end
    
    % Record user responses
    % Check the state of the keyboard.
    [keyIsDown, seconds, keyCode] = KbCheck(-1);

    if keyIsDown
        if strcmp(STIMULUS_SET{current}.type,'image') && did_subj_respond == 0
            response=find(keyCode);
            if ismember(response,RESPONSE_KEYS)
                did_subj_respond = 1;
                RT_raw(iI-1) = seconds;
                if isempty(find(RT_raw(iI-2)))
                    if repetitions(iI-2)
                        subjData(iI-1,7) = {1};
                    else
                        subjData(iI,7) = {1};
                    end
                    if repetitions(iI-2)
                        subjData(iI-1,8) = {RT_raw(iI-1) - flipTime(iI-2)};
                    else
                        subjData(iI,8) = {RT_raw(iI-1) - flipTime(iI-1)};
                    end
                    if repetitions(iI-1)
                        subjData(iI,9) = {1};
                    elseif repetitions(iI-2)
                        subjData(iI-1,9) = {1};
                    else
                        subjData(iI,9) = {0};
                    end
                end
            end
        end
        if keyCode(ESCAPE_KEY)
            cell2csvMR([DATA_DIR filesep file_to_save(1:end-4) '_earlyEsc.csv'], subjData, ',');
            save([DATA_DIR filesep file_to_save(1:end-4) '_earlyEsc.mat'],'NUM','RUN','SUBJ_ID','subjData');
            Screen('CloseAll');
            fprintf('Experiment quit by pressing ESCAPE\n');
            ShowCursor
            break;
        end

    end
end

catch err
    
    cell2csvMR([DATA_DIR filesep file_to_save(1:end-4) '_err.csv'], subjData, ',');
    save([DATA_DIR filesep file_to_save(1:end-4) '_err.mat'],'NUM','RUN','SUBJ_ID','subjData');
    Screen('CloseAll');
    fprintf('Experiment quit due to error\n');
    save([DATA_DIR filesep file_to_save(1:end-4) '_errorInfo'],'err');
    ShowCursor
    
end

%% Subfunctions

    function cond_list = randomizeCondOrder(condition)
        cond_dir = [STIM_DIR filesep condition];
        cond_file_list = dir([cond_dir '/*.' IMAGE_FORMAT]);
        [~,cond_order] = sort(rand(size(cond_file_list,1),1));
        cond_list = cell(size(cond_file_list,1),1);
        for i = 1:length(cond_order)
            cond_list{i,1} = [condition filesep cond_file_list(cond_order(i),1).name];
        end
    end

    function result = nonRepeatingRand(top,count)
        diff = randi(top - 1,[count,1]);
        result = rem(cumsum(diff) + randi(1,[count,1]) - 1, top) + 1;
    end

    function out = getKeyResponse
        [keyIsDown,seconds,keyCode]=KbCheck(-1);
        if keyIsDown
            response=find(keyCode);
            if ismember(response,RESPONSE_KEYS)
                out = 1;
                RT_raw(iI) = seconds;
                if isempty(find(RT_raw(iI-1)))
                    if repetitions(iI-1)
                        subjData(iI,7) = {1};
                    else
                        subjData(iI+1,7) = {1};
                    end
                    if repetitions(iI-1)
                        subjData(iI,8) = {RT_raw(iI) - flipTime(iI-1)};
                    else
                        subjData(iI+1,8) = {RT_raw(iI) - flipTime(iI)};
                    end
                    if repetitions(iI)
                        subjData(iI+1,9) = {1};
                    elseif repetitions(iI-1)
                        subjData(iI,9) = {1};
                    else
                        subjData(iI+1,9) = {0};
                    end
                end
            else
                out = 0;
            end
        else
            out = 0;
        end
    end

    function [outMat,pctcorrect,meanRT] = summarizeResponses(data)
        outMat = NaN(4,3);
        conds = cell2mat(data(2:end,3));
        repList = cell2mat(data(2:end,6));
        rts = cell2mat(data(2:end,8));
        accurate = cell2mat(data(2:end,9));
        for idxCond = 1:4,
            numReps = length(find(conds == idxCond & repList == 1));
            tmpAcc = find(conds == idxCond & accurate ==1);
            outMat(idxCond,3) = length(tmpAcc)/numReps;
            outMat(idxCond,1) = mean(rts(tmpAcc),1);
            outMat(idxCond,2) = std(rts(tmpAcc),1,1);
        end
        allRight = find(accurate);
        allReps = find(repList);
        pctcorrect = (length(allRight)/length(allReps))*100;
        meanRT = mean(rts(allRight),1);
    end
    
end