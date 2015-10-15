INCLUDE Irvine32.inc
.code

INCLUDE Test_Sudoku.asm

Main PROC
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester -- Program #2
    ; October 13, 2011

    ; Modify the Sudoku matrix below to test your procedure for Program #2,
	; "Test_Sudoku.asm": the value returned in eax is displayed.

	.data
		Matrix1 BYTE 1,0,0, 0,0,0, 0,0,0  ; a legal Sudoku matrix
		        BYTE 0,2,0, 0,0,0, 0,0,0
		        BYTE 0,0,3, 0,0,0, 0,0,0

		        BYTE 4,0,0, 1,0,0, 0,0,0
		        BYTE 0,5,0, 0,2,0, 0,0,0
		        BYTE 0,0,6, 0,0,3, 0,0,0

		        BYTE 0,0,0, 0,0,0, 7,0,0
		        BYTE 0,0,0, 0,0,0, 0,8,0
		        BYTE 0,0,0, 0,0,0, 0,0,9
	.code

	mov edx,OFFSET Matrix1  ; passes address of Sudoku matrix to "Test_Sudoku"
	call Test_Sudoku        ; returns eax=1 (legal) or eax=0 (not legal)
	call WriteDec			; displays eax
	call Crlf
	
	exit

Main ENDP
	
END main