	.data
prompt:	.asciiz "Specify a file to read (enter one lower case letter, e.g. entering 'a' opens up a.txt in current directory): "
fnf:	.ascii  "The file was not found: "
file:	.asciiz	"?.txt"	# the "?" is just a placeholder for a char to be overwritten
buffer: .space 524288	# the largest sub-dictionary, e.txt, is only 411621 bytes, so one can read any of them in one go
 
	.text

# ask for file name
	li	$v0, 4
	la	$a0, prompt
	syscall			# print prompt
	
	li	$v0, 12
	syscall			# read one char indicating file name
	
	la	$t0, file
	sb	$v0, ($t0)	# overwrite first char; now we have the file name needed
	
# open file
open:
	li	$v0, 13		# open file syscall
	la	$a0, file	# load file name
	li	$a1, 0		# read-only flag
	li	$a2, 0		# (ignored)
	syscall
	move	$s6, $v0	# save file descriptor
	blt	$v0, 0, err	# goto error
 
# read data
read:
	li	$v0, 14		# read file syscall
	move	$a0, $s6	# load file descriptor
	la	$a1, buffer	# load buffer address
	li	$a2, 524288	# buffer size; tweak with it for fun
	syscall
	
	li	$v0, 4		# for print string
	la	$a0, buffer
	syscall			# print data
 
# close file
close:
	li	$v0, 16		# close file syscall
	move	$a0, $s6	# load file descriptor
	syscall
	j	done		# goto end
 
# error
err:
	li	$v0, 4		# print string syscall
	la	$a0, fnf	# load error string
	syscall
 
# done
done:
	li	$v0, 10		# exit syscall
	syscall
