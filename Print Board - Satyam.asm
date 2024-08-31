.data				
	line:			.asciiz "|"
	space:			.asciiz " "
	border:			.asciiz "+----+----+----+----+----+----+\n"
	PlayerIcon: 	.asciiz "#MM#"
	ComputerIcon: 	.asciiz "#BB#"
	Choice1Word: 	.asciiz "Choice 1: "
	Choice2Word: 	.asciiz "\nChoice 2: "

.text
	.globl printBoard	
	printBoard:
		li $t1, 0							# Row index for game board
		li $t2, 0							# Col index for game board

		rowLoop:		
			li $v0, 4						# Service number for printing string into $v0
			la $a0, border					# Loads the horizontal border into $a0
			syscall 						# Print out the horizontal border before each row

			blt $t1, $s1, colLoop			# If row < numRows, then branch to the inner column loop
			j rowLoopEnd					# Exit loop
		
			colLoop:
				mul $t3, $t1, $s2			# Set t3 to row index * numCols
				add $t3, $t3, $t2			# Adds the colIndex to $t3
				sll $t3, $t3, 2				# Multiplies $t3 by the size of our data (integers, 4 bits)
				add $t3, $t3, $s0			# Adds the base address of the game board to $t3

				lw $t4, ($t3)				# Get the element stored at the first address calculated in $t3 into $t4
				
				# Print out a vertical line
				li $v0, 4 					# Service number for printing string into $v0
				la $a0, line				# Move the line string into $a0
				syscall						# Print out a vertical line
				
				# Check if space on the board equals -1
				beq $t4, -1, PlayerEqualsNegativeOne
					j FailedNegativeOneCheck	# If value not -1 then jump to check if the space has a -2

				PlayerEqualsNegativeOne:
					li $v0, 4				# Service number for printing integer into $v0
					la $a0, PlayerIcon		# Adds a 0 before single digit numbers
					syscall 				# Print out a 0 before single digit numbers
					j IfElseEnd				#skip rest of code to the end of the loop

				FailedNegativeOneCheck:
				
				# Check if space on the board equals -2
				beq $t4, -2, ComputerEqualsNegativeTwo
					j FailedNegativeTwoCheck

				ComputerEqualsNegativeTwo:
					li $v0, 4				# Service number for printing integer into $v0
					la $a0, ComputerIcon	# Adds a 0 before single digit numbers
					syscall 				# Print out a 0 before single digit numbers
					j IfElseEnd				#skip rest of code to the end of the loop

				FailedNegativeTwoCheck:
				
				# Print out a space	
				li $v0, 4 					# Load service number for printing an string into $v0
				la $a0, space				# Move the line string into $a0 for output
				syscall						# Syscall to print out a line
				
				# If space on board not -1 or -2, check if it's a single-digit number
				bge $t4, 10, GreaterThan10
				
					# Print out a zero
					li $v0, 1				# Service number for printing integer into $v0
					li $a0, 0				# Adds a 0 before single digit numbers
					syscall 				# Print out a 0 before single digit numbers
					
					# Print out the number
					addi $a0, $t4, 0		# Move the element in the array stored at $t4 to $a0 for output
					syscall					# Print out a number in the board
					
					# Print out a space	
					li $v0, 4 				# Load service number for printing an string into $v0
					la $a0, space			# Move the line string into $a0 for output
					syscall					# Syscall to print out a line
				
					j IfElseEnd				# Skip to end of loop

				GreaterThan10: 
					# Print out the number
					li $v0, 1				# Service number for printing integer into $v0
					addi $a0, $t4, 0		# Move the element in the array stored at $t4 to $a0 for output
					syscall					# Print out a number in the board
					
					# Print out a space	
					li $v0, 4 				# Service number for printing string into $v0
					la $a0, space			# Move the line string into $a0 for output
					syscall					# Syscall to print out a line
				
				IfElseEnd:

				# Check to see if the inner loop for the columns needs to be run again
				
				addi $t2, $t2, 1			# Increment the column index in list we are checking $t1 (col = col + 1)
				blt $t2, $s2, colLoop		# If col < numCols, then loop the inner loop again
				
				#Print end bar of each row
				li $v0, 4 					# Load service number for printing an string into $v0
				la $a0, line				# Move the line string into $a0 for output
				syscall						# Syscall to print out the win message

				# Print out a newline
				li $v0, 4 					# Load service number for printing an integer into $v0
				la $a0, newline				# Move the newline string into $a0 for output
				syscall						# Syscall to print out the win message
				
				# Reset variables, jump to outer loop for the rows
				addi $t1, $t1, 1			# Increment row = row + 1
				li $t2, 0					# reset col = 0
				j rowLoop					# Jump to the outer loop
		
		rowLoopEnd:
			jr $ra
	
	.globl printChoices
	printChoices:
		li $v0, 4						# Service number for printing string into $v0 
		la $a0, Choice1Word				# Adds the border before each row
		syscall 						# Print out the border before each row

		li $v0, 1						# Service number for printing integer into $v0
		lw $a0, choice1					# Adds the border before each row
		syscall 						# Print out the border before each row

		li $v0, 4						# Service number for printing string into $v0
		la $a0, Choice2Word				# Adds the border before each row
		syscall 						# Print out the border before each row

		li $v0, 1						# Service number for printing integer into $v0
		lw $a0, choice2					# Adds the border before each row
		syscall 						# Print out the border before each row
		
		li $v0, 4						# Service number for printing string into $v0
		la $a0, newline					# Loads newline character into $a0 for output
		syscall							# Print out a newline character
		syscall							# Print out another newline character

		jr $ra
