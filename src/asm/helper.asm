.data 

word:  .byte 's', 'l','p','p','e','e', 'a','m','t'
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

move $a0, $t1
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
loop:	    lb $t3, 0($t2)
	    beq $t3, $zero, exit
	    addi $t1, $t1, 1
	    addi $t2, $t2, 1
	    j loop
	   
exit:	    addi $v0, $t1, 0
	    jr $ra



correctLength:
 		bge $a0, 10, else1
 		ble $a0, 3, else2
 		addi $t0, $zero, 9
 		sub $t0, $t0, $a0
 	        addi $t1, $a0, 0 #length of string
	        addi $t2, $a1, 0 # address of string		
	        add $t2, $t2, $t1
	        addi $t3, $zero, 32
jump:           beq $t0, 0, else3
		lb $t3, ($t2)
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
				

	
