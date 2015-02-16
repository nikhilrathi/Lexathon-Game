#------------------------------------Import File------------------------------------------------------------------#
# Generates random file name
# Imports dictionary file

startGame:
	li $v0, 4
	la $a0, printLoading
	syscall
	
getRandomFileName:
	
	li   $a0, 0	#set lower bound for random int
	li   $a1, 25	#set upper boind for random int
	li   $v0, 42       # random int w/range
	syscall
	addi $a0, $a0, 65	#bring $v0 into range of Alphabet in Ascii table
	la $t1, fileName	#load address where we store filename
	sb $a0, ($t1)	# store the random letter in filename at position 0
	sb $zero, 1($t1)	#add a null character to end of fileName	



importFile:
	li   $v0, 13       	# open file
	la   $a0, fileName 	# load address with filename
	li   $a1, 0     	#flags   	
	li   $a2, 0  		#mode 0: read, 1: write  
	syscall            	# open a file (file descriptor returned in $v0)
	addi $sp, $sp, -4	#make room on the stack
	sw   $s6, 0($sp)	#save $s6 since we are using elsewhere
	move $s6, $v0      	# save the file descriptor in $s6
	li   $v0, 14      	# system call for read from file
	move $a0, $s6      	# file descriptor 
	la   $a1, fileContents	# address to buffer to store read data
	li   $a2, 500000    	# maximum number of characters to read
	syscall            	# read from file
	li   $v0, 16       	# system call for close file
	move $a0, $s6      	# file descriptor to close
	syscall            	# close file
	lw   $s6, 0($sp)	# restore $s6
	addi $sp, $sp, 4	#restore the stack
#--------------------------------------End Import File---------------------------------------------------------#


#-------------------Create Word List From Dictionary-----------------------------------------------------------#
# Jumps to a random character in the uploaded file
# Scans for first new line character
# Assumes next character is beginning of new  word
# Counts word length until first 9 letter word is reached
# begins copying words to wordlist. a new word is stored every 12 bytes.
#Stores available letters at availableLetters

createWordList:
	li   $a0, 0	#set lower bound for random int # $a0 contains position in fileContents
	li   $a1, 10000	#set upper boind for random int
	li   $v0, 42       # random int w/range
	syscall
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  findFirstWord
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	move $a0, $v0	#move positon of first word to $a0
	li   $v0, 0
	jal  findNineLetterWord
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	move $a0, $v0      #move positon of first nine letter word to $a0
	jal fillWordList
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  getNineLetters
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	j createWordListEnd
	
	
#------------------------------------get available letters--------------------------------------#
#returns 9 available letters stored in available letters	
getNineLetters:
	li $a0, 0 #counter for position in legalWords and availbleLetters
		getNineLettersStart:
			beq $a0, 12, getNineLettersEnd
			lb $t0, legalWords($a0) #load char from first word in legalWords (first word is the nine char word)
			sb $t0, availableLetters($a0) # copy to available letters
			add $a0, $a0, 1	#move forward in legalWords and availableLetters
			j getNineLettersStart
getNineLettersEnd:
	jr $ra

#---------------------------------end get available letters--------------------------------------#


#--------------------------------Fill Word List--------------------------------------------------#
#Fills Word List Until and Asterix is Read
#a new word is stored every 12 bytes.

fillWordList:
	li $a1, 0 #positon in legalWords
	li $a2, 0 #currentWord position counter
	fillWordListStart:
		lb $t0, fileContents($a0) # load current char
		beq $t0, 42, fillWordListEnd # found end of legalWords '*' return
		beq $t0, 10, saveWord #new line char found, current word loaded, go save
		sb  $t0, currentWord($a2) #save character to currentWord
		add $a2, $a2, 1 #move to next position in currentWord
		add $a0, $a0, 1 #move to next position in fileContents
		j fillWordListStart
		
			saveWord:
				addi $s1, $s1, 1
				mul $t2, $a1, 12 #$t2 contains the position in legalWords were we start storing the currentWord
				li $a2, 0 #reset current word position to 0
				li $t4, 32 #load a ' ' char into $t4 for resetting currentWord
					saveWordStart:
						lb $t3, currentWord($a2) #load char at current position
						beq $t3, 0, saveWordEnd #reached end of current word return
						sb $t3, legalWords($t2)    #copy to legalWords at current position
						sb $t4, currentWord($a2)
						add $t2, $t2, 1
						add $t3, $t3, 1
						add $a2, $a2, 1
						j saveWordStart
			saveWordEnd:
				li $a2, 0	#reset current word position to 0
				add $a1, $a1, 1 #move to next position in WordList
				add $a0, $a0, 1 #move to next position in fileContents
				j fillWordListStart
	fillWordListEnd:
		jr $ra
						
				 
		
		
	
