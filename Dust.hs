module Dust where

import System.IO.Unsafe
import System.Random
import Data.Maybe (listToMaybe)

-- have 2 humans play aaginst each other
human = do
	main 0

-- have 1 human play against the machine
ai = do
	main 1

main :: Int -> IO()
main ai = do
	putStrLn "Side length "
	n <- grab

	let board = populate 0 0 (construct n)

	putStrLn "Row and column numbers count from 1 to n, starting with the top-left corner. For example:"
	putStrLn "Top-left corner is (1, 1), top-right corner is (1, n), bottom-left corner is (n, 1), bottom-right corner is (n, n)."
	putStrLn ""
	printBoard n 0 board

	if ai == 0
		then play board n 0
		else playAI board n 0

-- routine for two players playing against each other. The first player to step on a mine loses.
play :: [((Int,Int),Int)] -> Int -> Int -> IO()
play board n turns = do
	if (mod turns 2) == 0 
		then putStrLn "Player 1's turn."
		else putStrLn "Player 2's turn."

	coordinates <- turn n

	let result = sweep (fst coordinates) (snd coordinates) 0 board
	--let result = explore (fst coordinates) (snd coordinates) board
	putStrLn ""
	printBoard n 0 result

	if referenceCell (fst coordinates) (snd coordinates) board == -2
		then putStrLn "You lost."
		else if gameOver result
			then putStrLn "You won."
			else play result n (turns + 1)

-- routine for playing against the computer (aka the R-110). First one to step on a mine loses.
playAI :: [((Int,Int),Int)] -> Int -> Int -> IO()
playAI board n turns = do
	if (mod turns 2) == 0 
		then do
			putStrLn "Your turn, human."
			coordinates <- turn n
			let result = sweep (fst coordinates) (snd coordinates) 0 board
			putStrLn ""
			printBoard n 0 result

			if referenceCell (fst coordinates) (snd coordinates) board == -2
				then putStrLn "You lost."
				else if gameOver result
					then putStrLn "You won."
					else playAI result n (turns + 1)
		else do
			putStrLn "R-110 on the move--"
			let coordinates = robotTurn n board
			let result = sweep (fst coordinates) (snd coordinates) 0 board
			putStrLn ""
			printBoard n 0 result

			if referenceCell (fst coordinates) (snd coordinates) board == -2
				then putStrLn "R-110 lost."
				else if gameOver result
					then putStrLn "R-110 won."
					else playAI result n (turns + 1)

-- function for verifying user input: http://stackoverflow.com/questions/2931557/haskell-check-for-user-input-errors
maybeRead :: Read a => String -> Maybe a
maybeRead = fmap fst . listToMaybe . filter (null . snd) . reads

-- used for letting the user choose which spot on the board to uncover
-- row and column numbers range from 1 to n.
-- The top left corner is (1, 1) -- it counts out from there.
-- uses the Matlab standard of matrix indexing: http://www.mathworks.com/help/matlab/math/matrix-indexing.html
turn :: Int -> IO(Int, Int)
turn n = do
   putStrLn "Row number "
   x <- grab
   putStrLn "Column number "
   y <- grab
   if x < 1 || y < 1 ||  x > n || y > n
   		then do
   			putStrLn "Error: invalid row/column values."
   			turn n
   		else return (x - 1, y - 1) -- rest of the program computes index operations using the standard "start at zero" approach.

-- robot randomly picks a spot on the board that doesn't have a mine. If no such spots exist, it will step on a mine.
-- The only way to beat the robot is to pick the last non-mine spot. Very difficult to do.
robotTurn :: Int -> [((Int,Int),Int)] -> (Int, Int)
robotTurn n board
	| length idealSpots > 0 = (fst (fst randomGoodSpot), snd (fst randomGoodSpot))
	| length badSpots > 0 = (fst (fst randomBadSpot), snd (fst randomBadSpot))
	| otherwise = (fst (fst firstBadSpot), snd (fst firstBadSpot))
	where idealSpots = (filter ((==(0-1)).snd) board)
	      badSpots = (filter ((==(0-2)).snd) board)
	      randomGoodSpot = idealSpots !! unsafePerformIO (getStdRandom (randomR (0, length idealSpots - 1)))
	      randomBadSpot = badSpots !! unsafePerformIO (getStdRandom (randomR (0, length badSpots - 1)))
	      firstBadSpot = badSpots !! 0

-- used for grabbing any sort of user input. Uses recursion to reprompt in event of user input errors.
grab :: IO(Int)
grab = do
	putStr "Enter an integer: "
	x <- fmap maybeRead getLine :: IO (Maybe Int)
	case x of
  	  Just x -> return x
  	  Nothing -> grab

