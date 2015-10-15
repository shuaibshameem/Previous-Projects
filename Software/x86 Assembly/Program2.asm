INCLUDE Irvine32.inc
.code


;-------------- BEGIN STUDENT CODE ------------------------------------------------
; (You may replace this block of code with "INCLUDE Test_Sudoku.asm", and then
; edit only that file when developing code.) Only submit code for this procedure:

INCLUDE Test_Sudoku.asm


;-------------- END STUDENT CODE --------------------------------------------------


Main PROC
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester -- Program #2
    ; October 6, 2011


    ; This code draws a Sudoku matrix, allows the user to enter or erase numbers,
    ; and thus helps students debug their procedure "Test_Sudoku" (which is called
    ; by this procedure after each number is entered; an illegal entry causes that
    ; value to flash on the screen a few times and then disappear).
    ;
    ; The Sudoku matrix is stored as a contiguous string of 81 bytes. These bytes
    ; will only contain unsigned codes for values 0-9 (0 is an uninitialized cell).
    ; The bytes are in row-wise (left-to-right, top-to-down) scan format.
    ;
    ; The single parameter passed to procedure "Test_Sudoku" is the starting address
    ; of these 81 bytes in memory, which is passed in register edx.
    ;
    ; Procedure "Test_Sudoku" passes back eax=1 if the matrix is found to be valid
    ; according to Sudoku rules of legality, and eax=0 if not valid.
    ;


    .data
        Sudoku_Matrix BYTE 81 dup(0)
        Cursor_Row   BYTE  ?
        Cursor_Col   BYTE  ?
        Temp_Dword   DWORD ?
    .code


    call Draw_Sudoku_Matrix


    ; Position cursor in upper left cell of the Sudoku grid
    mov Cursor_Row,0
    mov Cursor_Col,0


Get_User_Input:

    ; Redraw the Sudoku matrix values on the display
    call Update_Sudoku_Matrix

    call Update_Cursor

    call ReadChar

    .IF (al=='l')||(al=='L')
        jmp Square_Left
    .ELSEIF (al=='r')||(al=='R')
        jmp Square_Right
    .ELSEIF (al=='u')||(al=='U')
        jmp Square_Up
    .ELSEIF (al=='d')||(al=='D')
        jmp Square_Down
    .ELSEIF (al=='0')||(al==' ')
        ; blank square
        mov al,' '
        call WriteChar
        mov al,0
        call Write_Sudoku_Matrix
        jmp Square_Right
    .ELSEIF (al>='1')&&(al<='9')
        ; a number was entered
        sub al,'0'                 ; convert '1'-'9' to 1-9
        mov ah,al                  ; store the value in ah temporarily
        call Read_Sudoku_Matrix    ; AL returns the previous value at (Row,Col)
        ror ax,8                   ; swap AL and AH contents
        call Write_Sudoku_Matrix   ; AH stores previous value, user input sent to mem.

        pushad                     ; save all doubleword registers on stack
        mov edx,OFFSET Sudoku_Matrix
        call Test_Sudoku           ; EDX sends address of Sudoku_Matrix,
                                   ; EAX returns value of 1 (valid) or 0 (invalid)
        mov Temp_Dword,eax
        popad                      ; restore all doubleword registers
        mov eax,Temp_Dword         ; I had to do this for ease of testing many students' code...

        .IF (eax==1)
            ; legal input
            jmp Square_Right
        .ELSEIF (eax==0)
            ; illegal input
            call Flash_Value           ; flash the illegal input value a few times, then ignore
            mov al,ah
            call Write_Sudoku_Matrix   ; previous value is restored
        .ELSE
            ; eax has returned neither 1 nor 0, so terminate the program
            jmp Quit
        .ENDIF
    .ENDIF

    jmp Get_User_Input


Square_Left:

    .IF (Cursor_Col==0)
        mov Cursor_Col,8
        jmp Square_Up
    .ELSE
        dec Cursor_Col
    .ENDIF
    call Get_User_Input


Square_Right:

    .IF (Cursor_Col==8)
        mov Cursor_Col,0
        jmp Square_Down
    .ELSE
        inc Cursor_Col
    .ENDIF
    call Get_User_Input


Square_Up:

    .IF (Cursor_Row==0)
        mov Cursor_Row,8
    .ELSE
        dec Cursor_Row
    .ENDIF
    call Get_User_Input


