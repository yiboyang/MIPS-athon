		.data
session_msg:	.asciiz "\nDo you want to (start) a new game or (exit)? "
session_err:	.asciiz "\nInvalid choice: "
session_affirm:	.asciiz "start\n"
session_deny:	.asciiz "exit\n"
round_msg:	.asciiz "\nEnter another word: "
round_err:	.asciiz "\nInvalid word: "
exit_msg:	.asciiz "\nThanks for playing!"\
state_score:	.word 0
state_started:	.word 0
state_current:	.word 0
state_board:	.bytes 0, 0, 0, 0, 0, 0, 0, 0, 0
round_time:	.word 30000

prompt_buf:	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

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
CompStr_EQ:	addi $t2, 1
		bneq $t0, $0, CompStr_Loop
		li $v0, 0
		jr $ra

###
# Prompt user for string input
#
# Prints string ($a0) and places user input in ($v0). Does not allow user input
# beyond 10 characters, and a newline will be appended unless the user inputs
# 10 characters
###
Prompt:		li $v0, 4 # print string ($a0)
		syscall
		la $a0, prompt_buf
		li $a1, 11
		li $v0, 8 # read string to ($a0) of length <= $a1-1
		syscall
		jr $ra

###
# Main program loop
#
# Not a subroutine!
###
Session:	la $a0, session_msg
		jal Prompt			# Prompt for start or exit
		mv $a0, $v0
		la $a1, session_affirm
		jal CompStr			# Check is input is start
		beq $v0, $0, InitRound		# if so, start the round
		la $a1, session_deny
		jal CompStr			# else check for exit
		beq $v0, $0, Exit		# if so, exit
		la $a0, session_er
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
		mv $a0, $v0
		jal ScoreWord			# score the word
		mv $t0, $v0			# temp save score
		bneq $v0, $0, Round_Upd		# Check if score is 0
		la $a0, round_err
		li $v0, 4
		syscall				# if so, print error
Round_Upd:	mv $a0, $t0
		jal UpdateState			# update the game state
		blt $v0, $0, EndRound		# end if no time remaining
		jal DspState			# else display updates stat
		j Round				# and go back to user input

EndRound:	jal DisplayResults		# display the user's results
		jal DisplaySolutions		# display all solutions
		j Session

###
# Updates the current state of the game
# Points@$a0 -> RemainingTime@$v0
# The points passed to the method are directly awarded to the player
###
UpdateState:	la $t0, state_score
		lw $t1, 0($t0)			# $t1 has player's score
		add $t1, $t1, $a0		# add in new points
		sw $t1, 0($t0)			# stone new score
		# Score updated

		la $t0, state_start
		lw $t0, 0($t0)			# $t0 has round start time
		li $v0, 30
		syscall				# get current time
		sub $t0, $t0, $a0		# $t0 has elapsed time
		la $t1, round_time
		lw $t1, 0($t1)			# $t1 has round time limit
		sub $v0, $t1, $t0		# $vo has remaining time
		la $t1, state_current
		sw $v0, 0($t1)			# store remaining time in state
		jr $ra

###
# Initializes the entire game state in preparation for a new round.
# none -> none
# Assumes state_[score|start|time|board] exist
###
InitState:	addi $sp, $sp, 4
		sw $ra, 0($sp)
		jal InitBoard			# get a new board

		la $t0, state_score
		sw $0, 0($t0)			# Reset score to 0
		la $t0, round_time
		la $t1, state_current
		lw $t2, 0($t0)
		sw $t2, 0($t1)			# store total round time as remaining
		la $t0, state_start
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
		.text
ScoreWord_tag:	.asciiz "<Stub Method Called> ScoreWord\n"
		.data
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
		.text
DspState_BrdNL:	.asciiz "\n"
DspState_Smsg:	.asciiz "\nCurrent Score: "
DspState_Tmsg:	.asciiz "\nTime Remaining: "
		.data
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
		ble $t5, $t1, DspState_Sc	# check if finished
		addi $t2, $t2, 1
		li $t5, 3
		blt $t1, $t5, DspState_BrdLp	# if collumn not large, jump to 
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
		la $a0, state_current
		syscall
		jr $ra

###
# Initialize the board stored at state_board.
# none -> none
# CURRENTLY STUB
###
		.text
InitBoard_tag:	.asciiz "<Stub Method Called> InitBoard\n"
		.data
InitBoard:	li $v0, 4
		la $a0, InitBoard_tag
		syscall
		la $t0, state_board
		li $t1, 48
		li $t2, 58
InitBoard_iter:	add $t3, $t0, $t1
		sb $t1, 0($t3)
		addi $t1, $t1, 1
		blt $t1, $t2, InitBoard_iter
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
		.text
DspSol_tag:	.asciiz "<Stub Method Called> DspSol\n"
		.data
DspSol:		li $v0, 4
		la $a0, InitBoard_tag
		syscall
		jr $ra