#-------------------------------End Fill Word List-----------------------------------------------#


findFirstWord:
	lb $t0, fileContents($a0)
	beq $t0, 10, findFirstWordReturn #brnches on newline character
	add $a0, $a0, 1
findFirstWordReturn:
	add $a0, $a0, 1
	move $v0, $a0	#return position of first word
	jr $ra
	
findNineLetterWord:
	beq $v0, 10, findNineLetterWordReturn #nine letter word found *start of legalWords
	j getLength
	
findNineLetterWordReturn:
	add $a0, $a0, -11
	move $v0, $a0
	jr $ra
	
#----------------------Gets Length of current word in fileContents--------------------------------------------#	
getLength:
	li $a2, 0	#word length
		getLengthStart:
			lb $a1, fileContents($a0)
			beq $a1, 10, getLengthEnd #new line char found current word length is stored
			add $a0, $a0, 1 #move forward one position in file contents
			add $a2, $a2, 1 #add one to wordlength
			j getLengthStart
getLengthEnd:
	add $a0, $a0, 1
	move $v0, $a2
	j findNineLetterWord
			
#---------------------------------End getLength---------------------------------------------------------------#	
	
	
createWordListEnd:
	j printGrid
#-----------------End Create Word List From Dictionary--------------------------------------------------------#	


#----------------------Print Grid ------------------------------------------------#
# 
# Shuffles and displays grid to user
# 

printGrid:

	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  shuffleLetters
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	
	li $a1, 0	#$a1 stores the current char position in lettersInGrid
	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintTop
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintSideLeft
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintInside
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintInside
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintSideRight
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintMiddle
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
		
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintSideLeft
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintInside
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintInside
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintSideRight
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintMiddle
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintSideLeft
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintInside
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintInside
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintNextChar
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintSideRight
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  gridPrintBottom
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	jr $ra
	
	
gridPrintTop:
	li $v0, 4
	la $a0, gridPrintTopString
	syscall
	jr $ra
gridPrintMiddle:
	li $v0, 4
	la $a0, gridPrintMiddleString
	syscall
	jr $ra
gridPrintBottom:
	li $v0, 4
	la $a0, gridPrintBottomString
	syscall
	jr $ra

gridPrintInside:
	li $v0, 4
	la $a0, gridPrintInsideString
	syscall
	jr $ra
	
gridPrintSideLeft:	
	li $v0, 4
	la $a0, gridPrintSideLeftString
	syscall
	jr $ra 
	
gridPrintSideRight:
	li $v0, 4
	la $a0, gridPrintSideRightString
	syscall
	jr $ra
	
gridPrintNextChar:
	lb $a0, lettersInGrid($a1)
	li $v0, 11
	syscall
	add $a1, $a1, 1
	jr $ra
	
		
#------------------------------Shuffle Letters----------------------------------------#
#randomizes order of letters in array one of 3 ways
shuffleLetters:
	li $a0, 1
	li $a1, 3
	li $v0, 42
	beq $a0, 1, shuffle1
	beq $a0, 2, shuffle2
	beq $a0, 3, shuffle3
	
		shuffle1:
			li $t2, 0 #$t2 storesposition in lettersInGrid 
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 6
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 3
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 7
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 2
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 5
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			lb $s3, lettersInGrid($t2) #save middle character for later use
			add $t2, $t2, 1
			
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 0
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 1
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 8
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 4
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			
			
		shuffle2:
			li $t2, 0 #$t2 storesposition in lettersInGrid 
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 3
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 6
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 8
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 1
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 4
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			lb $s3, lettersInGrid($t2) #save middle character for later use
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 2
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 7
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 0
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 5
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
		
		shuffle3:
			li $t2, 0 #$t2 storesposition in lettersInGrid 
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 5
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 0
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 7
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 2
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 6
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			lb $s3, lettersInGrid($t2) #save middle character for later use
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 3
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 1
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 8
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			add $t2, $t2, 1
			
			li $t0, 0 #$t0 stores position in availableLetters
			add $t0, $t0, 4
			lb $t1, availableLetters($t0) #$t1 stores current char in availableLetters
			sb $t1, lettersInGrid($t2) #store current char in "lettersInGrid"
			
		
shuffleLettersEnd:
	jr $ra

#----------------------------------End shuffle letters------------------------------------------------------------------------#
	


#------------------------------------End Print Grid and Store Available Letters------------------------------------------------#


	
	
	
	
	