Square_Down:

    .IF (Cursor_Row==8)
        mov Cursor_Row,0
    .ELSE
        inc Cursor_Row
    .ENDIF
    jmp Get_User_Input


Quit:
    ;illegal value returned in eax from "Test_Sudoku" -- stop execution
    exit
Main ENDP


Draw_Sudoku_Matrix PROC
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; This procedure draws the grid lines for a Sudoku matrix in the
    ; command window.

    .data
        String1 BYTE 20 dup(' '),0C9h
                BYTE  2 dup(2 dup(3 dup(0CDh),0D1h),3 dup(0CDh),0CBh)
                BYTE        2 dup(3 dup(0CDh),0D1h),3 dup(0CDh),0BBh,0
        String2 BYTE 20 dup(' '),0BAh
                BYTE  2 dup(2 dup(3 dup(020h),0B3h),3 dup(020h),0BAh)
                BYTE        2 dup(3 dup(020h),0B3h),3 dup(020h),0BAh,0
        String3 BYTE 20 dup(' '),0C7h
                BYTE  2 dup(2 dup(3 dup(0C4h),0C5h),3 dup(0C4h),0D7h)
                BYTE        2 dup(3 dup(0C4h),0C5h),3 dup(0C4h),0B6h,0
        String4 BYTE 20 dup(' '),0CCh
                BYTE  2 dup(2 dup(3 dup(0CDh),0D8h),3 dup(0CDh),0CEh)
                BYTE        2 dup(3 dup(0CDh),0D8h),3 dup(0CDh),0B9h,0
        String5 BYTE 20 dup(' '),0C8h
                BYTE  2 dup(2 dup(3 dup(0CDh),0CFh),3 dup(0CDh),0CAh)
                BYTE        2 dup(3 dup(0CDh),0CFh),3 dup(0CDh),0BCh,0
        String6 BYTE "   Cursor control:",0
        String7 BYTE "   U = move up",0
        String8 BYTE "   D = move down",0
        String9 BYTE "   L = move left",0
        StringA BYTE "   R = move right",0
        StringB BYTE "   Enter 1-9,",0
        StringC BYTE "   or 0/space",0
        StringD BYTE "   for blank",0

    .code

    call ClrScr
    call Crlf
    call Crlf
    call Crlf
    mov edx,OFFSET String1
    call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
    call Crlf
    mov edx,OFFSET String3
    call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
    call Crlf
    mov edx,OFFSET String3
    call WriteString
        mov edx,OFFSET StringB
        call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
        mov edx,OFFSET StringC
        call WriteString
    call Crlf
    mov edx,OFFSET String4
    call WriteString
        mov edx,OFFSET StringD
        call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
    call Crlf
    mov edx,OFFSET String3
    call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
        mov edx,OFFSET String6
        call WriteString
    call Crlf
    mov edx,OFFSET String3
    call WriteString
        mov edx,OFFSET String7
        call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
        mov edx,OFFSET String8
        call WriteString
    call Crlf
    mov edx,OFFSET String4
    call WriteString
        mov edx,OFFSET String9
        call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
        mov edx,OFFSET StringA
        call WriteString
    call Crlf
    mov edx,OFFSET String3
    call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
    call Crlf
    mov edx,OFFSET String3
    call WriteString
    call Crlf
    mov edx,OFFSET String2
    call WriteString
    call Crlf
    mov edx,OFFSET String5
    call WriteString
    call Crlf
    ret
Draw_Sudoku_Matrix ENDP


Update_Sudoku_Matrix PROC
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; This procedure updates all of the numbers in the Sudoku matrix that is
    ; displayed in the command window, based on those stored in memory in array
    ; 'Sudoku_Matrix'.

    .data
        Cursor_Row_copy  BYTE  ?
        Cursor_Col_copy  BYTE  ?
    .code

    mov al,Cursor_Row                 ; save copy of the current cursor position
    mov Cursor_Row_copy,al
    mov al,Cursor_Col
    mov Cursor_Col_copy,al

    mov Cursor_Row,0
