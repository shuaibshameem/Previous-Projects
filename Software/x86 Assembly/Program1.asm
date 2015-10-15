
INCLUDE Irvine32.inc

	;		**********************
	;		**  Shuaib Shameem  **
	;		**    673551999     **
	;		**	   ECE 267		**
	;		**   Goncharoff     **
	;		**    Program 1     **
	;		**********************
	
	;  **This program adds functionality for functions not defined in the handout
	;  **Pressing enter simulates a carriage return and line feed
	;  **The backspace moves between lines when the right-side is reached

.data
	X BYTE 79						; X-location Variable
	Y BYTE 0						; Y-location Variable
.code

Main PROC
loopstart:							; Label to use as a loop
		mov DL,X					; Move X-location into register DL for use in procedure Gotoxy
		mov DH,Y					; Move Y-location into register DH for use in procedure Gotoxy
		call GoToXY					; Move cursor to the location saved in X and Y
		call ReadChar				; Read the next character entered on the keyboard
		.IF (AL == 08h)				; If key pressed was Backspace, Then
			.IF (DL == 79)			;  If X-location was in right-most position, Then
				.IF (DH == 0)		;   If Y-location was in top-most position, Then
					mov AL, 20h		;    Change register AL to ASCII code for space
					call WriteChar	;    Write space to cursor position    
					jmp loopstart	;    Go back to loop start
				.ELSE				;   Else
					mov DL, 0		;    Change X-location to left-most position
					sub DH, 1		;    Reduce Y-location by 1 line
					call GoToXY		;    Move cursor to new XY location
					mov AL, 20h		;    Change register AL to ASCII code for space
					call WriteChar	;    Write space to cursor position
					mov X, DL		;    Change X to new X-location
					mov Y, DH		;    Change Y to new Y-location
					jmp loopstart	;    Go back to loop start
				.ENDIF				;   End
			.ELSE					;  Else
				add DL, 1			;   Change X-location to one space to the right
				call GoToXY			;   Move cursor to new XY location
				mov AL, 20h			;   Change register AL to ASCII code for space
				call WriteChar		;   Write space to cursor position
				mov X, DL			;   Change X to new X-Location
				jmp loopstart		;   Go back to loop start
			.ENDIF					;  End
		.ELSEIF (AL == 0Dh)			; Else if key pressed was Enter, Then
			add DH, 1				;  Change Y-location to one line down
			mov Y, DH				;  Change Y to new Y-location
			mov X, 79				;  Change X to right-most position
			jmp loopstart			;  Go back to loop start
		.ENDIF						; End
									; ***Due to above IFs, the following code only happens***
									; ***********when the above statements all fail**********
		call WriteChar				; Write inputted character to screen at cursor position
		.IF (DL == 0)				; If X-location is at left-most position, Then
			mov X, 79				;  Change X-location to right-most position
			add DH, 1				;  Change Y-location to one line below
			mov Y, DH				;  Change Y to new Y-location
		.ELSE						; Else
			sub DL, 1				;  Change X-location to one space to the left
			mov X, DL				;  Change X to new X-location
		.ENDIF						; End
		jmp loopstart				; Go back to loop start
Main ENDP

END main