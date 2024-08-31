.data
	playerWinMssg:	.asciiz "CONGRATULATIONS! MARIO WON, YOU SAVED THE PRINCESS!\n"
	compWinMssg:	.asciiz	"OH NO! BOWSER WON! THE PRINCESS HAS BEEN KIDNAPPED!\n"

.text				
	.globl checkAllTilesForWin	
	checkAllTilesForWin:
		lw $t0, turnIndicator		# turnIndicator value (-1 or -2)
		li $t1, 0					# Row index in the list we are checking
		li $t2, 0					# Column index in the list we are checking
		
		rowLoop:
			blt $t1, $s1, colLoop		# If row < numRows, then branch to the inner column loop
			li $v0, 0					# Set $v0 to 0 (No win in a row was found)
			j rowLoopEnd				# Exit loop
		
			colLoop:
				# Get the element of the array at board[row][col] into $t4
				# address = baseAddr + (rowIndex * numCols + colIndex) * dataSize
				
				mul $t3, $t1, $s2						# Set t3 to row index * numCols
				add $t3, $t3, $t2						# Adds the colIndex to $t3
				sll $t3, $t3, 2							# Multiplies $t3 by the size of our data (integers, 4 bits)
				add $t3, $t3, $s0						# Adds the base address of the game board to $t3
				
				lw $t4, ($t3)							# Get the element stored at the first address calculated in $t3 into $t4
				
				bne $t4, $t0, notEqualToTurnIndicator	# If ($t4 == turnIndicator):
					
					# Check for a win within a row
					
					bgt $t2, 2, noRowWin				# If (col <= 2):		
						sw $ra, 4($sp)					# Store the address of $ra on stack
						
						la $a0, ($t3)					# Set $a0 to the address of the tile we are checking ($t3)
						li $a1, 4						# Set $a1 to the increment amount, (1 * 4 = 4)
						jal checkWin					# Call checkWin subroutine
						
						lw $ra, 4($sp)					# Restore the old address of $ra from stack
						beq $v0, $t0, rowLoopEnd		# If ($v0 == turnIndicator), exit method
						
					noRowWin:	
					
					# Check for a win within a column
					
					bgt $t1, 2, noColWin				# If (row <= 2):							
						sw $ra, 4($sp)					# Store the address of $ra on stack
						
						la $a0, ($t3)					# Set $a0 to the address of the tile we are checking ($t3)
						li $a1, 24						# Set $a1 to the increment amount, (6 * 4 = 24)
						jal checkWin					# Call checkWin subroutine
						
						lw $ra, 4($sp)					# Restore the old address of $ra from stack
						beq $v0, $t0, rowLoopEnd		# If ($v0 == turnIndicator), exit method
						
					noColWin:	
					
					# Check for a win within a right diagonal
					
					bgt $t1, 2, noRightDiagonalWin		# If (row <= 2):
					bgt $t2, 2, noRightDiagonalWin		# If (col <= 2):
						sw $ra, 4($sp)					# Store the address of $ra on stack
						
						la $a0, ($t3)					# Set $a0 to the address of the tile we are checking
						li $a1, 28						# Set $a1 to the increment amount, (7 * 4 = 28)
						jal checkWin					# Call checkWin subroutine
						
						lw $ra, 4($sp)					# Restore the old address of $ra from stack
						beq $v0, $t0, rowLoopEnd		# If ($v0 == turnIndicator), exit method
					
					noRightDiagonalWin:	
					
					# Check for a win within a left diagonal
					
					bgt $t1, 2, noLeftDiagonalWin		# If (row <= 2):
					blt $t2, 3, noLeftDiagonalWin		# If (col >= 3):
						sw $ra, 4($sp)					# Store the address of $ra on stack
						
						la $a0, ($t3)					# Set $a0 to the address of the tile we are checking
						li $a1, 20						# Set $a1 to the increment amount, (5 * 4 = 20)
						jal checkWin					# Call checkWin subroutine
						
						lw $ra, 4($sp)					# Restore the old address of $ra from stack
						beq $v0, $t0, rowLoopEnd		# If ($v0 == turnIndicator), exit method
						
					noLeftDiagonalWin:
					
				notEqualToTurnIndicator:	
				
				# Check to see if the inner loop for the columns needs to be run again
				
				addi $t2, $t2, 1			# Increment the column index in list we are checking $t1 (col = col + 1)
				blt $t2, $s2, colLoop		# If col < numCols, then loop the inner loop again
				
				# Reset variables, jump to outer loop for the rows
				
				addi $t1, $t1, 1			# Increment row = row + 1
				li $t2, 0					# reset col = 0
				j rowLoop					# Jump to the outer loop
		
		rowLoopEnd:
			jr $ra
		
	# ----------------------------------------------------------------------------------------------
	
	checkWin:
		
		li $t4, 0		# checkWin loopCounter
		li $t5, 0 		# Stores the address of the game board space we are checking
		li $t6, 0 		# Stores the word at the address of the game board space we are checking
		
		checkWinLoop:
			
			addi $t4, $t4, 1				# Increment the loopCounter
			mul $t5, $a1, $t4				# Store the amount to increment (increment * loopCounter) in $t5
			add $t5, $t5, $a0				# Add the starting address to (increment * loopCounter)
			lw $t6, ($t5)					# Load the word found at the calculated address in $t6
			
			bne $t6, $t0, noWinnerFound		# If (board[startingIndex + (increment * loopCounter] == turnIndicator
			beq $t4, 3, winnerFound			# If (loop counter == 3), a winner is found
				j checkWinLoop				# Run checkWinLoop again
		
		winnerFound:
			la $v0, ($t0)					# Set the contents of $v0 to the turnIndicator
			
		noWinnerFound:
			jr $ra
	
	# ----------------------------------------------------------------------------------------------
	.globl printWinner
	printWinner:
		
		beq $t0, -2, computerWin			# If $t0 equals -2, the computer won. Otherwise, the player won
			la $a0, playerWinMssg			# Load the address of the playerWinMessage into $a0 for output
			j printWinMssg					# Jump to the end of the if/else statement
		
		computerWin:						
			la $a0, compWinMssg				# Load the address of the computerWinMessage into $t0 for output
		
		printWinMssg:
			li $v0, 4						# Load service number for printing a string into $v0
			syscall							# Syscall to print out the win message
			
			li $v0, 10						# Load service number 10 into $v0
			syscall							# Terminate program execution
