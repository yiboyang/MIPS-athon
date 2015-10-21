// Lexathon written in C++. No functions used so less overhead!
// Use c-strings, so translation to C is greatly simplified.
// By Yibo Yang
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<ctime>
#include<cstring> // not using string objects just for fun :)
using namespace std;

const int WDSIZE = 32; // assuming a word has 32 chars at most
const int MAXSOLN = 100; // maximum number of solutions per round==100

int main() {
	//srand(118); // seed the randomizer for debugging
	srand(time(NULL)); // randomize with time
	cout << "----Lexathon in C++----" << endl;
	while (1) {
		char soln[MAXSOLN][WDSIZE] = { 0 }; // declare the array of cstring solutions
		char ans[MAXSOLN][WDSIZE] = { 0 }; // declare the array of user answers

		cout << "-----------------------" << endl;
		cout << "enter 'n' to start a new round, or enter 'q' to quit: ";
		char quit;
		cin >> quit;
		if (quit == 'q' || quit == 'Q')
			break;
		cin.ignore();
		// build the grid
		char chars[9] = { 0 }; // grid size = 9
		// populate each entry with random chars
		for (int i = 0; i < 9; i++)
			chars[i] = rand() % 26 + 97; // random char between 97 ('a') and 122 ('z')

		// populate the solution array
		int count[26] = { 0 }, countCopy[26] = { 0 };
		for (int j = 0; j < 9; j++) {
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
		ifstream fin(dicName);
		if (!fin.is_open()) {
			cout << "Failed to open dictionary file!" << endl;
			return -1;
		}

		// now check every line of dictionary for valid solution
		char line[WDSIZE];
		int numSoln = 0;
		while (!fin.eof()) {
			fin.getline(line, WDSIZE);
			if (strcmp(line, "\0") == 0)
				break; // this is when we encounter the newline right before EOF
			bool goodLine = true;
			char c;
			int idx = 0;
			while (1) {
				c = line[idx++];
				if (c == '\0')
					break;
				count[c - 97]--; // decrease the count for that character
				if (count[c - 97] == -1) // if we reached the count limit
						{
					goodLine = false;
					break;
				}
			}

			if (goodLine)
				strncpy(*(soln + numSoln++), line, WDSIZE); // pointer notation same as "soln[numSoln++]"

			for (int j = 0; j < 26; j++) {
				count[j] = countCopy[j]; // restore the original count
			}
		}
		fin.close();

		// we've finished populating the solutions array; time for user interaction
		int numAns = 0; // initialize number of valid user answers to 0
		while (1) {
			cout << endl;

			// print the grid
			cout << "-----" << endl;
			for (int i = 0; i < 9; i++) {
				cout << *(chars + i) << ' ';
				if (i % 3 == 2)
					cout << endl;
			}
			cout << "-----" << endl;

			// prompt/validate input
			char entry[WDSIZE];
			cout << "enter your word (4-9 char lower case, must use the letter "
					<< "at the center of the grid); [enter 'S' for all solutions,"
					<< "'D' to be done with this round]: ";
			cout << endl;
			cin.getline(entry, WDSIZE);
			if (entry[0] == 'S') {
				if (numSoln == 0) {
					cout
							<< "Sorry to waste your time: no solutions for this round!"
							<< endl;
					break;
				}

				for (int s = 0; s < numSoln; s++)
					cout << soln[s] << endl;
				continue;
			}

			else if (entry[0] == 'D')
				break;

			if (strlen(entry) < 4 or strlen(entry) > 9) // minimal input validation :)
					{
				cout << "Make sure your entry has 4-9 chars!" << endl;
				continue;
			}

			// is this answer already entered?
			bool alreadyAns = false;
			for (int a = 0; a < numAns; a++) {
				if (strcmp(ans[a], entry) == 0) {
					alreadyAns = true;
					break;
				}
			}

			if (alreadyAns)
				cout << "You already found it!" << endl;
			else // else this is a new entry
			{
				// by this point we can check the answer; for simplicity use linear search
				// (even though a binary search is better and not difficult to write since
				// all the rows in soln are already sorted; but converting to MIPS...)
				bool isSoln = false;
				for (int k = 0; k < numSoln; k++) {
					if (strcmp(soln[k], entry) == 0) {
						isSoln = true;
						break;
					}
				}
				if (isSoln) // add to ans
				{
					cout << "Right on!" << endl;
					strncpy(ans[numAns++], entry, WDSIZE);
				} else
					// else this new entry is no good
					cout << "Nope..." << endl;
			}

			cout << "Words found so far: ";
			for (int p = 0; p < numAns; p++)
				cout << ans[p] << " ";
			cout << endl;
			cout << numAns << " out of " << numSoln << endl;
		}
	}
	cout << "bye" << endl;
	return 0;
}

