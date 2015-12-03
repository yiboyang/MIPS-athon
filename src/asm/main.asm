		.data
session_msg:	.asciiz "\nDo you want to (start) a new game or (exit)? "
session_err:	.asciiz "\nInvalid choice: "
session_affirm:	.asciiz "start\n"
session_deny:	.asciiz "exit\n"
round_msg:	.asciiz "\nEnter another word: "
round_err:	.asciiz "\nInvalid word: "
exit_msg:	.asciiz "\nThanks for playing!"
exit_request:	.asciiz "idk\n"
state_score:	.word 0
state_PrevTime:	.word 0
state_RemTime:	.word 0
state_board:	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0
round_time:	.word 30000

gridChars:	.space 26			# boolean array keeping track of which chars are present in grid
temp:		.space 26			# temporary copy of gridChars; reinitailized to gridChars each round
buffer: 	.space 10			# use buffer size that is the size of an entry
file:		.asciiz	"?.txt"			# the "?" is just a placeholder for a char to be overwritten
solution:	.space 3000			# assume max 300 solution entries (each has length 10 including null char)
numSol:		.word 0

prompt_buf:	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

Hash_Map:	.space 26			#hash map of used letters

		.align 4
		.text
main:		j Session

###
# Compare the strings ($a0) and ($a1).
#
# Returns 0 on equality, -1 for ($a0)<($a1), and 1 for ($a0)>($a1)
###
CompStr:	li $t2, 0
CompStr_Loop:	add $t0, $a0, $t2
		add $t1, $a1, $t2
		lb $t0, 0($t0)
		lb $t1, 0($t1)
		blt $t0, $t1, CompStr_LT
		blt $t1, $t0, CompStr_GT
		beq $t0, $t1, CompStr_EQ
CompStr_LT:	li $v0, -1
		jr $ra
CompStr_GT:	li $v0, 1
		jr $ra
CompStr_EQ:	addi $t2, $t2, 1
		bne $t0, $0, CompStr_Loop
		li $v0, 0
		jr $ra

###
# Prompt user for string input
#
# Prints string ($a0) and places user input in ($v0). Does not allow user input
# beyond 10 characters, and a newline will be appended unless the user inputs
# 10 characters
###
Prompt:		li $v0, 			 # print string ($a0)
		syscall
		la $a0, prompt_buf
		li $a1, 11
		li $v0, 8 # read string to ($a0) of length <= $a1-1
		syscall
		add $v0, $a0, $zero		#move string to $v0
		jr $ra

###
# Main program loop
#
# Not a subroutine!
###
Session:	la $a0, session_msg
		jal Prompt			# Prompt for start or exit
		move $a0, $v0
		la $a1, session_affirm
		jal CompStr			# Check is input is start
		beq $v0, $0, InitRound		# if so, start the round
		la $a1, session_deny
		jal CompStr			# else check for exit
		beq $v0, $0, Exit		# if so, exit
		la $a0, session_err
		li $v0, 4
		syscall				# else, print error
		j Session			# and jump to input

Exit:		la $a0, exit_msg
		li $v0, 4
		syscall				# Print exit message
		li $v0, 10
		syscall				# system exit

InitRound:	jal InitState
		jal DspState
		j Round

Round:		la $a0, round_msg
		jal Prompt			# ask user for word
		move $a0, $v0

		la $a1, exit_request		#checks if user is exiting early
		jal CompStr
		beq $v0, $zero, End

		jal ScoreWord			# score the word
		move $t0, $v0			# temp save score
		bne $v0, $0, Round_Upd		# Check if score is 0
		la $a0, round_err
		li $v0, 4
		syscall				# if so, print error
Round_Upd:	move $a0, $t0
		jal UpdateState			# update the game state
		blt $v0, $0, EndRound		# end if no time remaining
		jal DspState			# else display updates stat
		j Round				# and go back to user input

EndRound:	jal DspResult			# display the user's results
		jal DspSol			# display all solutions
		j Session

###
# Updates the current state of the game
# Points@$a0 -> RemainingTime@$v0
# The points passed to the method are directly awarded to the player
###
UpdateState:	beq $a0, $0, UpdateState_ElapsedTime

		la $t0, state_score
		lw $t1, 0($t0)			# $t1 has player's score
		add $t1, $t1, $a0		# add in new points
		sw $t1, 0($t0)			# store new score
		# Score updated

		la $t0, state_RemTime
		lw $t1, 0($t0)
		addi $t1, $t1, 20000
		sw $t1, 0($t0)

UpdateState_ElapsedTime:
		la $t0, state_PrevTime
		lw $t1, 0($t0)			# $t1 has previous update time
		li $v0, 30
		syscall				# get current time
		sw $a0, 0($t0)			# save current update time
		sub $t1, $a0, $t1		# $t1 has elapsed time since last update
		la $t2, state_RemTime
		lw $t3, 0($t2)			# $t2 has remaining time from previous update
		sub $v0, $t3, $t1		# $v0 has new remaining time
		sw $v0, 0($t2)

		jr $ra

