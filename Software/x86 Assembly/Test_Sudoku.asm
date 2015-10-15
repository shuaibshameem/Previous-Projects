.data
	one BYTE 0									; Counter for # of 1s in row/col/box
	two BYTE 0									; Counter for # of 2s in row/col/box
	three BYTE 0								; Counter for # of 3s in row/col/box
	four BYTE 0									; Counter for # of 4s in row/col/box
	five BYTE 0									; Counter for # of 5s in row/col/box
	six BYTE 0									; Counter for # of 6s in row/col/box
	seven BYTE 0								; Counter for # of 7s in row/col/box
	eight BYTE 0								; Counter for # of 8s in row/col/box
	nine BYTE 0									; Counter for # of 9s in row/col/box
	Start_Pointer DWORD ?						; Save starting location of the matrix
.code
Test_Sudoku PROC
	mov eax, 1									; Assume matrix is valid
	mov Start_Pointer, edx						; Save copy of starting location from EDX
	call Test_Sudoku_Row						; Test first row for validity
	add edx, 9									; Move edx to point to box 9 (box 1 of row 2)
	call Test_Sudoku_Row						; Test second row for validity
	add edx, 9									; Move edx to point to box 18 (box 1 of row 3)
	call Test_Sudoku_Row						; Test third row for validity
	add edx, 9									; Move edx to point to box 27 (box 1 of row 4)
	call Test_Sudoku_Row						; Test fourth row for validity
	add edx, 9									; Move edx to point to box 36 (box 1 of row 5)
	call Test_Sudoku_Row						; Test fifth row for validity
	add edx, 9									; Move edx to point to box 45 (box 1 of row 6)
	call Test_Sudoku_Row						; Test sixth row for validity
	add edx, 9									; Move edx to point to box 54 (box 1 of row 7)
	call Test_Sudoku_Row						; Test seventh row for validity
	add edx, 9									; Move edx to point to box 63 (box 1 of row 8)
	call Test_Sudoku_Row						; Test eighth row for validity
	add edx, 9									; Move edx to point to box 72 (box 1 of row 9)
	call Test_Sudoku_Row						; Test ninth row for validity
	mov edx, Start_Pointer						; Reset EDX to starting pointer address, just in case
	call Test_Sudoku_Col						; Test first Col for validity
	inc edx										; Move edx to point to box 1 (box 1 of Col 2)
	call Test_Sudoku_Col						; Test second Col for validity
	inc edx										; Move edx to point to box 2 (box 1 of Col 3)
	call Test_Sudoku_Col						; Test third Col for validity
	inc edx										; Move edx to point to box 3 (box 1 of Col 4)
	call Test_Sudoku_Col						; Test fourth Col for validity
	inc edx										; Move edx to point to box 4 (box 1 of Col 5)
	call Test_Sudoku_Col						; Test fifth Col for validity
	inc edx										; Move edx to point to box 5 (box 1 of Col 6)
	call Test_Sudoku_Col						; Test sixth Col for validity
	inc edx										; Move edx to point to box 6 (box 1 of Col 7)
	call Test_Sudoku_Col						; Test seventh Col for validity
	inc edx										; Move edx to point to box 7 (box 1 of Col 8)
	call Test_Sudoku_Col						; Test eighth Col for validity
	inc edx										; Move edx to point to box 8 (box 1 of Col 9)
	call Test_Sudoku_Col						; Test ninth Col for validity
	mov edx, Start_Pointer						; Reset EDX to starting pointer address, just in case
	call Test_Sudoku_Box						; Test first Col for validity
	add edx, 3									; Move edx to point to box 3 (box 1 of Box 2)
	call Test_Sudoku_Box						; Test second Box for validity
	add edx, 3									; Move edx to point to box 6 (box 1 of Box 3)
	call Test_Sudoku_Box						; Test third Box for validity
	add edx, 21									; Move edx to point to box 27 (box 1 of Box 4)
	call Test_Sudoku_Box						; Test fourth Box for validity
	add edx, 3									; Move edx to point to box 30 (box 1 of Box 5)
	call Test_Sudoku_Box						; Test fifth Box for validity
	add edx, 3									; Move edx to point to box 33 (box 1 of Box 6)
	call Test_Sudoku_Box						; Test sixth Box for validity
	add edx, 21									; Move edx to point to box 54 (box 1 of Box 7)
	call Test_Sudoku_Box						; Test seventh Box for validity
	add edx, 3									; Move edx to point to box 57 (box 1 of Box 8)
	call Test_Sudoku_Box						; Test eighth Box for validity
	add edx, 3									; Move edx to point to box 60 (box 1 of Box 9)
	call Test_Sudoku_Box						; Test ninth Box for validity
	ret											; Return to procedure from which called
