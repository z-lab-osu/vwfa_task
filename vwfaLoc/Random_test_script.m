
screens=Screen('Screens');
screenNumber=max(screens);
[w, wRect]=Screen('OpenWindow',screenNumber, [0 0 0],[],[],[],[],[]);

ListenChar(2);

numLetters = 5;
numTrials = 5;

Screen('TextSize',w,110);
Screen('TextFont', w,'Arial');

A = 'A';
B = 'B';
C = 'C';



for trial = 1:numTrials
    for i = 1:numLetters

x = rand();     

% useThisLetter = strcat('letter',num2str(i));

if x < 0.33
    letter(i) = A;
elseif (x > 0.33) && (x<0.66)
    letter(i) = B;
else
    letter(i) = C;
end
% 
% y = rand()
% if y < 0.33
%     letter2 = A;
% elseif (y>0.33) && (y<0.66)
%     letter2 = B;
% else
%     letter2 = C;
% end
% 
% z = rand()
% if z < 0.33
%     letter3 = A;
% elseif (z>0.33) && (z<0.66)
%     letter3 = B;
% else
%     letter3 = C;
% end
    end

word = letter;
% save('word.mat', word);
% image(word);

grid = imread('gridgray.png');
grid2 = Screen('MakeTexture',w,grid);
Screen('DrawTexture',w,grid2);
DrawFormattedText(w, word,'center','center', [0,0,0]);
Screen('Flip',w);
WaitSecs(2);
Screen('Flip',w);
WaitSecs(0.5);
end

ListenChar(0);

sca
