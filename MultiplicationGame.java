import java.util.Scanner;
import java.lang.Math;

public class MultiplicationGame {

    // 2D array of integers to store the game board
    // IMPORTANT NOTE: In MIPS, this array is stored as a 1D array of INTEGERS!
    public static int[][] gameBoard = {
        {1, 2, 3, 4, 5, 6},
        {7, 8, 9, 10, 12, 14},
        {15, 16, 18, 20, 21, 24},
        {25, 27, 28, 30, 32, 35},
        {36, 40, 42, 45, 48, 49},
        {54, 56, 63, 64, 72, 81}
    };

    // Variables to store which choices the player and computer can pick from
    public static int choice1 = 0;
    public static int choice2 = 0;
    public static int choiceToChange = 0;

    // Variables to store the player and computer's chosen numbers
    public static int playersChosenNum = 0;
    public static int computersChosenNum = 0;

    // Integer to indicate whose turn it is (Player = -1, Computer = -2)
    public static int turnIndicator = -1;

    // Count the number of turns taken thus far
    public static int turnCount = 0;

    // -----------------------------------------------------------------------
    // -------------------------- MAIN GAME LOOP -----------------------------
    // -----------------------------------------------------------------------

    public static void main(String[] args) {
        // Make the initial computer choice
        getComputerChoice();
        printComputerChoice();

        while (true) {
            // Print game board, and process the turn for the user
            printGameBoardAndChoices();
            getUserChoice();
            calculateMoveAndUpdateBoard();
            checkWin();

            // Print game board, and process the turn for the computer
            printGameBoardAndChoices();
            getComputerChoice();
            printComputerChoice();
            calculateMoveAndUpdateBoard();
            checkWin();
        }
    }

    // -----------------------------------------------------------------------
    // --------------------- GETTING VALID COMPUTER INPUT --------------------
    // -----------------------------------------------------------------------

    // Name: getComputerChoice
    // Purpose: To get a valid choice for the computer to make on the board
    public static void getComputerChoice() {

        // For every turn that is NOT the first turn:
        if (turnCount != 0) {

            // Have the computer choose a random number between 1 - 9
            computersChosenNum = (int) Math.floor(Math.random() * (10 - 1) + 1);
            // Have the computer randomly choose which choice it wants to change (1 or 2)
            choiceToChange = (int) Math.floor(Math.random() * (3 - 1) + 1);

            // If the computer's chosen numbers are NOT valid, then run getComputerChoice() again
            if (!validateComputerChoice(computersChosenNum, choiceToChange)) {
                getComputerChoice();
            }

            // When the computer has chosen valid values, update the choices accordingly
            if (choiceToChange == 1) {
                choice1 = computersChosenNum;
            }
            else {
                choice2 = computersChosenNum;
            }

        }
        else {
            // EDGE CASE: On the first turn, have the computer choose any value, 1 - 9
            computersChosenNum = (int) Math.floor(Math.random() * (10 - 1) + 1);
            // EDGE CASE: On the first turn, have the computer set the value of choice 1
            choice1 = computersChosenNum;
        }
    }

    // Name: validateComputerChoice
    // Purpose: to validate the choice that the computer made
    // Returns: boolean, true/false depending on if the computer's chosen numbers are valid or not
    public static boolean validateComputerChoice(int computersChosenNum, int choiceToChange) {

        int computerMove;

        // Calculate what the computer's move would be given its current number selections
        if (choiceToChange == 1) {
            computerMove = computersChosenNum * choice2;
        }
        else {
            computerMove = computersChosenNum * choice1;
        }

        // Check to see if the computer's move is a valid one. If so, return true, otherwise, return false
        for (int row = 0; row < gameBoard.length; row++) {
            for (int col = 0; col < gameBoard.length; col++) {
                if (gameBoard[row][col] == computerMove) {
                    return true;
                }
            }
        }
        return false;
    }

    public static void printComputerChoice() {
        // Print information regarding what choice the computer made
        System.out.println("The computer chose the integer: " + computersChosenNum);
        System.out.println("The computer changed choice number:" + choiceToChange);
    }

    // -----------------------------------------------------------------------
    // --------------------- GETTING VALID USER INPUT ------------------------
    // -----------------------------------------------------------------------

    // Name: getUserInput
    // Purpose: Gets the number chosen for the player's next move
    public static void getUserChoice() {
        // Get and store the number choice from the user
        Scanner scnr = new Scanner (System.in);
        System.out.print("Input an integer between 1, and 9: ");
        playersChosenNum = scnr.nextInt();

        // Get and store the which choice (choice 1 or 2) the user wants to change
        System.out.print("Which choice do you want to change? (Choice 1, or 2?): ");
        choiceToChange = scnr.nextInt();

        validatePlayerInput();
    }