-- -1 = untouched spot (safe), -2 = untouched mine (will lose if uncovered), 0 = spot already uncovered (display # of surrounding mines)

-- creates grid full of zeroes, later to be populated with mines/not mines
construct :: Int -> [((Int,Int),Int)]
construct n = [((x, y), 0) | x <- [0..n-1], y <- [0..n-1]]

-- populates board with random mines
-- for some reason, on a 3x3 board, the first coordinate tuple (0, 0) gets replaced with (2, 3).
-- A similar pattern probably exists for different board sizes. As of right now, this does not seem to affect gameplay.
-- However, this bug should be found and removed, because I imagine it would cause difficulties further down the line.
populate :: Int -> Int -> [((Int,Int),Int)] -> [((Int,Int),Int)] -- call like: populate 0 0 board
populate x y board = do
	let index = serveIndex x y board
	let secondaryIndex = serveIndex (x+1) 0 board
	let value = placeMine 9 2 -- for more mines, raise the first #, lower the second #. In the future this value might be set by the user at the program's start.
	if index >= 0
		then populate x (y+1) (sweep x y value board)
		else if secondaryIndex >= 0
			then populate (x+1) 0 (sweep x y value board)
			else popFix (sweep x y value board)

-- Replaces first coordinate (n-1, n) with (0, 0)
popFix :: [((Int,Int),Int)] -> [((Int,Int),Int)]
popFix board = do
	let cell = board!!0
	let replacement = ((0, 0), snd cell) -- replaces whatever's at that location with the chosen value
	replacement : (snd (splitAt 1 board))

-- Prints the board onto the screen. Recursive function -- at the initial call, "m" should be zero.
printBoard :: Int -> Int -> [((Int,Int),Int)] -> IO()
printBoard n m arr = do
	let cell = (arr !! m)
	let x = fst (fst cell)
	let y = snd (fst cell)
	let val = snd cell
	if val == (-1) || val == (-2)
		then putStr "-"
		else putStr (show (sumAdjMines x y arr))
	if y == (n-1)
		then putStr "\n" -- row is expired, move on to next row
		else putStr "  " -- separate each number with a tab. Should suffice since the numbers displayed are one-digit-wide, max.
	if (m+1) < (length arr)
		then printBoard n (m+1) arr
		else putStrLn ""

-- Changes the value stored at a given location in the board, uses list techniques to construct and return a new board.
sweep :: Int -> Int -> Int -> [((Int,Int),Int)] -> [((Int,Int),Int)]
sweep x y value board = do
	let index = serveIndex x y board
	let cell = board!!index
	let chunks = splitAt index board
	let firstChunk = fst chunks
	let secondChunk = snd chunks
	let tailEnd = snd (splitAt 1 secondChunk)
	let fillIn = ((x, y), value) -- replaces whatever's at that location with the chosen value
	firstChunk ++ fillIn : tailEnd -- returns the new board

-- doesn't work (ideally it would recursively traverse the board for any spots with 0 mines surrounding it, a la real minesweeper, but I haven't successfully implemented that yet.)
explore :: Int -> Int -> [((Int,Int),Int)] -> [((Int,Int),Int)]
explore x y board
	| sumAdjMines x y board /= 0 = sweep (x-1) y 0 board
	| otherwise = explore (x+1) y (sweep (x+1) y 0 board)


-- takes in an x,y coordinate pair and returns the coordinates for the list itself (since the 2-dimensional board is a 1-dimensional list)
-- uses "row-major" computation for 
serveIndex :: Int -> Int -> [((Int,Int),Int)] -> Int
serveIndex x y board = do
	let sideLength = sqrt (fromIntegral (length board)) 
	let index = (truncate sideLength)*x + y
	if index < 0 || index >= (length board) || x < 0 || x >= (truncate sideLength) || y < 0 || y >= (truncate sideLength)
		then -1
		else index

-- find value at a location specified by x, y coordinates
referenceCell :: Int -> Int -> [((Int,Int),Int)] -> Int -- given x y coordinates and a board, this returns the value stored in that location
referenceCell x y board = do
	let index = serveIndex x y board
	if index >= 0 && index < (length board)
		then snd (board !! index)
		else 0

-- find number of mines that surround a given location
sumAdjMines :: Int -> Int -> [((Int,Int),Int)] -> Int
sumAdjMines x y board = do
	let left = referenceCell (x-1) (y) board
	let topLeft = referenceCell (x-1) (y-1) board
	let top = referenceCell (x) (y-1) board
	let topRight = referenceCell (x+1) (y-1) board
	let right = referenceCell (x+1) (y) board
	let bottomRight = referenceCell (x+1) (y+1) board
	let bottom = referenceCell (x) (y+1) board
	let bottomLeft = referenceCell (x-1) (y+1) board
	-- neighbors comprises the 8 spots surrounding the given spot. If one of the 8 spots is invalid (off the board), it's returned as a 0.
	let neighbors = [left, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft]
	let mines = (filter (== -2) neighbors) -- neighbors will contain a mix of 0s, -1s and -2s. We're interested in the -2s.
	length mines -- specifically, we're interested in how many -2s are in that list.

-- Determine whether or not a given location should have a mine there. Used when board is initially created.
-- The higher the value of "n" is, the less likely a given spot will contain a mine (in theory -- fewer mines).
-- unsafePerformIO (getStdRandom (randomR (0, n))) produces a random number from 0 to n-1.
-- If the given number is less than "m" a mine will be spawned.
placeMine :: Int -> Int -> Int
placeMine n m = do
	if unsafePerformIO (getStdRandom (randomR (0, n))) > m
		then -1 -- safe square
		else -2 -- mine

-- win condition: returns false if a given index does not store -1. Filter board down to those entries that store -1. If the length is zero, the game is won,
-- since there exist no more spots to uncover.
gameOver :: [((Int,Int),Int)] -> Bool
gameOver board = do
	let untouchedSpots = filter ((==(0 - 1)).snd) board
	if (length untouchedSpots) == 0
		then True
		else False
