What is this?
This is an implementation of the mobile game Lexathon in MIPS.

Features:
In this game you are given a 3x3 matrix of letters and you must find as many
words that use those letters as possible within 60 seconds.  All words you enter
must be at least 4 letters long, use each letter no more than the number of
times it appears in the matrix, and contain the center letter.

For each correct word you enter that you have not previously entered, you will
recieve points based off of your time remaining as well as the total number of
words possible.  In addition, for each correct word you will be given an
additional 20 seconds.

How to:
To use the program, first make sure that all provided dictionary files are in
the same directory as MARS, once that is accomplished simply assemble and run
the program.

To play the game, enter "start" when prompted to do so, then a new round will
start and you can start entering words.  Once you have found all the words you
can think of, you may enter "idk" to end the round early.  After you enter "idk"
or once the timer runs out you will be given your score as welll as all the
words that you did not find.  From there, you may either enter "start" to begin
a new round, or "exit" if you wish to end the program.

Limitations:
This variant of Lexathon produces boards that do not have repeated letters.
This makes the solution sets much smaller and the words harder to find. MARS
also appears to have an issue with repeated file IO, so it is suggested to
restart MARS if the board initialization is taking too long.