    // Name: validateUserInput
    // Purpose: Validate the user input (ensure it is an integer in the range 1 through 9)
    public static void validatePlayerInput() {
        // Edge case: on the first turn, the player must update the choice that doesn't have a value set to it yet (choice 2)
        if (choiceToChange == 1 && turnCount == 0) {
            System.out.println("Invalid Input! Choice 2 cannot be zero!\n");
            getUserChoice();
        }
        // Check if user's chosen number is within the proper range, 1-9 (inclusive)
        if (playersChosenNum < 1 || playersChosenNum > 9) {
            System.out.println("Invalid Input! " + playersChosenNum + " is out of bounds!\n");
            getUserChoice();
        }
        // Check if the choice to update is valid (either a 1, or a 2)
        if (choiceToChange != 1 && choiceToChange != 2) {
            System.out.println("Invalid Input! You must either pick choice 1, or choice 2!\n");
            getUserChoice();
        }

        if (turnCount !=0) {

            int playerMove;

            // Calculate what the player's move would be given its current number selections
            if (choiceToChange == 1) {
                playerMove = playersChosenNum * choice2;
            } else {
                playerMove = playersChosenNum * choice1;
            }

            boolean spaceIsTaken = true;

            // Check if the move is available to be made on the board
            for (int row = 0; row < gameBoard.length; row++) {
                for (int col = 0; col < gameBoard[row].length; col++) {
                    if (gameBoard[row][col] == playerMove) {
                        spaceIsTaken = false;
                    }
                }
            }

            if (spaceIsTaken) {
                System.out.println("That space is already taken! Please choose different inputs.");
                getUserChoice();

            } else {
                // If the user input is valid, update the choice the user wants to change with the new value
                if (choiceToChange == 1) {
                    choice1 = playersChosenNum;
                } else {
                    choice2 = playersChosenNum;
                }
            }
        }
    }

    // -----------------------------------------------------------------------
    // -------------------------- UPDATING GAME BOARD ------------------------
    // -----------------------------------------------------------------------

    // Name: calculateMoveAndUpdateBoard
    // Purpose: Updates the game board array with a new move that was made
    public static void calculateMoveAndUpdateBoard() {
        // Calculate the integer value of the next move on the board
        int nextMove = choice1 * choice2;

        // Loop through the game board until the value of the next move is found, and update it on the game board
        for (int row = 0; row < gameBoard.length; row++) {
            for (int col = 0; col < gameBoard[row].length; col++) {
                if (gameBoard[row][col] == nextMove) {
                    // Set the value of the gameBoard equal to the turnIndicator (-1 or -2)
                    gameBoard[row][col] = turnIndicator;
                }
            }
        }

        // Increment turnCount, print the move that was made
        turnCount++;
        System.out.println("Move made: " + choice1 + " * " + choice2 + " = " + nextMove);
    }

    // -----------------------------------------------------------------------
    // -------------------------- PRINT GAME BOARD ---------------------------
    // -----------------------------------------------------------------------

    // Name: printGameBoardAndChoices
    // Purpose: Prints the game board, and the numbers the player and computer selected.
    public static void printGameBoardAndChoices() {
        // Print out the game board
        System.out.println("+----+----+----+----+----+----+");

        for (int row = 0; row < gameBoard.length; row++) {
            for (int col = 0; col < gameBoard[row].length; col++) {

                if (gameBoard[row][col] == -1) {
                    System.out.print("|#PL#");
                }
                else if (gameBoard[row][col] == -2) {
                    System.out.print("|#CP#");
                }
                else if (gameBoard[row][col] < 10) {
                    System.out.print("| 0" + gameBoard[row][col] + " ");
                }
                else {
                    System.out.print("| " + gameBoard[row][col] + " ");
                }
            }
            System.out.println("|");
            System.out.println("+----+----+----+----+----+----+");
        }

        // Print out the player and computer choices
        System.out.println("Choice 1: " + choice1);
        System.out.println("Choice 2: " + choice2);
        System.out.println();
    }

    // -----------------------------------------------------------------------
    // -------------------------- WIN CHECKING -------------------------------
    // -----------------------------------------------------------------------

    // Name: checkWin
    // Purpose: Checks if either the player or computer have won
    public static void checkWin(){

        // Check for a horizontal win (4 in a row)
        int numOfConsecutiveRowMatches = 0;

        for (int row = 0; row < gameBoard.length; row++) {
            for (int col = 0; col < gameBoard[row].length; col++) {

                if (gameBoard[row][col] == turnIndicator) {
                    numOfConsecutiveRowMatches++;

                    if (numOfConsecutiveRowMatches == 4) {
                        printWinner();
                    }
                }
                else {
                    numOfConsecutiveRowMatches = 0;
                }
            }
        }

        // Check for a vertical win (4 in a column)
        int numOfConsecutiveColMatches = 0;

        for (int row = 0; row < gameBoard.length; row++) {
            for (int col = 0; col < gameBoard[row].length; col++) {

                if (gameBoard[row][col] == turnIndicator) {

                    for (int i = 0; i < (gameBoard.length - row); i++) {
                        if (gameBoard[row + i][col] == turnIndicator) {
                            numOfConsecutiveColMatches++;
                            if (numOfConsecutiveColMatches == 4) {
                                printWinner();
                            }
                        }
                        else {
                            numOfConsecutiveColMatches = 0;
                        }
                    }
                }
            }
        }

        // If no winner is found, update whose turn it is
        if (turnIndicator == -1) {
            turnIndicator = -2;
        }
        else {
            turnIndicator = -1;
        }
    }


    // Name: printWinner
    // Purpose: Print out a message for who won
    public static void printWinner() {

        if (turnIndicator == -1) {
            System.out.println("You won!");
        }

        if (turnIndicator == -2) {
            System.out.println("Computer won!");
        }

        System.exit(0);
    }
}