###
# Initializes the entire game state in preparation for a new round.
# none -> none
# Assumes state_[score|start|time|board] exist
###
InitState:	addi $sp, $sp, 4
		sw $ra, 0($sp)
		jal InitBoard			# get a new board
		jal FindSol			# find solutions for board
		la $t0, state_score
		sw $0, 0($t0)			# Reset score to 0
		la $t0, round_time
		la $t1, state_RemTime
		lw $t2, 0($t0)
		sw $t2, 0($t1)			# store total round time as remaining
		la $t0, state_PrevTime
		li $v0, 30
		syscall
		sw $a0, 0($t0)			# get start time

		lw $ra, 0($sp)
		jr $ra

###
# Scores a user input word
# Word@($a0) -> Points@$v0
# CURRENTLY STUB
###
ScoreWord:	li $v0, 4
		.data
ScoreWord_tag:	.asciiz "<Stub Method Called> ScoreWord\n"
		.text
		la $a0, ScoreWord_tag
		syscall
		li $v0, 1
		jr $ra

###
# Display the current state of the game
# none -> none
# Assumes there is valid data at state_[board|score|time]
###
DspState:	la $t0, state_board		# $t0 has board address
		.data
DspState_BrdNL:	.asciiz "\n"
DspState_Smsg:	.asciiz "\nCurrent Score: "
DspState_Tmsg:	.asciiz "\nTime Remaining: "
		.text
		li $t1, 0
		li $t2, 0
		li $v0, 11			# syscode for printchar
DspState_BrdLp: add $t4, $t0, $t1		# $t4 has address into board array
		lb $a0, 0($t4)			# $a0 has byte at $t4
		syscall				# print char
		li $a0, 32
		syscall				# print space
		addi $t1, $t1, 1		# move to next collumn
		li $t5, 9
		ble $t5, $t1, DspState_Score	# check if finished
		addi $t2, $t2, 1
		li $t5, 3
		blt $t2, $t5, DspState_BrdLp	# if collumn not large, jump to
		li $t2, 0
		li $v0, 4
		la $a0, DspState_BrdNL
		syscall
		li $v0, 11
		j DspState_BrdLp
DspState_Score:	li $v0, 4
		la $a0, DspState_Smsg
		syscall
		la $t0, state_score
		lw $a0, 0($t0)
		li $v0, 1
		syscall
		li $v0, 4
		la $a0, DspState_Tmsg
		syscall
		li $v0, 1
		la $a0, state_RemTime
		lw $a0, 0($a0)
		syscall
		jr $ra

###
# Initialize the board stored at state_board.
# none -> none
# CURRENTLY STUB
###
		.data
InitBoard_tag:	.asciiz "<Stub Method Called> InitBoard\n"


		.text
InitBoard:	#li $v0, 4
		#la $a0, InitBoard_tag
		#syscall

		la $t0, Hash_Map		#initialize hash map
		li $t1, 0
		li $t2, 0
	Init_hash_map_for:
		add $t3, $t1, $t0
		sb $t2, ($t3)
		add $t1, $t1, 1
		bne $t1, 26, Init_hash_map_for 	#end for loop


		addi $sp, $sp, -4		#make room on stack
		sw $ra, ($sp)

		li $t0, 0
		la $t1, state_board
	InitBoard_FOR:				#get 9 letters
		jal InitBoard_RNG		#get random letter

		add $a0, $v0, $zero
		jal InitBoard_HASH		#hash letter
		add $t2, $t1, $t0		#store letter
		sb $v0, ($t2)

		addi $t0, $t0, 1		#loop control
		bne $t0, 9, InitBoard_FOR
						#End for loop

		lw $ra, ($sp)			#restore stack
		addi $sp, $sp, 4


		jr $ra



	InitBoard_RNG:
		li $v0, 41			#get random number
		syscall
		srl $a0, $a0, 26		#divide to within 0-31

		slti $t2, $a0, 26		#if the result is greater than 25, try again
		beq $t2 $zero, InitBoard_RNG

		add $v0, $a0, $zero		#put random number in $v0
		jr $ra



	InitBoard_HASH:
		la $t2, Hash_Map
	InitBoard_WHILE:
		add $t3, $a0, $zero
		add $t3, $t3, $t2		#get current byte

		lb $t4, ($t3)
		beq $t4, $zero, InitBoard_VALID	#check if byte is used
		beq $a0, 25, InitBoard_WRAP	#check if needs to wrap back to 0
		addi $a0, $a0, 1
		j InitBoard_NO_WRAP
	InitBoard_WRAP:
		li $a0, 0
	InitBoard_NO_WRAP:
		j InitBoard_WHILE
	InitBoard_VALID:
		li $t4, 1
		sb $t4, ($t3)			#mark letter as used
		addi $v0, $a0, 97		#final letter

		jr $ra



###
# Display the final results after a round has completed
# none -> none
#
###
		.data
DspResult_Scor:	.asciiz "\nYour final score: "
		.text
DspResult:	li $v0, 4
		la $a0, DspResult_Scor
		syscall
		li $v0, 1
		la $t0, state_score
		lw $a0, 0($t0)
		syscall
		jr $ra

