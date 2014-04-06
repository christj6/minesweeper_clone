#include <iostream>
#include <fstream>
#include <stdio.h>      /* printf, scanf, puts, NULL */
#include <stdlib.h> 
#include <time.h>       /* time */


#define MINES 100 // max number of mines
#define LENGTH 10 // max length of board

// g++ dust.cpp -o dust.o
// ./dust.o

using namespace std;

int mineHit(int, int);
int returnValue(int, int);
int winCheck();
int search(int, int);
void exploreLeft(int, int);
void exploreUp(int, int);
void exploreRight(int, int);
void exploreDown(int, int);
void generateMines();
void printBoard();

int game = 1;

int workingLength = 4;
int workingMines = 3;

int board[LENGTH][LENGTH];

int mineXcoord[MINES];
int mineYcoord[MINES];

int mineHit(int x, int y)
{
	if (x > -1 && x < workingLength)
	{
		if (y > -1 && y < workingLength)
		{
			for (int i = 0; i < workingMines; i++)
			{
				if (mineXcoord[i] == x)
				{
					if (mineYcoord[i] == y)
					{
						return 1;
					}
				}
			}
		}
	}

	return 0;
}

int returnValue(int x, int y)
{
	if (x > -1 && x < workingLength)
	{
		if (y > -1 && y < workingLength)
		{
			return board[x][y];
		}
	}

	return -10;
}

// checks if it's possible to click another square without a mine being found there
int winCheck()
{
	int untouchedSpots = 0;
	int untouchedMines = 0;

	for (int i = 0; i < workingLength; i++)
	{
		for (int j = 0; j < workingLength; j++)
		{
			if (board[i][j] == -1)
			{
				untouchedSpots++;

				if (mineHit(i, j) == 1)
				{
					untouchedMines++;
				}
			}
		}
	}

	if (untouchedMines == untouchedSpots)
	{
		return 1;
	}

	return 0;
}


int search(int x, int y)
{
	int surroundingHits = 0;

	if (mineHit(x-1, y) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x-1, y-1) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x, y-1) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x+1, y-1) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x+1, y) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x+1, y+1) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x, y+1) == 1)
	{
		surroundingHits++;
	}
	if (mineHit(x-1, y+1) == 1)
	{
		surroundingHits++;
	}

	return surroundingHits;
}

void exploreLeft(int x, int y)
{
	if (search(x-1,y) == 0 && returnValue(x-1, y) == -1)
	{
		board[x-1][y] = 0;
		exploreLeft(x-1, y);
		exploreUp(x-1, y);
		exploreDown(x-1, y);
	}
	else if (search(x-1,y) != 0 && mineHit(x, y) != 1)
	{
		board[x-1][y] = search(x-1,y);
	}
}

void exploreUp(int x, int y)
{
	if (search(x, y-1) == 0 && returnValue(x, y-1) == -1)
	{
		board[x][y-1] = 0;
		exploreUp(x, y-1);
		exploreLeft(x, y-1);
		exploreRight(x, y-1);
	}
	else if (search(x, y-1) != 0 && mineHit(x, y-1) != 1)
	{
		board[x][y-1] = search(x, y-1);
	}
}

void exploreRight(int x, int y)
{
	if (search(x+1, y) == 0 && returnValue(x+1, y) == -1)
	{
		board[x+1][y] = 0;
		exploreRight(x+1, y);
		exploreUp(x+1, y);
		exploreDown(x+1, y);
	}
	else if (search(x+1, y) != 0 && mineHit(x+1, y) != 1)
	{
		board[x+1][y] = search(x+1, y);
	}
}

void exploreDown(int x, int y)
{
	if (search(x, y+1) == 0 && returnValue(x, y+1) == -1)
	{
		board[x][y+1] = 0;
		exploreDown(x, y+1);
		exploreLeft(x, y+1);
		exploreRight(x, y+1);
	}
	else if (search(x, y+1) != 0 && mineHit(x, y+1) != 1)
	{
		board[x][y+1] = search(x, y+1);
	}
}

void printBoard()
{
	for (int i = 0; i < workingLength; i++)
	{
		for (int j = 0; j < workingLength; j++)
		{
			if (board[i][j] == -1)
			{
				cout << "-" << " ";
			}
			else
			{
				cout << board[i][j] << " ";
			}
		}
		cout << endl;
	}
}

