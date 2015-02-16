# Collects User Input
# Validating User Input

test:
	li $v0, 4
	la $a0, promptUser
	syscall	

	# Start Time
	li $v0, 30
	syscall
	move $t3, $a0
	div $t3, $t3, 1000
	
	# Collect user input and store in userInput
	li $v0, 8	
	la $a0, userInput
	li $a1, 10
	syscall
	
	li $t0, 0
	lb $t1, userInput($t0)
	
	# Check if user input is 0, and if yes then go to printScore
	beq $t1, 48, printScore
	
	# Stop Time	
	li $v0, 30
	syscall
	move $t4, $a0
	div $t4, $t4, 1000
	
	# Subtract time spent by user from the main time
	sub $t5, $t4, $t3 
	sub $s5, $s5,$t5
	blt $s5, 0, timeOver
	
	# Make User Input Upper Case Letters
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  makeUpperCase 
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	# Check for the Middle Character
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  validateMiddle 
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	# Check for the Word Length
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  getWordLength 
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	
	# Check if Legit Word
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  validateWord 
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	# Check if Duplicate Word
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  validateDuplicate
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4
	
	# Store the entered word
	addi $sp, $sp, -4	#make room on the stack
	sw   $ra, 0($sp)	#store return address
	jal  storeCorrectWord 
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4		
	
	# Print Success Message
	li $v0, 4
	la $a0, successMessage1
	syscall
	li $v0, 1
	move $a0, $s7
	syscall
	li $v0, 4
	la $a0, successMessage2
	syscall
	
	addi $s5, $s5, -5
		
	
	j test #end of validating 

#-------------------------Get word length----------------------------------------------------#
getWordLength:
	li $a0, 0
	li $s6, 0 #word length stored here
		getWordLengthLoop:
			lb $t0, userInput($a0)
			beqz $t0, exitGetWordLength
			add $s6, $s6, 1
			add $a0, $a0, 1
exitGetWordLength:
 	jr $ra

#-------------------------Validate Middle----------------------------------------------------#
#chacks to ensure middle char. was used		
validateMiddle:
	li $a0, 0 #position counter for userinput
	validateMiddleStart:
		lb $t0, userInput($a0)
		beqz $t0, unableToValidateMiddle
		beq $t0, $s3, validateMiddleSuccess
		add $a0, $a0, 1
		j validateMiddleStart
unableToValidateMiddle:
	li $v0, 4
	la $a0, noMiddle
	syscall
	lw   $ra, 0($sp)  #restore return address
	addi $sp, $sp, 4	
	j test
	
validateMiddleSuccess:
	jr $ra
	
#---------------------- End Validate Middle-------------------------------------------------#
#-----------------------Validate Word-------------------------------------------------------#
#Checks user inputted word against available words in word list

validateWord:
	li $a0, 0 # positon counter for userInput
	li $a1, 0 #word number in legalWords
	li $a2, 0 #reset positon in legalwords to 0	
		getNextWord: #gets next word from legalwords and stores in wordValidate
			mul $a2, $a1, 12 #aligns to next word in legalWords
			li $a3, 0 #position counter for wordValidate
			 nextWordLoop:
			 	lb $t0, legalWords($a2)#load character from position in legalWords
			 	beqz $t0, wordNotFound #if end of legalWordList exit
			 	beq $t0, 32, checkWord #if end of current word go check against userInput
			 	sb  $t0, wordValidate($a3)# else store the current char in the next position in wordValidate
			 	add $a3, $a3, 1 #increment positioncounter for wordValidate
			 	add $a2, $a2, 1 #increment position in legalWords
			 	j nextWordLoop
			 	
			 checkWord:
			 	li $a3, 0 #reset counter for wordValidate to 0
			 	li $a0, 0 # positon counter for userInput
			 	
			 		checkWordLoop:
			 			
			 			lb $t2, wordValidate($a3)
			 			lb $t3, userInput($a0)
			 			beq $t2, $0, validateSuccess 
			 			beq $t2, '\r', validateSuccess #all characters cycled without fail. assume match
			 			
			 			bne $t2, $t3, validateFail #if character fail word is not equal-fail
			 			 
			 			add $a3, $a3, 1 #increment wordValidate position
			 			add $a0, $a0, 1 #increment userInput position
			 			j checkWordLoop
			 validateSuccess:
			 	#word matches go back to wherever you need to go if the word entered macthes in the dictionary
			 	
			 	jr $ra
			 	
			 validateFail:
			 #validation failed. empty wordValidate and go to next word
			 	add $a1, $a1, 1 #increment to next word in legalWords
			 	li $a3, 0 #reset counter for wordValidate to 0
			 	li $t4, ' ' #load a space char into $t4
			 	 resetValidateWord:
			 	 	lb $t2, wordValidate($a3)
			 	 	beqz $t2, exitValidateFail #end of word go get next word
			 	 	sb  $t4, wordValidate($a3)
			 	 	add $a3, $a3, 1
			 	 	j resetValidateWord
			 exitValidateFail:
			 	j getNextWord
			 	
			 	
