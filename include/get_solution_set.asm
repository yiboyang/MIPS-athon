# Input: length 9 array of grid characters; here we a static array from .data
# Output: $a0 containing the address of the first char in the solution set (each entry has length 10 and will be null padded),
# and $a1 containing the size of the solution set

# Uses saved registers $s0 - $s3, which could be easily eliminated;
# so far gives the same output as my Python demo program;
# should work for grid/dictionary that allows duplicates as well.
# Relabeled all labels (prepending 'sol' and capitalizing the first char)
# By Yibo Yang
	
	.data
grid:	.asciiz "abjkedgci"	# my test grid
gridChars:	.space 26		# boolean array keeping track of which chars are present in grid
temp:	.space 26	# temporary copy of gridChars; reinitailized to gridChars each round
buffer: .space 10	# use buffer size that is the size of an entry
file:	.asciiz	"?.txt"	# the "?" is just a placeholder for a char to be overwritten
solution: .space 3000	# assume max 300 solution entries (each has length 10 including null char)

	.text
solStart:	la	$s0, grid	# s0 <- grid	THIS IS THE REAL ARGUMENT NEEDED BY THIS ROUTINE
	la	$s1, gridChars	# s1 <- gridChars
	la	$s2, temp	# s2 <- temp
	la	$s3, solution	# s3 <- write pointer into solution array
	
# populate the gridChars array which keeps track of the occurrences of each char in grid
	li	$t0, 0		# counter
solPrep:	beq	$t0, 9, solCont	# if looped thru grid, then continue
	add	$t1, $s0, $t0	# address to a char in grid in t1
	lb	$t2, ($t1)	# get the actual char in t2
	sub	$t2, $t2, 97	# offset to the corresponding char in gridChars in t2
	add	$t3, $s1, $t2	# get corresponding index in gridChars in t3
	lb	$t4, ($t3)	# get that char count (initially zero)
	addi	$t4, $t4, 1	# increase count by 1
	sb	$t4, ($t3)	# store new count back
	addi	$t0, $t0, 1	# incre counter
	j solPrep

# get dictionary name	
solCont:	lb	$t1, 4($s0)	# put central char in t1
	la	$t0, file	# file name in t0
	sb	$t1, ($t0)	# overwrite first char; now we have the file name needed

# open file
solOpen:	li	$v0, 13		# open file syscall
	la	$a0, file	# load file name
	li	$a1, 0		# read-only flag
	li	$a2, 0		# (ignored)
	syscall
	move	$t6, $v0	# save file descriptor to t6; no error checking bc laziness
	
	# get ready to read data
	move	$a0, $t6	# load file descriptor
	la	$a1, buffer	# load buffer address
	li	$a2, 10		# buffer size = 10
	
	li	$t8, 0		# count number of lines for debugging
	li	$t9, 0		# count number of solutions
 
# read data
solRead:	li	$v0, 14		# read file syscall (have to manually reset everytime)
	syscall			# stuff read in buffer
	lb	$t1, ($a1)	# get first char of buffer
	beq	$t1, 3, solDone	# if buffer is end-of-text, done; else check this entry for validity

# re-initialize the temp array before checking	
	li	$t0, 0
solInit:	beq	$t0, 26, solCheckInit	# if looped thru gridChars, then move onto checking
	add	$t1, $s1, $t0	# pointer to a char in gridChars in t1
	add	$t2, $s2, $t0	# pointer to a char in temp in t2
	lb	$t3, ($t1)	# get char from t1
	sb	$t3, ($t2)	# store it to t2
	addi	$t0, $t0, 1	# incre counter
	j solInit	

# check for validity of an entry
solCheckInit:	move $t0, $a1	# make a copy of a1 (buffer address) in t0
solCheck:	lb	$t1, ($t0)	# get a char of buffer
	beq	$t1, 0, solCopyInit	# if null, this entry is valid (otherwise we would have broken the loop)
	sub	$t1, $t1, 97	# offset to the corresponding entry in temp
	add	$t1, $t1, $s2	# get actual address in temp into t1
	lb	$t2, ($t1)	# load that char count
	subi	$t2, $t2, 1	# minus one count for that char
	blt	$t2, 0, solMoveon	# if the count drops below zero, bad entry, break (move on)
	sb	$t2, ($t1)	# store the new count back
	addi	$t0, $t0, 1	# move over one char
	j solCheck

# by now the entry in buffer is valid and needs to be copied to solution set
solCopyInit:	move	$t1, $a1	# copy a1 (buffer address) in t1
	move	$t3, $s3	# copy $s3 (pointer into solution set array) in t3
solCopy:	lb	$t4, ($t1)	# get a char from buffer to t4
	beq	$t4, 0, solCopyDone	# if finished copying entire buffer
	sb	$t4, ($t3)	# else store it to t3 (solution)
	addi	$t1, $t1, 1	# incre pointer in buffer
	addi	$t3, $t3, 1	# incre pointer in solution
	j solCopy
solCopyDone:	addi	$s3, $s3, 10	# seek 10 forward in solution array
	addi	$t9, $t9, 1	# incre solution count
solMoveon:	addi	$t8, $t8, 1	# incre line count
	j solRead			# keep reading
 
solDone:	li	$v0, 16		# close file syscall
	move	$a0, $t6	# load file descriptor
	syscall
	
	la	$a0, solution	# copy solution set address
	move	$a1, $t9	# copy number of solutions
	
	li	$t0,0
	move	$t1, $a0
solPrint:	beq	$t0,$a1,solFinish
	move	$a0,$t1
	li	$v0, 4	# for print string
	syscall
	li	$v0,11		# print char
	li	$a0,0x0a	# newline
	syscall
	addi	$t1,$t1,10
	addi	$t0,$t0,1
	j solPrint
	
solFinish:	li	$v0, 10		# exit syscall; optional
	syscall