Test_Sudoku ENDP

;Tests 9 adjacent array indices for uniqueness (with the exception of 0)
;Initial indices passed in via EDX, uniqueness passed out as 1 in EAX
Test_Sudoku_Row PROC
	mov one, 0									; Reset counter to 0
	mov two, 0									; Reset counter to 0
	mov three, 0								; Reset counter to 0
	mov four, 0									; Reset counter to 0
	mov five, 0									; Reset counter to 0
	mov six, 0									; Reset counter to 0
	mov seven, 0								; Reset counter to 0
	mov eight, 0								; Reset counter to 0
	mov nine, 0									; Reset counter to 0
	mov ecx, 0									; Reset counter to 0
A0: mov bl, [edx]								; Set BL to box value found at the address stored in EDX
	.IF bl == 1									; If BL is equal to one
		inc one									; Increment the 1s counter
	.ELSEIF bl == 2								; If BL is equal to two
		inc two									; Increment the 2s counter
	.ELSEIF bl == 3								; If BL is equal to three
		inc three								; Increment the 3s counter
	.ELSEIF bl == 4								; If BL is equal to four
		inc four								; Increment the 4s counter
	.ELSEIF bl == 5								; If BL is equal to five
		inc five								; Increment the 5s counter
	.ELSEIF bl == 6								; If BL is equal to six
		inc six									; Increment the 6s counter
	.ELSEIF bl == 7								; If BL is equal to seven
		inc seven								; Increment the 7s counter
	.ELSEIF bl == 8								; If BL is equal to eight
		inc eight								; Increment the 8s counter
	.ELSEIF bl == 9								; If BL is equal to nine
		inc nine								; Increment the 9s counter
	.ENDIF										; 
	.IF ecx < 8									; If the loop counter is less than 8
		inc ecx									; Increment loop counter
		inc edx									; Increment EDX pointer address to next box
	.ELSE										; If the loop counter is equal to 8
		sub edx, 8								; Adjust EDX pointer address back to original value
		jmp A1									; Jump to check # counters
	.ENDIF										;
	jmp A0										; Jump to beginning of loop
												;
												; If any # counter is above 1
A1: .IF ((one > 1) || (two > 1) || (three > 1) || (four > 1) || (five > 1) || (six > 1) || (seven > 1) || (eight > 1) || (nine > 1))
		mov eax, 0								; Set EAX equal to 0 to signify invalidity
	.ENDIF
	ret											; Return to procedure from which called
Test_Sudoku_Row ENDP

;Tests 9 array indices, each 9 apart from each other, for uniqueness (with the exception of 0)
;Initial indices passed in via EDX, uniqueness passed out as 1 in EAX
Test_Sudoku_Col PROC
	mov one, 0									; Reset counter to 0
	mov two, 0									; Reset counter to 0
	mov three, 0								; Reset counter to 0
	mov four, 0									; Reset counter to 0
	mov five, 0									; Reset counter to 0
	mov six, 0									; Reset counter to 0
	mov seven, 0								; Reset counter to 0
	mov eight, 0								; Reset counter to 0
	mov nine, 0									; Reset counter to 0
	mov ecx, 0									; Reset counter to 0
