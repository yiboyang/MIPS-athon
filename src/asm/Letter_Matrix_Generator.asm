	.data
	
Map:	.space 104		#hash map
Result:	.space 36		#letter matrix

	.text
GEN_MATRIX:
	addi $sp, $sp, -4	#make room on stack
	sw $ra, ($sp)
	
	li $t0, 0
	la $t1, Result
FOR_GEN:				#get 9 letters
	jal RNGALPHA		#get random letter
	
	add $a0, $v0, $zero
	jal HASHALPHA		#hash letter
	
	add $t2, $t1, $t0	#store letter
	sw $v0, ($t2)
	
	addi $t0, $t0, 4	#loop control
	bne $t0, 36, FOR_GEN
#End for loop
			
	lw $ra, ($sp)		#restore stack
	addi $sp, $sp, 4
	
	
	jr $ra



RNGALPHA:
	li $v0, 41		#get random number
	syscall
	srl $a0, $a0, 26	#divide to within 0-31
	
	slti $t2, $a0, 26	#if the result is greater than 25, try again
	beq $t2 $zero, RNGALPHA
	
	add $v0, $a0, $zero	#put random number in $v0
	jr $ra
	
	
	
HASHALPHA:
	la $t2, Map
WHILE_HASH:
	sll $t3, $a0, 2
	add $t3, $t3, $t2	#get current byte
	
	lw $t4, ($t3)
	beq $t4, $zero, VALID_HASH	#check if byte is used
	
	beq $a0, 26, WRAP	#check if needs to wrap back to 0
	addi $a0, $a0, 1
	j NO_WRAP
WRAP:
	sub $a0, $a0, 26
NO_WRAP:	
	j WHILE_HASH
VALID_HASH:	
	li $t4, 1
	sw $t4, ($t3)		#mark letter as used
	add $v0, $a0, $zero	#final letter
	
	jr $ra
