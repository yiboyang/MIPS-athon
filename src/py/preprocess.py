# input: name of the word list file to be preprocessed, e.g.
# preprocess('linux_words.txt'); (this is the one gigantic dictionary,
# terminating in newline)
# output: 26 text files: a.txt, b.txt, c.txt, ... z.txt. Each
# lists words that contain the corresponding character, which are also
# potentially 'valid' entries in the Lexathon game (with that particular
# character at the center), i.e. length b/w 4 and 9, lower-case only, and no
# repeated characters.
# By Yibo Yang
# Edit: Tim Hewitt

import sys

lowerChars='abcdefghijklmnopqrstuvwxyz'
minCharNum=4 # default minimum number of characters
maxCharNum=9


def preprocess(wordlist):
    # First create and collect a bunch of file handles for the output files
    foutList=[]
    for char in lowerChars:
        out=char+'.txt'
        try:
            fout=open(out,'w')
            foutList.append(fout)
        except IOError:
            print("Can't create output files")
            sys.exit(1)

    # Now real processing
    with open(wordlist, 'r') as words:
        for word in words:
            word=word.rstrip() # remove annoying newline at the end; word[:-1] doesn't always work b/c '\r\n' vs '\n' issue
            # print(word)
            if valid(word):
                wordChars=set(word) # important to convert to set to avoid duplicates; e.g. we don't want to write to g.txt twice the word "egg"
                word = word.ljust(9, '\0') # Consistent line size
                for char in wordChars: # append this word with appropriate handle;
                    foutList[ord(char)-97].write(word+'\0')

    for fout in foutList:
        fout.close()


# returns true if the given string is 'valid'
def valid(string):
    if len(string)<minCharNum or len(string)>maxCharNum:
        return False
    letters = set()
    for char in string:
        if (char<'a' or char>'z'):
            return False
        if char in letters: # add in check for repeated characters.
            return False
        else:
            letters.add(char)

    return True;


if __name__ == '__main__':
    if (len(sys.argv)!=2):
        raise ValueError('usage: preprocess.py <inputfile>')
    preprocess(sys.argv[1])
    print('Finished!')
