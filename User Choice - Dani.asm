.data
	promptUserInput: .asciiz "Input a number between 1 and 9: "
	promptUserInputChoice: .asciiz "Which choice should we change? (1 or 2): "

    choiceTwoInvalidMssg: .asciiz "Invalid input! Choice 2 cannot be zero!\n\n"
	chosenNumberInvalidMssg: .asciiz "Invaild input! Number choice out of Bounds!(1-9)\n\n"
    invalidChoiceMssg: .asciiz "Invalid input! You must choose either 1 or 2!\n\n"
    spaceIsTakenMssg: .asciiz "That space is already taken! Please choose different inputs.\n\n"
    
    numOutputMssg: .asciiz "\nYou chose the number: "
    choiceOutputMssg: .asciiz "You chose to update choice: "
    
    playersChosenNum: .word 0
    playerChoiceToChange: .word 0
    
.text
.globl getUserChoice
getUserChoice:
    # Prompt user to input their chosen number (1 - 9)
    li $v0, 4 
    la $a0, promptUserInput
    syscall

    # Read input from user, store it in $t0
    li $v0, 5
    syscall
    move $t0, $v0
    
    # Prompt user to input the choice they want to change (choice 1 or 2)
    li $v0, 4
    la $a0 promptUserInputChoice
    syscall
    
    # Read input from the user, store it in $t1
    li $v0, 5
    syscall
    move $t1, $v0
    
    j validateUserChoice

validateUserChoice:
	# Check if the player's chosen number is within range (1-9)
    checkChosenNumber:
    	blt $t0, 1, chosenNumberInvalid
    	bgt $t0, 9, chosenNumberInvalid

    # Check if it's the first turn, and choice 2 is zero
    checkChoicesOnFirstTurn:
    	beq $t1, 1, checkIfFirstTurn # If choice to change is 1
        	j checkChoiceToChange
        	checkIfFirstTurn:
            	beqz $s2, edgeCaseFailed

    # Check to see if the choice we're updating is valid (either choice 1 or 2)
    checkChoiceToChange:
    	beq $t1, 1, checkIfMoveIsAvailable
    	beq $t1, 2, checkIfMoveIsAvailable
        	j invalidChoice
	
	# Check to ensure the move can be made on the board
    checkIfMoveIsAvailable:
    	beqz $s1, userChoicesValid
        
    # Calulate what the next move on the board would be, store it in $t2
    	beq $t1, 2, userChangedChoiceTwo
        	mul $t2, $t0, $s2
        	j endUserIfElse

    	userChangedChoiceTwo:
        	mul $t2, $t0, $s1
		
    	endUserIfElse:
    	
    	# Check to make sure the next move on the board is not taken
    	li $t3, 0    # address of the item in our array we are checking
    	li $t4, 0    # Loop Counter
    	li $t5, 0	 # Item in our array we are checking

    	checkIfTakenLoopUser:
        	# Calculate address of next item in game board, store in $t5
        	mul $t3, $t4, 4
        	lw $t5, board($t3)

        	# Check if $t5 is equal to $t2
        	beq $t5, $t2, userChoicesValid
            
        	# Increment Loop Counter
        	addi $t4, $t4, 1

        	# Loop until all elements in array are checked
        	bne $t4, 36, checkIfTakenLoopUser
       			j choicesAreTaken

	edgeCaseFailed:
    	# Print the invalid choice 2 error message
    	li $v0, 4
    	la $a0, choiceTwoInvalidMssg
		syscall

		# Prompt user to pick input again
		j getUserChoice

	chosenNumberInvalid:
    	# Print the bound error message
    	li $v0, 4
    	la $a0, chosenNumberInvalidMssg
    	syscall

    	# Prompt user to pick input again
    	j getUserChoice

	invalidChoice:
    	# Print the error message for an invalid choice
    	li $v0, 4
    	la $a0, invalidChoiceMssg
    	syscall

    	# Prompt user to pick input again
    	j getUserChoice

	choicesAreTaken:
    	# Print the error message if a space is taken on the board
    	li $v0, 4
    	la $a0, spaceIsTakenMssg
    	syscall
        
        # Prompt user to pick input again
    	j getUserChoice

	userChoicesValid:
    	sw $t0, playersChosenNum
    	sw $t1, playerChoiceToChange
    	j endValidation

	endValidation:
    	jr $ra

.globl updateUserChoices   	
updateUserChoices:
	# Load the players chosen number, and chosen choice to change from memory
	lw $t0, playersChosenNum
	lw $t1, playerChoiceToChange
	
	# Update choice 1 and choice 2 accordingly
	beq $t1, 1, updateUserC1
    beq $t1, 2, updateUserC2
    
    updateUserC1:
    	sw $t0, choice1
    	j endUpdateUserChoices
    	
    updateUserC2:
    	sw $t0, choice2
    	
    endUpdateUserChoices:
    	jr $ra

.globl printUserChoices
printUserChoices:
	# Print the number the user chose
    li $v0, 4
    la $a0, numOutputMssg
    syscall
    
    li $v0, 1
    lw $a0, playersChosenNum
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    # Print the choice the user changed
    li $v0, 4
    la $a0, choiceOutputMssg
    syscall
    
    li $v0, 1
    lw $a0, playerChoiceToChange
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall

    jr $ra
