.data
	.globl board
	.globl turnIndicator
	.globl turnCount
	.globl choice1
	.globl choice2
	.globl numRows
	.globl numCols
	.globl newline
	
	board:			.word 1, 2, 3, 4, 5, 6
					.word 7, 8, 9, 10, 12, 14,
					.word 15, 16, 18, 20, 21, 24
					.word 25, 27, 28, 30, 32, 35
					.word 36, 40, 42, 45, 48, 49
					.word 54, 56, 63, 64, 72, 81
	
	turnIndicator: 	.word -1		# Indicates whose turn it is (-1 = Player, -2 = Computer)
	turnCount: .word 0
	
	choice1: .word 0
    choice2: .word 0
    
    numRows: .word 6
	numCols: .word 6
	
	newline: .asciiz "\n"
	
	splashTitle: .asciiz "-------------------MARIO VS BOWSER MULTIPICATION GAME!-------------------\n"
	splashAuthor: .asciiz "Programmed by: Alex Countryman, Danielle Bryan, Raman Gupta, Satyam Garg\n"
	gameDescription: .asciiz "Help save princess peach by connecting 4 in a row before Bowser does!\n"
	
	gameStartMssg: .asciiz "*********** GAME START ************\n\n"
	
	playerTurnMssg: .asciiz "*********** YOUR TURN ************\n\n"

	compTurnMssg: .asciiz 	"********** BOWSERS TURN **********\n\n"
	
	tieGameMssg: .asciiz "TIE GAME! NOBODY WON!\n"
    
.text
	.globl main
	main:
		# Print the title of the game
		li $v0, 4
		la $a0, splashTitle
		syscall
		
		# Print out game authors
		la $a0, splashAuthor
		syscall
		
		la $a0, newline
		syscall
		
		# Print out game description
		la $a0, gameDescription
		syscall
		
		la $a0, newline
		syscall
		
		# Print out message indicating its the start of the game
		la $a0, gameStartMssg
		syscall
		
		# Get the computers choice, update, and print it out
		lw $s0, board   	
    	lw $s1, choice1
    	lw $s2, choice2
		jal getComputerChoice
    	jal updateComputerChoice
		
		# Print the game board & the choices
		la $s0, board
		lw $s1, numRows
		lw $s2, numCols
		jal printBoard
		jal printChoices
		
		gameLoop:
			# Print out message indicating its the players turn
			li $v0, 4
			la $a0, playerTurnMssg
			syscall
			
			# Get the player choice, update, and print it out
			lw $s0, board   	
    		lw $s1, choice1
    		lw $s2, choice2 
    		jal getUserChoice
    		jal updateUserChoices
    		jal printUserChoices
			
			# Calculate & update the next move on the game board
			jal movepusher
			jal printNextMove
			
			# Print the game board & the choices
			la $s0, board
			lw $s1, numRows
			lw $s2, numCols
			jal printBoard
			jal printChoices
			
			# Check for a win
			la $s0, board
			lw $s1, numRows
			lw $s2, numCols
			jal checkAllTilesForWin
			beq $v0, $t0, printWinner
			
			# change turnIndicator to the computer
			li $t0, -2
			sw $t0, turnIndicator
			
			# Increment turnCount by 1
			lw $t1, turnCount
			addi $t1, $t1, 1
			sw $t1, turnCount
			
			# Print out message indicating its the computers turn
			li $v0, 4
			la $a0, compTurnMssg
			syscall
			
			# Get the computers choice, update, and print it out
			lw $s0, board   	
    		lw $s1, choice1
    		lw $s2, choice2
			jal getComputerChoice
    		jal updateComputerChoice
			jal printComputerChoice
			
			# Calculate & update the next move on the game board
			jal movepusher
			jal printNextMove
			
			# Print the game board & the choices
			la $s0, board
			lw $s1, numRows
			lw $s2, numCols
			jal printBoard
			jal printChoices
			
			# Check for a win
			la $s0, board
			lw $s1, numRows
			lw $s2, numCols
			jal checkAllTilesForWin
			beq $v0, $t0, printWinner
			
			# Change turnIndicator to the player
			li $t0, -1
			sw $t0, turnIndicator
			
			# Increment turnCount by 1
			lw $t1, turnCount
			addi $t1, $t1, 1
			sw $t1, turnCount
			
			# Check for a tie game
			lw $t2, turnCount
			bne $t2, 36, continueGameLoop
			
				# Print tie game message
				li $v0, 4
				la $a0, tieGameMssg
				syscall
				
				# Terminate program execution
				li $v0, 10
				syscall
				
			continueGameLoop:
				j gameLoop
