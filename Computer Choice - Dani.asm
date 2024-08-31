.data
			
	newline: .asciiz "\n"
	CompCMsg: .asciiz "Bowser chose the integer: "
	CCMsg: .asciiz "Bowser changed choice number: "
	
	computersChosenNum: .word 0
    computersChoiceToChange: .word 0

.text 
.globl getComputerChoice
getComputerChoice:
	# Check if its the first turn or not
    lw $t9, turnCount
    bnez $t9, notFirstTurn
	
	# Generate random number
    li $v0, 42 
    li $a1, 9  # Sets the upper bound to 9 (exclusive)
    syscall	   # Generate random number 0 - 8
    addi $a0, $a0, 1 # Add 1 to random number generated
    
    move $t3, $a0	# Move contents of $a0 to $t3
    li $t4, 1      # choice1 = computers chosen number
    
    # Save to registers $t3 and $t4
    sw $t3, computersChosenNum
    sw $t4, computersChoiceToChange
    j endCompValidation

	notFirstTurn:
    	# computer choose a random number between 1 - 9
    	li $v0, 42
    	li $a1, 9
    	syscall
    	addi $a0, $a0, 1 # Add 1 to random number generated
    	move $t3, $a0

    	# randomly choose which choice it wants to change (1 or 2)
    	li $v0, 42
    	li $a1, 2
    	syscall
    	addi $a0, $a0, 1 # Add 1 to random number generated
    	move $t4, $a0

    	# comps chosen numbers are not valid, then run again
    	j validateComputerChoice

validateComputerChoice:
	# Calulate what the next move on the board would be, store it in $t6
    beq $t4, 2, compChangedChoiceTwo
        mul $t6, $t3, $s2
        j endCompIfElse
        
    compChangedChoiceTwo:
        mul $t6, $t3, $s1
		
    endCompIfElse:

    # Check to make sure the next move on the board is not taken
    li $t0, 0    # address of the item in our array we are checking
    li $t1, 0    # Loop Counter
    li $t2, 0	 # Item in our array we are checking

    checkIfTakenLoopComp:
        # Calculate address of next item in game board, store in $t2
        mul $t0, $t1, 4
        lw $t2, board($t0)

        # Check if $t2 is equal to $t6
        beq $t2, $t6, compChoicesValid
            
        # Increment Loop Counter
        addi $t1, $t1, 1

        # Loop until all elements in array are checked
        bne $t1, 36, checkIfTakenLoopComp
       		j getComputerChoice
       		
    compChoicesValid:
        # if the computer has chosen valid values, update the choices as needed
    	sw $t3, computersChosenNum
    	sw $t4, computersChoiceToChange
    	j endCompValidation
    
	endCompValidation:
    	jr $ra
    	
.globl updateComputerChoice    	
updateComputerChoice:	
    # Load the computers chosen number, and chosen choice to change from memory
	lw $t0, computersChosenNum
	lw $t1, computersChoiceToChange
    
    # Update choice 1 and choice 2 accordingly
    beq $t1, 1, updateComputerC1
    beq $t1, 2, updateComputerC2

	updateComputerC1:
    	sw $t0, choice1
    	j endUpdateComputerChoices

	updateComputerC2:
    	sw $t0, choice2

	endUpdateComputerChoices:
    	jr $ra
    	
.globl printComputerChoice 
printComputerChoice:
	# Print the number the computer chose
    li $v0, 4
    la $a0, CompCMsg
    syscall

    li $v0, 1
    lw $a0, computersChosenNum
    syscall
	
    li $v0, 4
    la $a0, newline
    syscall
	
	# Print the choice the computer changed
    li $v0, 4
    la $a0, CCMsg
    syscall

    li $v0, 1
    lw $a0, computersChoiceToChange
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    jr $ra
