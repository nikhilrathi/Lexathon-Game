# LEXATHON (MIPS EDITION)
# main.asm
# Created by: John Arteaga, Jorge Quiros, Matthew Bachelder, Nicholas Ibarra, Nikhil Rathi
#NOTE: Make sure 'Initialize Program Counter to Global 'main' if defined' is checked in settings!!!!###########

#################################### DATA SEGMENT ###################################################
.data
	#main.asm strings
	welcomeMessage1:	.asciiz "Welcome to LEXATHON (MIPS Edition)!\n"
	welcomeMessage2: 	.asciiz "===================================\n"
	welcomeMessage3: 	.asciiz "LEXATHON (MIPS EDITION)is an adaptation of the popular Android word game Lexathon.\n"
	welcomeMessage4: 	.asciiz "The object of the game is to find as many possible word combinations as you can given the letters you are provided with.\n\n"
	instructions1:		.asciiz "INSTRUCTIONS:\n"
	instructions2:		.asciiz "               1. At the start of the game you will be given 60 seconds and a 3x3 grid of letters.\n"
	instructions3:		.asciiz	"               2. The letter located in the center of the grid is your key letter.\n"
	instructions4:		.asciiz "               3. During the 60 seconds you must find as many word combinations as you can using the provided letters.\n"
	instructions5: 		.asciiz "               4. Every word that you enter MUST contain the key letter somewhere within the word.\n"
	instructions6: 		.asciiz "               5. Every word that you enter MUST be AT LEAST four letters long.\n"
	instructions7: 		.asciiz "               6. For every correct word you guess, you will receive an additional 5 seconds of time.\n"
	instructions8: 		.asciiz "               7. For every correct word you guess, you will receive 2 points for every letter.\n"
	instructions9:		.asciiz "               8. The game ends when the time reaches ZERO or you type '0'(zero) to GIVE UP.\n\n"
	beginLexathon: 		.asciiz "Enter '1' to begin game or '0' to exit: "
	newLine: 		.asciiz "\n"
	invalidInput:		.asciiz "Invalid Entry, Please Try Again!\n"
	endGame1:		.asciiz "\n\n###################################################################\n"
	endGame2:		.asciiz "###########   Thanks for playing!!  Program ending...   ###########\n"
	endGame3:		.asciiz "###################################################################\n"

	#summary.asm strings
	scoreMessage:		.asciiz "\n========================== GAME  OVER!! ===========================\n\n"
	scoreMessage2:		.asciiz "###################################################################\n"
	scoreMessage3:		.asciiz "#########################  GAME SUMMARY  ##########################\n"
	scoreMessage4:		.asciiz "###################################################################\n"
	scoreMessage5:		.asciiz "\nTotal score: "
	correctWordsNumber:	.asciiz "\nNumber of correct words: "
	correctWordsNumber2:	.asciiz "Correct words: \n       "
	missedWordsNumber:	.asciiz "Missed words: "
	possibleWordsNumber:	.asciiz "\nNumber of possible words: "
	possibleWordsNumber2:	.asciiz "Possible words: "
	playAgainMessage:	.asciiz "\nWould you like to play again? Type '1' for Yes or '0' for No (Exit Program): "

	#gameStarts.asm
	fileName:		.space	8
	fileContents:		.space	500000
	legalWords:		.space	500000
	correctWords:		.space 	500000		
	currentWord: 		.asciiz "            "
	availableLetters:	.asciiz "            "
	lettersInGrid:		.asciiz "         "
	printLoading:		.asciiz "\nPlease wait while your game loads...\n\n\n"
	timeOverMessage: 	.asciiz "\n\n!!!OUT OF TIME!!!\n"
	successMessage1: 	.asciiz "\nYou have entered "
	successMessage2: 	.asciiz " correct words!\n"
	duplicateMessage:	.asciiz "\nDuplicate word entered!\n"
	promptUser:		.asciiz "\nEnter your word or type '0' to Give Up: "
	userInput:		.asciiz "         "
	wordValidate:		.asciiz "         "
	duplicateWord:		.asciiz "         "
	noMiddle:		.asciiz "\nYou did not use the middle character! Try again...\n"
	wordNotFoundString:	.asciiz "\nWord does not exist OR word is less than four characers!!! Try again...\n"
	gridPrintTopString:	.asciiz "\t\t+---+---+---+\n"
	gridPrintMiddleString:	.asciiz "\t\t|---+---+---|\n"
	gridPrintBottomString:	.asciiz "\t\t+---+---+---+\n"
	gridPrintSideLeftString:.asciiz "\t\t| "
	gridPrintSideRightString:.asciiz " |\n"
	gridPrintInsideString:	.asciiz " | "
	
############################################ TEXT SEGMENT ############################################################
	.text
	.globl main
	
	# To include other .asm files of the project
	.include "gameStarts.asm"
	.include "validating.asm"
	.include "summary.asm"	
	
main:	
	# Print Introduction
	li $v0, 4
     	la $a0, welcomeMessage1
     	syscall   
     	#
     	la $a0, welcomeMessage2
     	syscall   
     	#
     	la $a0, welcomeMessage3
     	syscall   
     	#
     	la $a0, welcomeMessage4
     	syscall   
     	#
     	la $a0, instructions1
     	syscall   
     	#
     	la $a0, instructions2
     	syscall   
     	#
     	la $a0, instructions3
     	syscall   
     	#
     	la $a0, instructions4
     	syscall   
     	#
     	la $a0, instructions5
     	syscall   
     	#
     	la $a0, instructions6
     	syscall   
     	#
     	la $a0, instructions7
     	syscall 
     	#
     	la $a0, instructions8
     	syscall 
     	#
     	la $a0, instructions9
     	syscall    
     	#
     	la $a0, newLine
     	syscall  
 
requestGame:
	# Ask Player to Begin:
     	li $v0, 4
     	la $a0, beginLexathon
     	syscall   
     	#
     	li $v0, 5 			# read a single int number from player
     	syscall
     	#
     	beq $v0, $zero, gameOver	# go to exit if player enters zero otherwise continue
     	bne $v0, 1, invalidEntry	# go to invalidEntry if player enters anything except 1 and 0

newGame:
     	li $s1, 0			# Initialize total word count ($s1)
     	li $s4, 0			# Initialize score ($s4)
     	li $s5, 60			# Initialize time remaining to 60 seconds ($s5)
	jal startGame			# Pick random 9 letter word and its acronyms and display
	jal test			# Check score
	#
     	la $a0, newLine
     	syscall
     	#
     	la $a0, newLine
     	syscall  
	
gameOver:
     	li $v0, 4 
     	la $a0, endGame1
     	syscall
     	#   
     	la $a0, endGame2
     	syscall   
     	#
     	la $a0, endGame3
     	syscall   
     	#
     	j exit				#ask player again
     	
exit:
	li $v0, 10 			# exit program
     	syscall   
	
invalidEntry:
     	li $v0, 4 			# Invalid input message
     	la $a0, invalidInput
     	syscall   
     	#
     	j requestGame			#ask player again
