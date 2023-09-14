wordScramble('wordis')

function word = wordScramble
    word = input('type a word to be scrambled: ', 's');
    word(randperm(numel(word)))
end