###
# Display solutions
# none -> none
# CURRENTLY STUB
###
		.data
DspSol_tag:	.asciiz "<Stub Method Called> DspSol\n"
		.text
DspSol:		li $v0, 4
		la $a0, InitBoard_tag
		syscall
		jr $ra

FindSol:			#find solutions 
		la	$s0, state_board	# s0 <- state_board	THIS IS THE REAL ARGUMENT NEEDED BY THIS ROUTINE
		la	$s1, gridChars		# s1 <- gridChars
		la	$s2, temp		# s2 <- temp
		la	$s3, solution		# s3 <- write pointer into solution array
	
						# populate the gridChars array which keeps track of the occurrences of each char in grid
		li	$t0, 0			# counter
	FindSol_Prep:	
		beq	$t0, 9, FindSol_Cont	# if looped thru grid, then continue
		add	$t1, $s0, $t0		# address to a char in grid in t1
		lb	$t2, ($t1)		# get the actual char in t2
		sub	$t2, $t2, 97		# offset to the corresponding char in gridChars in t2
		add	$t3, $s1, $t2		# get corresponding index in gridChars in t3
		lb	$t4, ($t3)		# get that char count (initially zero)
		addi	$t4, $t4, 1		# increase count by 1
		sb	$t4, ($t3)		# store new count back
		addi	$t0, $t0, 1		# incre counter
		j FindSol_Prep

						# get dictionary name	
	FindSol_Cont:	
		lb	$t1, 4($s0)		# put central char in t1
		la	$t0, file		# file name in t0
		sb	$t1, ($t0)		# overwrite first char; now we have the file name needed

						# open file
	FindSol_Open:		
		li	$v0, 13			# open file syscall
		la	$a0, file		# load file name
		li	$a1, 0			# read-only flag
		li	$a2, 0			# (ignored)
		syscall
		move	$t6, $v0		# save file descriptor to t6; no error checking bc laziness
	
		# get ready to read data
		move	$a0, $t6		# load file descriptor
		la	$a1, buffer		# load buffer address
		li	$a2, 10			# buffer size = 10
		
		li	$t8, 0			# count number of lines for debugging
		li	$t9, 0			# count number of solutions
 
						# read data
	FindSol_Read:	
		li	$v0, 14			# read file syscall (have to manually reset everytime)
		syscall				# stuff read in buffer
		lb	$t1, ($a1)		# get first char of buffer
		beq	$t1, 3, FindSol_Done	# if buffer is end-of-text, done; else check this entry for validity

						# re-initialize the temp array before checking	
		li	$t0, 0
	FindSol_Init:	
		beq	$t0, 26, FindSol_CheckInit	# if looped thru gridChars, then move onto checking
		add	$t1, $s1, $t0		# pointer to a char in gridChars in t1
		add	$t2, $s2, $t0		# pointer to a char in temp in t2
		lb	$t3, ($t1)		# get char from t1
		sb	$t3, ($t2)		# store it to t2
		addi	$t0, $t0, 1		# incre counter	
		j FindSol_Init	

						# check for validity of an entry
	FindSol_CheckInit:	
		move $t0, $a1			# make a copy of a1 (buffer address) in t0
	FindSol_Check:		
		lb	$t1, ($t0)		# get a char of buffer
		beq	$t1, 0, FindSol_CopyInit	# if null, this entry is valid (otherwise we would have broken the loop)
		sub	$t1, $t1, 97		# offset to the corresponding entry in temp
		add	$t1, $t1, $s2		# get actual address in temp into t1
		lb	$t2, ($t1)		# load that char count
		subi	$t2, $t2, 1		# minus one count for that char
		blt	$t2, 0, FindSol_Moveon	# if the count drops below zero, bad entry, break (move on)
		sb	$t2, ($t1)		# store the new count back
		addi	$t0, $t0, 1		# move over one char
		j FindSol_Check

						# by now the entry in buffer is valid and needs to be copied to solution set
	FindSol_CopyInit:	
		move	$t1, $a1		# copy a1 (buffer address) in t1
		move	$t3, $s3		# copy $s3 (pointer into solution set array) in t3
	FindSol_Copy:	
		lb	$t4, ($t1)		# get a char from buffer to t4
		beq	$t4, 0, FindSol_CopyDone	# if finished copying entire buffer
		sb	$t4, ($t3)		# else store it to t3 (solution)
		addi	$t1, $t1, 1		# incre pointer in buffer
		addi	$t3, $t3, 1		# incre pointer in solution
		j FindSol_Copy
	FindSol_CopyDone:	
		addi	$s3, $s3, 10		# seek 10 forward in solution array
		addi	$t9, $t9, 1		# incre solution count
	FindSol_Moveon:	
		addi	$t8, $t8, 1		# incre line count
		j FindSol_Read			# keep reading
 
	FindSol_Done:	
		li	$v0, 16			# close file syscall
		move	$a0, $t6		# load file descriptor
		syscall
	
		la	$a0, solution		# copy solution set address
		
		la 	$t0, numSol		#added by braden to store the number of solutions in memory and return
		sw	$t9, (t0)
		jr $ra