int assessValue(int x, int y)
{
	// the lowest value will be the safest spot to mark, highest the most likely to have a mine
	// algorithm to be implemented later
	return 0;
}

void findSpot(int *x, int *y)
{
	for (int i = 0; i < workingLength; i++)
	{
		for (int j = 0; j < workingLength; j++)
		{
			// to be implemented later, using the assess value function
			(*x) = i;
			(*y) = j;
		}
	}
}

void generateMines()
{
	for (int i = 0; i < workingMines; i++)
	{
		mineXcoord[i] = rand() % workingLength;
		mineYcoord[i] = rand() % workingLength;

		/*
		// this block of code doesn't work the way I intended -- duplicate mines still appear
		for (int j = 0; j < workingMines; j++)
		{
			if (i != j && mineXcoord[i] == mineXcoord[j] && mineYcoord[i] == mineYcoord[j]) // ensure there are no duplicate pairs of mine coordinates
			{
				mineXcoord[i] = rand() % workingLength;
				mineYcoord[i] = rand() % workingLength;
			}
		}    
		*/

		//mineXcoord[i] = -500; // used to eliminate MINES from playing field; makes it easier to debug recursive zero display functions
		//mineYcoord[i] = -500;

		cout << "x: " << mineXcoord[i] << ", y: " << mineYcoord[i] << endl;
	}
}


int main()
{
	srand (time(NULL));

	cout << "Please enter length of board (up to 10): ";
	cin >> workingLength;
	cout << "Please enter number of mines (up to 100): ";
	cin >> workingMines;

	// initialize board
	for (int i = 0; i < workingLength; i++)
	{
		for (int j = 0; j < workingLength; j++)
		{
			board[i][j] = -1;
		}
	}

	generateMines();

	int whoseTurn = 0; // 0 = player, 1 = AI, just add 1 to it after each turn and take mod 2 to figure out whose turn it is.

	while (game == 1)
	{
		if (whoseTurn%2 == 0)
		{
			if (winCheck() == 1)
			{
				game = 0;
				cout << "Player 2 wins. " << endl;
			}
			else
			{
				cout << "Player 1's turn: \n";

				int x = 0;
				int y = 0;

				cout << "Please enter x: ";
				cin >> x;
				cout << "Please enter y: ";
				cin >> y;


				if (mineHit(x, y) == 1)
				{
					game = 0;
					cout << "Mine hit, you lose. " << endl;
				}
				else
				{
					board[x][y] = search(x, y);
					
					// when a user hits a spot with 0 MINES
					// the surrounding 0-spots will be revealed, like in normal minesweeper
					if (board[x][y] == 0)
					{
						exploreLeft(x, y);
						exploreUp(x, y);
						exploreRight(x, y);
						exploreDown(x, y);
					}
					
					printBoard();
					whoseTurn++;
				}
			}
		}
		else if (whoseTurn%2 == 1)
		{
			if (winCheck() == 1)
			{
				game = 0;
				cout << "Player 1 wins. " << endl;
			}
			else
			{
				cout << "Player 2's turn: \n";

				int x = 0;
				int y = 0;

				// Choose some good numbers for x and y
				/*
				for (int i = 0; i < workingLength; i++)
				{
					for (int j = 0; j < workingLength; j++)
					{
						if (mineHit(i, j) == 0 && returnValue(i, j) == -1)
						{
							// with this algorithm, the AI is definitely cheating.
							// Using information the human player doesn't have access to.
							x = i;
							y = j;
							i = workingLength + 1; // trip the loop when you find the first good spot, so you don't modify x and y.
							j = workingLength + 1;
						}
					}
				}

				if (x == 0 && y == 0 && returnValue(x, y) != -1)
				{
					// the AI ran out of guaranteed safe spots to check
					cout << "You cornered me, human. \n" << endl;
				}
				*/

				findSpot(&x, &y); // AI algorithm goes here

				if (mineHit(x, y) == 1) // this would probably never happen?
				{
					game = 0;
					cout << "Mine hit, player 2 loses. " << endl;
				}
				else
				{
					board[x][y] = search(x, y);
					
					// when a user hits a spot with 0 MINES
					// the surrounding 0-spots will be revealed, like in normal minesweeper
					if (board[x][y] == 0)
					{
						exploreLeft(x, y);
						exploreUp(x, y);
						exploreRight(x, y);
						exploreDown(x, y);
					}
					
					printBoard();
					whoseTurn++;
				}
			}
		}

	}

	

	return 0;
}