wordNotFound:
	li $a0, 0
	li $t4, ' ' #load a space char into $t4
	 resetUserInput:
		lb $t2, userInput($a0)
		beqz $t2, exitWordNotFound #end of word go get next word
	 	sb  $t4, userInput($a0)
		add $a0, $a0, 1
		j resetUserInput
	
exitWordNotFound:
	li $v0, 4
	la $a0, wordNotFoundString
	syscall
		 			
	j test		 
	
#----------
validateDuplicate:

	li $a0, 0 # positon counter for userInput
	li $a1, 0 #word number in correctWordd
	li $a2, 0 #reset positon in correctWords to 0	
		getNextWord1: #gets next word from correctWords and stores in wordValidate
			mul $a2, $a1, 12 #aligns to next word in correctWords
			li $a3, 0 #position counter for correctWords
			 nextWordLoop1:
			
			 	lb $t0, correctWords($a2)#load character from position in correctWords
			 	beqz $t0, wordNotFound1 #if end of correctWords assume no duplicate  exit
			 	beq $t0, 32, checkWord1 #if end of current word go check against userInput
			 	sb  $t0, duplicateWord($a3)# else store the current char in the next position in duplicateWord
			 	add $a3, $a3, 1 #increment positioncounter for duplicateWord
			 	add $a2, $a2, 1 #increment position in correctWords
			 	
			 	j nextWordLoop1
			 	
			 checkWord1:
			 	sb $t0, duplicateWord($a3)
			 	li $a3, 0 #reset counter for duplicateWord to 0
			 	li $a0, 0 # positon counter for userInput
			 	li $t2, 0
			 	li $t3, 0
			 	
			 		checkWordLoop1:
			 			lb $t2, duplicateWord($a3)
			 			lb $t3, userInput($a0)
			 			beq $t3, '\r', validateFail1
			 			beq $t2, 32, validateFail1
			 			beq $t2, '\r', validateFail1 #all characters cycled without fail. assume duplicate
			 			
			 			bne $t2, $t3, validateSuccess1 #if character fail word is not equal-fail
			 			 
			 			add $a3, $a3, 1 #increment duplicateWord position
			 			add $a0, $a0, 1 #increment userInput position
			 			j checkWordLoop1
			 validateSuccess1:
			 
			 	#validation failed. empty wordValidate and go to next word
			 	add $a1, $a1, 1 #increment to next word in correctWords
			 	li $a3, 0 #reset counter for wordValidate to 0
			 	li $t4, ' ' #load a space char into $t4
			 	 resetValidateWord1:
			 	 	lb $t2, duplicateWord($a3) #currentWord in CorrectWords
			 	 	beqz $t2, exitValidateSuccess1 #end of word go get next word
			 	 	sb  $t4, duplicateWord($a3)
			 	 	add $a3, $a3, 1
			 	 	j resetValidateWord1
			 exitValidateSuccess1:
			 	j getNextWord1
			 	
			 	
			 validateFail1:
			 #word matches go back to wherever you need to go if the word entered macthes in the dictionary
			 	li $v0, 4
			 	la $a0, duplicateMessage
			 	syscall
			 	j test
			 
wordNotFound1:	
	jr $ra

#----------------------Make upper case------------------------------------------------------#
#converts each char user inputs to upper case if needed. matches dic file

makeUpperCase:
	li $a0, 0	#stores posiiton in userInput
	
	makeUpperCaseStart:
		lb $t0, userInput($a0) #$t0 holds current char
		beqz $t0, makeUpperCaseEnd #end of userInput
		bgt  $t0, 96, convertToUpper #char is lower, go convert to upper
		add $a0, $a0, 1
		j makeUpperCaseStart
	convertToUpper:
		add $t0, $t0, -32
		sb $t0, userInput($a0)
		add $a0, $a0, 1
		j makeUpperCaseStart
makeUpperCaseEnd:
	jr $ra
				
#--------------------------End make upper case------------------------------------------------#				
															
storeCorrectWord:	

	li $a0, 0 #poition in userInput
	#remeber $s7 is the word number in correctWords
	li $a1, 0 #position in current word in correctWords
	mul $a1, $s7, 12
	li $t8, 0
		storeCorrectWordLoop:
		
			lb $t0, userInput($a0)
			beqz $t0,  storeSuccess
			sb $t0, correctWords($a1)
			add $a0, $a0, 1
			add $a1, $a1, 1
			add $t8,$t8, 1
			j storeCorrectWordLoop
			
		storeSuccess:
			
			li $t0, 32
			
			sb $t0, correctWords($a1)
			beq $a0, 11, endStoreSuccess
			add $a0, $a0,1
			add $a1, $a1,1
			j storeSuccess
			
		endStoreSuccess:
			
			addi $s7, $s7, 1
			#Calculate Score
			li $t9, 0
			sub $t8, $t8, 1
			mul $t9, $t8, 2
			add $s4, $s4, $t9
			jr $ra

timeOver:
	li $v0, 4
	la $a0, timeOverMessage
	syscall
	
	j printScore		
									
#------------------------------End of validate----------------------------------------------#
