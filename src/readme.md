#Here's an overview of my implementation of the prototype in C:

##Preprocessing:

create file handles for a.txt, b.txt, ... z.txt

for each entry in the bigass english dictionary:

    if entry is not valid (length &lt;4 or &gt;9 or contains non lowercase char): continue;

    create a set of chars in this entry

        for each char in set:

                append this entry to the file handle corresponding to this char

##The Game:

initialize two arrays, grid solutions array and user solutions array to null entries

generate 9 random numbers in [0,25], repetition allowed

get 9 corresponding letters and put them into an array

print grid based on the letters array

determine the dictionary file to access based on center grid letter

for each entry in that dictionary:

    if this entry is valid based on the array of 9 letters: *

        add to the grid solutions array;

    else: continue

ask user for input

if not valid (e.g. werid character, length &lt;4 or &gt;9): continue;

if already in user solutions array: continue;

if in the grid solutions array: congrats and add this input to user solutions array;

keep playing this round (prompt another input) or start a new round  

** Currently I do this by creating an array of size 26, each entry corresponding to the frequency a letter appears in the grid letters array; then for each word in the dictionary, I go through it character by character, decrementing the grid letter frequency array; if at any point I get a negative frequency, continue; else after going through the whole word, add it to the solutions array.

##MIPS stuff

Just added a basic file IO program to select any sub dictionary to read, all in one go (in Mars).

Guess we won't need SPIM after all.

Forgive my egregious  markdown...Feel free to make suggestions...Check back for more updates...
