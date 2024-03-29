.data 

word:  .byte 's', 'l','p','p','e','e', 'a','m','t'
sol_num: .word 27
word1: .asciiz  "please   ", "apple    ", "maple    ", "team     ", "teams    ", "peas     ", "mats     ", "palm     ",
 "tame     ", "else     ","tapes    ","pets     ", "slap     ", "maps     ", "amps     ", "teal     ","steal    ", "steel    ", 
 "plate    ","plates   ", "meat     ","meet     ", "meets    ", "steam    ", "pale     ","stale    ", "metal    "
word2: .asciiz " Please  "
word3: .asciiz "metals"
word4: .asciiz "apple please"
word5: .space 1000

.text



la $a0, word2
jal normalization
move $t7, $v0

li $v0, 4
add $a0, $zero, $t7
syscall

li $v0, 11
addi $a0, $zero, 10
syscall

add $a0, $t7, $zero
jal loopLength
move $t8, $v0

li $v0, 1
add $a0, $t8, $zero
syscall

li $v0, 11
addi $a0, $zero, 10
syscall

move $a0, $t8
move $a1, $t7

jal correctLength

move $t0, $v0
move $t1, $v1
beq $t0, 1, exitF

li $v0, 4
add $a0, $t1, 0
syscall

li $v0, 11
addi $a0, $zero, 10
syscall

add $a0, $t1, $zero
jal loopLength
move $t8 , $v0


li $v0, 1
add $a0, $t8, $zero
syscall



exitF:
li $v0, 10
syscall



normalization:
la $t5, word5
addi $t6, $t5, 0 #to return the pointer to the first character
addi $t1, $zero, 0 #to contain the length
addi $t2, $a0, 0 #pointer to the first character of word2

toLowerCase: lb $t4, 0($t2)
	     beq $t4, $zero, exit2
	     beq $t4, 32 , removeSpace
	     bge $t4, 97, noChange
	     ble $t4, 90, goChange
	      

removeSpace: addi $t2, $t2, 1
	     j toLowerCase

goChange: addi $t4, $t4, 32
	  sb $t4, ($t5)
	  addi $t5, $t5, 1
	  addi $t2, $t2, 1
	  j toLowerCase
	  
noChange: sb $t4, ($t5)
	  addi $t5, $t5, 1
	  addi $t2, $t2, 1
	  j toLowerCase	  		

exit2:	sb $t4, ($t5)
	move $v0, $t6
	jr $ra
	
	

loopLength: addi $t2, $zero, 0
	    addi $t2, $a0, 0
	    addi $t1, $zero,0
loop:	    lb $t3, 0($t2)
	    beq $t3, $zero, exit
	    addi $t1, $t1, 1
	    addi $t2, $t2, 1
	    j loop
	   
exit:	    addi $v0, $t1, 0
	    jr $ra


# returns 0 in $v0 when the string is between 4 and 9 in length
#returns the start address of the string that has been padded with white spaces
#the string returned is 9 in length
correctLength:
 		bge $a0, 10, else1
 		ble $a0, 3, else2
 		addi $t0, $zero, 9
 		sub $t0, $t0, $a0
 	        addi $t1, $a0, 0 #length of string
	        addi $t2, $a1, 0 # address of string		
	        add $t2, $t2, $t1
	        addi $t3, $zero, 32 #the place where spaces are to be replaced by null characters
jump:           beq $t0, 0, else3
		sb $t3, ($t2)
	        addi $t0, $t0, -1
	        addi $t2, $t2, 1
	        j jump
	        
else3:		addi $v0, $zero, 0
		addi $v1, $a1, 0
		j result
		
else2: 		addi $v0, $zero, 1
		addi $v1, $a1, 0
		j result

else1: 		addi $v0, $zero, 1
		addi $v1, $a1, 0
		j result
		
result: 	jr $ra
				


findReplace: 	addi $t8, $zero, 0
		la $t8, sol_num
		lw $t9, ($t8)
		addi $a0, $t0, 0 # the address of the string to be compared
		la $t1, word1 # address of the string array
		addi $t4, $t0, 0# to preserve the address of string 
		addi $t5, $zero, 0 #to keep track of 10
		
Outer:		beq $t9, $zero, exitFind		
loopA:		beq $t5, 10, elseB
		lb $t3, ($t0)
		lb $t2, ($t1)
		bne $t2, $t3, elseA
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		addi $t5, $t5, 1
		j loopA
	
elseB: 		addi $t0, $t4, 0 #moving string pointer to the beginning
		sub $t9, $t9, 1
		j Outer
		
elseA:		addi $v0, $zero, 0
		j exitFind
		
exitFind: 	