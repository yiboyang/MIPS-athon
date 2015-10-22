// Lexathon written in C. No functions used so less overhead!
// By Yibo Yang
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>

//const WDSIZE = 32; // assuming a word has 32 chars at most
//const int MAXSOLN = 100; // maximum number of solutions per round==100
//char soln[MAXSOLN][WDSIZE]={0};
//char ans[MAXSOLN][WDSIZE]={0};

#define WDSIZE 32 // assuming a word has 32 chars at most
#define MAXSOLN 100 // maximum number of solutions per round==100
char soln[MAXSOLN][WDSIZE];
char ans[MAXSOLN][WDSIZE];

int main() {
	// srand(118); // seed the randomizer for debugging
	srand(time(NULL));
	printf("----Lexathon in C----\n");
	while (1) {
		memset(soln, 0, sizeof(soln));
		memset(ans, 0, sizeof(ans));
		puts("---------------------\n");
		puts("enter 'n' to start a new round, or enter 'q' to quit: ");
		char quit;
		while ((quit=(char)getchar())=='\n');
		if (quit == 'q' || quit == 'Q')
			break;
		// build the grid
		char chars[9] = { 0 }; // grid size = 9
		// populate each entry with random chars
		int i;
		for (i = 0; i < 9; i++)
			chars[i] = rand() % 26 + 97; // random char between 97 ('a') and 122 ('z')

		// populate the solution array
		int count[26] = { 0 }, countCopy[26] = { 0 };
		int j;
		for (j = 0; j < 9; j++) {
			int ch = chars[j];
			count[ch - 97]++; // increase the count for that character
			countCopy[ch - 97]++; // countCopy will be later used to restore count
		}

		// now find all the solutions based on corresponding dictionary file
		char center = chars[4]; // center grid that determines which dic to open
		char dicName[6] = { 0 }; // in MIPS we probably have to manually set everything to 0 (NULL) and manually copy
		strncat(dicName, &center, 1); // notice the arguments must be const char*
		strncat(dicName, ".txt", 4);
		// open the dictionary
		FILE * fin;
		fin = fopen(dicName, "r");
		if (fin == NULL) {
			puts("Failed to open dictionary file!");
			return -1;
		}

		// now check every line of dictionary for valid solution
		char line[WDSIZE];
		int numSoln = 0;
		while (!feof(fin)) {
			fscanf(fin, "%s", line);
			if (strcmp(line, "\0") == 0)
				break; // this is when we encounter the newline right before EOF
			short goodLine = 1;
			char c;
			int idx = 0;
			while (1) {
				c = line[idx++];
				if (c == '\0')
					break;
				count[c - 97]--; // decrease the count for that character
				if (count[c - 97] == -1) // if we reached the count limit
				{
					goodLine = 0;
					break;
				}
			}

			if (goodLine)
				strncpy(*(soln + numSoln++), line, WDSIZE); // pointer notation same as "soln[numSoln++]"

			int j;
			for (j = 0; j < 26; j++) {
				count[j] = countCopy[j]; // restore the original count
			}
		}
		fclose(fin);

		// we've finished populating the solutions array; time for user interaction
		int numAns = 0; // initialize number of valid user answers to 0
		while (1) {
			// print the grid
			printf("\n");
			puts("-----");
			int i = 0;
			for (i = 0; i < 9; i++) {
				printf("%c ", *(chars + i));
				if (i % 3 == 2)
					printf("\n");
			}
			puts("-----");

			// prompt/validate input
			char entry[WDSIZE];
			printf("enter your word (4-9 char lower case, must use the letter at the center of the grid); [enter 'S' for all solutions, 'D' to be done with this round]: ");
			printf("\n");
			scanf(" %s", entry);
			if (entry[0] == 'S') {
				if (numSoln == 0) {
					puts("Sorry to waste your time: no solutions for this round!");
					break;
				}

				int s;
				for (s = 0; s < numSoln; s++)
					printf("%s\n", soln[s]);
				continue;
			}

			else if (entry[0] == 'D')
				break;

			if (strlen(entry) < 4 || strlen(entry) > 9) // minimal input validation :)
			{
				puts("Make sure your entry has 4-9 chars!");
				continue;
			}

			// is this answer already entered?
			short alreadyAns = 0;
			int a;
			for (a = 0; a < numAns; a++) {
				if (strcmp(ans[a], entry) == 0) {
					alreadyAns = 1;
					break;
				}
			}

			if (alreadyAns)
				puts("You already found it!");
			else // else this is a new entry
			{
				// by this point we can check the answer; for simplicity use linear search
				// (even though a binary search is better and not difficult to write since
				// all the rows in soln are already sorted; but converting to MIPS...)
				short isSoln = 0;
				int k;
				for (k = 0; k < numSoln; k++) {
					if (strcmp(soln[k], entry) == 0) {
						isSoln = 1;
						break;
					}
				}
				if (isSoln) // add to ans
				{
					puts("Right on!");
					strncpy(ans[numAns++], entry, WDSIZE);
				} else
					// else this new entry is no good
					puts("Nope...");
			}

			puts("Words found so far: ");
			int p;
			for (p = 0; p < numAns; p++)
				printf("%s ", ans[p]);
			printf("\n");
			printf("%d out of %d\n", numAns, numSoln);
		}
	}
	puts("bye");
	return 0;
}

