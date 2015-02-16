# Prints the Summary of the Game

.text

printScore: 
	li $v0, 4 			#Print scoreMessage
     	la $a0, scoreMessage	
     	syscall   
     	#
     	la $a0, scoreMessage2	
     	syscall   
     	#
     	la $a0, scoreMessage3	
     	syscall   
     	#
     	la $a0, scoreMessage4
     	syscall   
     	#
     	la $a0, scoreMessage5
     	syscall   
     	#
	li $v0, 1 		 	#Print integer
     	move $a0, $s4			#load/print score
     	syscall   
	#
	li $v0, 4 			#Print newLine
     	la $a0, newLine			#newLine label located in main.asm
     	syscall   

printCorrectWords:
	li $v0, 4 			#Print correctWordsNumber message
     	la $a0, correctWordsNumber	
     	syscall   
     	#
	li $v0, 1 			#Print number of correct words
     	move $a0, $s7			#Register for correct words count
     	syscall   
	#
	li $v0, 4 			#Print newLine
     	la $a0, newLine			#newLine label located in main.asm
     	syscall   
     	#
	li $v0, 4 			#Print correctWordsNumber message
     	la $a0, correctWordsNumber2	
     	syscall   
     	#

	li $v0, 4
	la $a0, correctWords
	syscall
	#
	li $v0, 4 			#Print newLine
     	la $a0, newLine			#newLine label located in main.asm
     	syscall   
     	#

printTotalPossibleWords:
	li $v0, 4 			#Print total number of possible words message
     	la $a0, missedWordsNumber	
     	syscall   
     	#
	sub $s2, $s1, $s7		#Obtaining number of missed words
	#
	li $v0, 1 			#Print total number of missed words
     	move $a0, $s2			#Moving missed words to $a0 to print
     	syscall   
	#
	li $v0, 4 			#Print newLine
     	la $a0, newLine			#newLine label located in main.asm
     	syscall   
     	#
     	li $v0, 4 			#Print total number of possible words message
     	la $a0, possibleWordsNumber	
     	syscall
     	#
     	li $v0, 1 			#Print total number of missed words
     	move $a0, $s1			#Moving missed words to $a0 to print
     	syscall 
     	#
	li $v0, 4 			#Print newLine
     	la $a0, newLine			#newLine label located in main.asm
     	syscall   
     	#
     	li $v0, 4 			#Print total possible words message
     	la $a0, possibleWordsNumber2	
     	syscall   
     	#
     	li $v0, 4 			#Print newLine
     	la $a0, newLine			#newLine label located in main.asm
     	syscall   
		
printPossibleWords:
	add	$t1, $0, $0

printPossibleWordsLoop:
	li $v0, 4
	la $a0, legalWords
	syscall
	#
	la $a0, newLine
	syscall

	j gameOver