A0: mov bl, [edx]								; Set BL to box value found at the address stored in EDX
	.IF bl == 1									; If BL is equal to one
		inc one									; Increment the 1s counter
	.ELSEIF bl == 2								; If BL is equal to two
		inc two									; Increment the 2s counter
	.ELSEIF bl == 3								; If BL is equal to three
		inc three								; Increment the 3s counter
	.ELSEIF bl == 4								; If BL is equal to four
		inc four								; Increment the 4s counter
	.ELSEIF bl == 5								; If BL is equal to five
		inc five								; Increment the 5s counter
	.ELSEIF bl == 6								; If BL is equal to six
		inc six									; Increment the 6s counter
	.ELSEIF bl == 7								; If BL is equal to seven
		inc seven								; Increment the 7s counter
	.ELSEIF bl == 8								; If BL is equal to eight
		inc eight								; Increment the 8s counter
	.ELSEIF bl == 9								; If BL is equal to nine
		inc nine								; Increment the 9s counter
	.ENDIF										; 
	.IF ecx < 8									; If the loop counter is less than 8
		inc ecx									; Increment loop counter
		add edx, 9								; Increment EDX pointer address to next box in the column
	.ELSE										; If the loop counter is equal to 8
		sub edx, 72								; Adjust EDX pointer address back to original value
		jmp A1									; Jump to check # counters
	.ENDIF										;
	jmp A0										; Jump to beginning of loop
												;
												; If any # counter is above 1
A1: .IF ((one > 1) || (two > 1) || (three > 1) || (four > 1) || (five > 1) || (six > 1) || (seven > 1) || (eight > 1) || (nine > 1))
		mov eax, 0								; Set EAX equal to 0 to signify invalidity
	.ENDIF
	ret											; Return to procedure from which called
Test_Sudoku_Col ENDP 

;Tests 9 array indices, a set of 3 adjacent, followed by another set 7 indices away,
;followed by a final set another 7 indices away, for uniqueness (with the exception of 0)
;Initial indices passed in via EDX, uniqueness passed out as 1 in EAX
Test_Sudoku_Box PROC
	mov one, 0									; Reset counter to 0
	mov two, 0									; Reset counter to 0
	mov three, 0								; Reset counter to 0
	mov four, 0									; Reset counter to 0
	mov five, 0									; Reset counter to 0
	mov six, 0									; Reset counter to 0
	mov seven, 0								; Reset counter to 0
	mov eight, 0								; Reset counter to 0
	mov nine, 0									; Reset counter to 0
	mov ecx, 0									; Reset counter to 0
A0: mov bl, [edx]								; Set BL to box value found at the address stored in EDX
	.IF bl == 1									; If BL is equal to one
		inc one									; Increment the 1s counter
	.ELSEIF bl == 2								; If BL is equal to two
		inc two									; Increment the 2s counter
	.ELSEIF bl == 3								; If BL is equal to three
		inc three								; Increment the 3s counter
	.ELSEIF bl == 4								; If BL is equal to four
		inc four								; Increment the 4s counter
	.ELSEIF bl == 5								; If BL is equal to five
		inc five								; Increment the 5s counter
	.ELSEIF bl == 6								; If BL is equal to six
		inc six									; Increment the 6s counter
	.ELSEIF bl == 7								; If BL is equal to seven
		inc seven								; Increment the 7s counter
	.ELSEIF bl == 8								; If BL is equal to eight
		inc eight								; Increment the 8s counter
	.ELSEIF bl == 9								; If BL is equal to nine
		inc nine								; Increment the 9s counter
	.ENDIF										; 
	.IF ((ecx == 2) || (ecx == 5))				; If the loop counter is at the edge of the box
		inc ecx									; Increment loop counter
		add edx, 7								; Increment EDX pointer address to left side of box, next column
	.ELSEIF ecx < 8								; If the loop counter is less than 8
		inc ecx									; Increment loop counter
		inc edx									; Increment EDX pointer address to next box in the column
	.ELSE										; If the loop counter is equal to 8
		sub edx, 20								; Adjust EDX pointer address back to original value
		jmp A1									; Jump to check # counters
	.ENDIF										;
	jmp A0										; Jump to beginning of loop
												;
												; If any # counter is above 1
A1: .IF ((one > 1) || (two > 1) || (three > 1) || (four > 1) || (five > 1) || (six > 1) || (seven > 1) || (eight > 1) || (nine > 1))
		mov eax, 0								; Set EAX equal to 0 to signify invalidity
	.ENDIF
	ret											; Return to procedure from which called
Test_Sudoku_Box ENDP 