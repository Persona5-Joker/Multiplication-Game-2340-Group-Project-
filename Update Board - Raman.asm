.data
	
	nextMoveMssg: .asciiz "Next Move: "
	multSign: .asciiz " * "
	equalSign: .asciiz " = "
	
	nextMove: .word 0

.text
.globl movepusher
movepusher: # code runs top to bottom will reach jr $ra at bottom eventually going through other labels
	# calling a method isolated calculation doesn't matter what used to be in temporary registers
	lw $t0, choice1 # pull using label into temporary register
	lw $t1, choice2 # pull using label into temporary register
	
	# allows saving product to register unlike mult
	mul $t2, $t0, $t1 # $t2 destination register
	sw $t2, nextMove
	
	li $t3, 0 # loop counter
	li $t4, 0 # store address in array being checked
	li $t5, 0 # store item at address we are checking
	
	crunchloop: # labels are to branch or jump to
	# calculate address of item we are trying to get
	mul $t4, $t3, 4 # 4 bit increment because the integers are stored as 4 bits
	lw $t5, board($t4) # use label / $t4 acts a lot like an offset given how the code is written
	
	beq $t2, $t5, leapexit
	addi $t3, $t3, 1 # take $t3 and add 1 and put it back into itself as the destination
	bne $t3, 36, crunchloop # loop counter not equal to 36
	j trueexit
	
	leapexit: # leap to exit
	# set value of space of gameboard we are accessing
	lw $t6, turnIndicator # load value of turn indicator into $t6
	sw $t6, board($t4) # store value of turn indicator at address of number that is selected as part of code
	
	trueexit:
	jr $ra # jump to previously saved register

.globl printNextMove
printNextMove:
	# Prints the calculation for the next move made on the board
	li $v0, 4
	la $a0, nextMoveMssg
	syscall
	
	li $v0, 1
	lw $a0, choice1
	syscall
	
	li $v0, 4
	la $a0, multSign
	syscall
	
	li $v0, 1
	lw $a0, choice2
	syscall
	
	li $v0, 4
	la $a0, equalSign
	syscall
	
	li $v0, 1
	lw $a0, nextMove
	syscall
	
	li $v0, 4
	la $a0, newline
	syscall
	
	jr $ra
