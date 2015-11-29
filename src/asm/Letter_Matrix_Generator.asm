	.data
state_board:	.bytes 0, 0, 0, 0, 0, 0, 0, 0, 0		#letter matrix	

#start copying here
	.data
Map:	.space 26		#hash map

	.text
GEN_MATRIX:
	addi $sp, $sp, -4	#make room on stack
	sw $ra, ($sp)
	
	li $t0, 0
	la $t1, state_board
GEN_MATRIX_FOR:				#get 9 letters
	jal RNGALPHA		#get random letter
	
	add $a0, $v0, $zero
	jal HASHALPHA		#hash letter
	
	add $t2, $t1, $t0	#store letter
	sb $v0, ($t2)
	
	addi $t0, $t0, 4	#loop control
	bne $t0, 36, GEN_MATRIX_FOR
#End for loop
			
	lw $ra, ($sp)		#restore stack
	addi $sp, $sp, 4
	
	
	jr $ra



GEN_MATRIX_RNG:
	li $v0, 41		#get random number
	syscall
	srl $a0, $a0, 26	#divide to within 0-31
	
	slti $t2, $a0, 26	#if the result is greater than 25, try again
	beq $t2 $zero, GEN_MATRIX_RNG
	
	add $v0, $a0, $zero	#put random number in $v0
	jr $ra
	
	
	
GEN_MATRIX_HASH:
	la $t2, Map
GEN_MATRIX_WHILE:
	add $t3, $a0, $zero
	add $t3, $t3, $t2	#get current byte
	
	lb $t4, ($t3)
	beq $t4, $zero, GEN_MATRIX_VALID	#check if byte is used
	
	beq $a0, 26, GEN_MATRIX_WRAP	#check if needs to wrap back to 0
	addi $a0, $a0, 1
	j GEN_MATRIX_NO_WRAP
GEN_MATRIX_WRAP:
	sub $a0, $a0, 26
GEN_MATRIX_NO_WRAP:	
	j GEN_MATRIX_WHILE
GEN_MATRIX_VALID:	
	li $t4, 1
	sb $t4, ($t3)		#mark letter as used
	add $v0, $a0, $zero	#final letter
	
	jr $ra