A1:     mov Cursor_Col,0
A2:         call Read_Sudoku_Matrix   ; AL returns value at (Cursor_Row,Cursor_Col)
            .IF (al==0)
                mov al,' '            ; display space character instead of zero
            .ELSE
                add al,'0'            ; convert 1-9 to '1'-'9'
            .ENDIF
            call Update_Cursor        ; display value inside the grid lines
            call WriteChar
            call Update_Cursor1       ; display value as it appears in linear memory
               .IF (al==' ')
                mov al,'0'            ; display zero instead of space character
            .ENDIF
            call WriteChar
       inc Cursor_Col
       cmp Cursor_Col,9
       jne A2
    inc Cursor_Row
    cmp Cursor_Row,9
    jne A1

    mov al,Cursor_Row_copy            ; restore cursor position
    mov Cursor_Row,al
    mov al,Cursor_Col_copy
    mov Cursor_Col,al
    ret
Update_Sudoku_Matrix ENDP


Read_Sudoku_Matrix PROC USES ecx edx
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; This procedure reads and returns (in al) the Sudoku matrix value
    ; that is stored at location (Cursor_Row,Cursor_Col).  Cursor_Row
    ; and Cursor_Col are existing memory bytes in the range [0,8].
    ; The base address is "Sudoku_Matrix".
    ;
    mov edx,OFFSET Sudoku_Matrix
    mov ecx,0
    mov cl,Cursor_Row
    shl cl,3    ; CL <-- 8*Cursor_Row
    add cl,Cursor_Row  ; CL <-- CL + Cursor_Row = 9*Cursor_Row
    add cl,Cursor_Col  ; CL <-- 9*Cursor_Row + Cursor_Col = matrix offset
                       ;         to desired cell
    mov al,[edx+ecx]
    ret
Read_Sudoku_Matrix ENDP


Write_Sudoku_Matrix PROC USES ecx edx
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; This procedure writes the value that is passed in al to the Sudoku
    ; matrix at location (Cursor_Row,Cursor_Col).  Cursor_Row and Cursor_Col
    ; are existing memory bytes in the range [0,8]. The base address is
    ; "Sudoku_Matrix".
    ;
    mov edx,OFFSET Sudoku_Matrix
    mov ecx,0
    mov cl,Cursor_Row
    shl cl,3    ; CL <-- 8*Cursor_Row
    add cl,Cursor_Row  ; CL <-- CL + Cursor_Row = 9*Cursor_Row
    add cl,Cursor_Col  ; CL <-- 9*Cursor_Row + Cursor_Col = matrix offset
                       ;         to desired cell
    add edx,ecx ; pointer <-- pointer + offset
    mov [edx],al
    ret
Write_Sudoku_Matrix ENDP


Update_Cursor PROC USES edx
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; input parameters: Cursor_Row,Cursor_Col (in memory)
    ; Cursor is moved to Sudoku Matrix location (Cursor_Row,Cursor_Col)
    ;
    mov dh,Cursor_Row
    shl dh,1
    add dh,4         ; dh <-- Yoffset + 2*Cursor_Row  (Yoffset=4)
    mov dl,Cursor_Col
    shl dl,2
    add dl,22        ; dl <-- Xoffset + 4*Cursor_Col  (Xoffset=22)
    call GotoXY
    ret
Update_Cursor ENDP


Update_Cursor1 PROC USES edx
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; input parameters: Cursor_Row,Cursor_Col (in memory)
    ;
    ; Cursor is moved to a spot at left of the matrix grid to a position
    ; corresponding to coordinates (Cursor_Row,Cursor_Col)
    ;
    mov dh,Cursor_Row
    add dh,8             ; dh <-- Yoffset + Cursor_Row  (Yoffset=8)
    mov dl,Cursor_Col
    add dl,5             ; dl <-- Xoffset + Cursor_Col  (Xoffset=5)
    call GotoXY
    ret
Update_Cursor1 ENDP


Flash_Value PROC USES eax ecx
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; This procedure flashes on and off (4 times) the value that is stored at
    ; Sudoku Matrix location (Cursor_Row,Cursor_Col)
    ;
    mov ecx,4
A0:     mov al,' '
        call WriteChar
        call Update_Cursor
        call Wait1
        call Read_Sudoku_Matrix
        add al,'0'
        call WriteChar
        call Update_Cursor
        call Wait1
    loop A0
    ret
Flash_Value ENDP


Wait1 PROC USES eax
    ; Vladimir Goncharoff
    ; ECE 267: Computer Organization I
    ; University of Illinois at Chicago
    ; Fall 2011 Semester
    ; October 6, 2011
    ;
    ; This procedure waits for 1/10 sec
    ;
    mov eax,100
    call Delay
    ret
Wait1 ENDP


END main