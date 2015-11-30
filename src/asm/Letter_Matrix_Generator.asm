	.data
state_board:	.bytes 0, 0, 0, 0, 0, 0, 0, 0, 0		#letter matrix	
Hash_Map:	.space 26


		.text
InitBoard:	

		la $t0, Hash_Map	#initialize hash map
		li $t1, 0
		li $t2, 0
	Init_hash_map_for:
		add $t3, $t1, $t0
		sb $t2, ($t3)
		add $t1, $t1, 1
		bne $t1, 26, Init_hash_map_for
		

		addi $sp, $sp, -4	#make room on stack
		sw $ra, ($sp)
		
		li $t0, 0
		la $t1, state_board
	InitBoard_FOR:				#get 9 letters
		jal InitBoard_RNG		#get random letter
		
		add $a0, $v0, $zero
		jal InitBoard_HASH		#hash letter
		
		
		add $t2, $t1, $t0	#store letter
		sb $v0, ($t2)
		
		addi $t0, $t0, 4	#loop control
		bne $t0, 36, InitBoard_FOR
#End for loop
			
		lw $ra, ($sp)		#restore stack
		addi $sp, $sp, 4
	
	
		jr $ra



	InitBoard_RNG:
		li $v0, 41		#get random number
		syscall
		srl $a0, $a0, 26	#divide to within 0-31
		
		slti $t2, $a0, 26	#if the result is greater than 25, try again
		beq $t2 $zero, InitBoard_RNG
	
		add $v0, $a0, $zero	#put random number in $v0
		jr $ra
	
	
	
	InitBoard_HASH:
		la $t2, Hash_Map
	InitBoard_WHILE:
		add $t3, $a0, $zero
		add $t3, $t3, $t2	#get current byte
		
		lb $t4, ($t3)
		beq $t4, $zero, InitBoard_VALID	#check if byte is used
		
		beq $a0, 26, InitBoard_WRAP	#check if needs to wrap back to 0
		addi $a0, $a0, 1
		j InitBoard_NO_WRAP
	InitBoard_WRAP:
		sub $a0, $a0, 26
	InitBoard_NO_WRAP:	
		j InitBoard_WHILE
	InitBoard_VALID:	
		li $t4, 1
		sb $t4, ($t3)		#mark letter as used
		addi $v0, $a0, 97	#final letter
		
		jr $ra

