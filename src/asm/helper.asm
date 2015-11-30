.data 

word:  .byte 's', 'l','p','p','e','e', 'a','m','t'
word1: .asciiz  "please", "apple", "maple", "team", "teams", "peas", "mats", "palm", "tame", "else","tapes","pets", "slap", "maps", "amps", "teal","steal", "steel", "plate","plates", "meat","meet", "meets", "steam", "pale","stale", "metal"
word2: .asciiz " Please  "
word3: .asciiz "metals"
word4: .asciiz "apple please"
word5: .space 1000

.text



la $a0, word2
jal normalization
move $t7, $v0
move $t8, $v1

li $v0, 1
add $a0, $t8, $zero
syscall

li $v0, 11
addi $a0, $zero, 10
syscall

li $v0, 4
add $a0, $zero, $t7
syscall 

exitF: li $v0, 10
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
	addi $t2, $zero, 0
	addi $t2, $t6, 0

loopLength: lb $t3, 0($t2)
	    beq $t3, $zero, exit
	    addi $t1, $t1, 1
	    addi $t2, $t2, 1
	    j loopLength
	   
exit:

addi $v1, $t1, 0

jr $ra





	