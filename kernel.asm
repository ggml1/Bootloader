org 0x7e00
jmp 0x0000:START

%macro random 1
    mov word [modulo], %1
    call RAND
%endmacro

modulo dw 0

RAND:
    mov ah, 00h ; interrupt to get system time
    int 1ah     ; CX:DX has number of clock ticks since midnight (00:00)
    mov ax, dx
    xor dx, dx
    mov cx, word [modulo]
    div cx
    mov cx, 1
    ret

START:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov bl, 15
    mov al, 10h
    int 10h

  	call RESET_CURSOR

  	call PRINT_LOGO

    mov ah, 2
    mov bh, 0
    mov dh, 14
    mov dl, 17
   	int 10h

    mov si, login
    call PRINT

    mov di, username ; READ occurs in di
    call READ

    call CLEAR_SCREEN

    startBegin:
        mov si, startHeader1
        call PRINT_COLOR

        mov si, startHeader2
        call PRINT_COLOR

        mov si, startHeader3
        call PRINT

        mov si, startHeader4
        call PRINT_COLOR

        mov si, startHeader5
        call PRINT_COLOR

    .while:
        mov si, username
        call PRINT_COLOR

        mov si, aux
        call PRINT

        mov di, command
        call READ

        call ANALYZE_COMMAND

        jmp .while

    jmp end

STRCMP:
    lodsb ; getting current char pointed by SI and putting it on AL
    ;;;;;;
    ; mov ah, 0xe
    ; mov bh, 0
    ; int 10h ;;debug

    cmp byte[di], al ;comparing loaded byte from [ES:SI] with [ES:DI]

    jne .false ; if different, then strings aren't equal

    cmp al, 0 ; string end? then analyze if it is also the end of the other one
    je .si_end

    cmp byte[di], 0 ; same as above
    je .di_end

    inc di

    jmp STRCMP

    .si_end:
        cmp byte[di], 0
        je .true
        jmp .false
    .di_end:
        cmp al, 0
        je .true
        jmp .false
    .true:
        mov cx, 1
        ret
    .false:
        mov cx, 0
        ret

RESET_CURSOR:
    mov ah, 2
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    ret

GENERATE_RANDOM_NUMBER:
    random 1000

    mov dh, 0
    mov ax, dx

    ret

ANALYZE_COMMAND:

    .help:
        mov di, command
        mov si, help
        xor cx, cx
        call STRCMP
        cmp cl, 0
        je .clear ; if its not help, try exit

        mov si, menu1
        call PRINT

        mov si, menu2
        call PRINT

        mov si, getHelpChoice
        call PRINT

        mov di, temp
        call READ

        mov di, temp
        mov si, choice1 ; comparing with '1'
        call STRCMP
        cmp cl, 1
        je .help.choice1

        mov di, temp
        mov si, choice2 ; comparing with '2'
        call STRCMP
        cmp cl, 1
        je .help.choice2

        jmp .error

        .help.choice1:
            mov si, availableCommands1
            call PRINT

            mov si, availableCommands2
            call PRINT

            mov si, availableCommands3
            call PRINT

            mov si, availableCommands4
            call PRINT

            mov si, availableCommands5
            call PRINT

            mov si, availableCommands6
            call PRINT

            mov si, availableCommands7
            call PRINT

            mov si, availableCommands8
            call PRINT

            jmp .done

        .help.choice2:
            mov si, creditsHelp
            call PRINT

            jmp .done
    .clear:
        mov di, command
        mov si, clearCommand
        call STRCMP
        cmp cl, 0
        je .game ; if command is not clear, try game

        call CLEAR_SCREEN

        jmp .done

    .game:
        mov di, command
        mov si, gameCommand
        call STRCMP
        cmp cl, 0
        je .exit ; if command is not game, try exit

        mov si, gamePresentation1
        call PRINT

        mov si, gamePresentation2
        call PRINT

        mov si, gamePresentation3
        call PRINT

        mov si, gamePresentation4
        call PRINT

        mov si, gamePresentation5
        call PRINT

        mov si, gamePresentation6
        call PRINT

        mov si, gamePresentation7
        call PRINT

        mov si, gamePresentation8
        call PRINT

        mov si, gamePresentation9
        call PRINT

        mov si, gamePresentation10
        call PRINT

        mov si, gamePresentation11
        call PRINT

        mov si, gamePresentation12
        call PRINT

        mov si, gamePresentation13
        call PRINT

        mov di, temp
        call READ

        mov di, temp
        mov si, y
        call STRCMP
        cmp cl, 0
        je .done

        call GENERATE_RANDOM_NUMBER

        push ax

        xor dx, dx

        .game.while:
            cmp dl, 10
            je .game.tooManyTries

            inc dl

            mov si, askInput
            call PRINT

            mov di, guess
            call READ

            mov di, guessNumber
            mov si, guess
            call transform

            mov di, guessNumber
            mov ah, byte[di]
            inc di
            mov al, byte[di]
            dec di

            mov bx, ax

            pop ax

            cmp ax, bx
            jg .game.high

            cmp ax, bx
            jl .game.low

            mov si, correctAnswer1
            call PRINT_COLOR

            mov si, correctAnswer2
            call PRINT

            mov si, correctAnswer3
            call PRINT_COLOR

            jmp .game.done

        .game.high:
            push ax

            mov si, numberIsHigher
            call PRINT_COLOR
            jmp .game.while

        .game.low:
            push ax

            mov si, numberIsLower
            call PRINT_COLOR
            jmp .game.while

        .game.tooManyTries:
            mov si, wrongAnswer1
            call PRINT_COLOR

            mov si, wrongAnswer2
            call PRINT

            mov si, wrongAnswer3
            call PRINT_COLOR

            pop ax

            jmp .game.done

        .game.done:
            jmp .done

    .exit:
        mov di, command
    	mov si, exit
    	xor cx, cx
    	call STRCMP
    	cmp cl, 0
    	je .credits ; if its not exit, try credits

    	mov si, ctz
    	call PRINT

    	mov di, temp
    	call READ

    	mov di, temp
    	mov si, y

    	call STRCMP
    	cmp cl, 1
    	je end

    	jmp .done

    .credits:
        mov di, command
        mov si, creditsCommand
        xor cx, cx
        call STRCMP
        cmp cl, 0
        je .add ; if not credits, try add

        mov si, credits0
        call PRINT

        mov si, credits1
        call PRINT

        mov si, credits2
        call PRINT

        mov si, credits3
        call PRINT

        mov si, credits4
        call PRINT

        mov si, credits5
        call PRINT

        jmp .done

    .add:
        mov di, command
    	mov si, addCommand
    	xor cx, cx
    	call STRCMP
    	cmp cl, 0
    	je .sub ; if its not add, try sub

    	mov si, escolha
    	call PRINT

    	call READ_NUMBER

        add ax, bx

		mov di, valuef
		mov byte[di], ah
		inc di
		mov byte[di], al
		dec di

		mov si, valuef
		mov di, numf
		call transform2

		mov si, numf
		call inverte_str

		mov si, numf
		call PRINT

        ; continue addition
        jmp .done

    .sub:
        mov di, command
        mov si, subCommand
        xor cx, cx
        call STRCMP
        cmp cl, 0
        je .mult ; if its not sub, try mult

        mov si, escolhaSub
        call PRINT

        call READ_NUMBER

        mov cx, 0
        cmp ax, bx
        jge .positivo

        mov cx, 1

        xor ax, bx
        xor bx, ax ; swap
        xor ax, bx

        .positivo:
            sub ax, bx

            cmp cx, 0
            je .certo

            mov si, menos
            push ax
            call PRINT
            pop ax

        .certo:
            mov di, valuef
            mov byte[di], ah
            inc di
            mov byte[di], al
            dec di

            mov si, valuef
            mov di, numf
            call transform2

            mov si, numf
            call inverte_str

            mov si, numf
            call PRINT

        ; work sub
        jmp .done

    .mult:
        mov di, command
        mov si, multCommand
        xor cx, cx
        call STRCMP
        cmp cl, 0
        je .div ; if its not mult, try div

        mov si, escolhaMult
        call PRINT

        call READ_NUMBER

        mul bx

        mov di, valuef
        mov byte[di], ah
        inc di
        mov byte[di], al
        dec di

        mov si, valuef
        mov di, numf
        call transform2

        mov si, numf
        call inverte_str

        mov si, numf
        call PRINT

        ; work mult
        jmp .done

    .div:
        mov di, command
        mov si, divCommand
        xor cx, cx
        call STRCMP
        cmp cl, 0
        je .error ; if its not sub, then its error

        mov si, escolhaDiv
        call PRINT

        call READ_NUMBER

	mov si, value2
	mov di, zeroString
	call STRCMP
	cmp cl, 0
	je .div.byZero
	
	mov si, quotientResult
        call PRINT

        mov si, value1
        mov ah, byte[si]
        inc si
        mov al, byte[si]

        mov si, value2
        mov bh, byte[si]
        inc si
        mov bl, byte[si]
        dec si

        xor dx, dx

	cmp bx, 0
	je .div.byZero	
	
        div bx

        mov di, valuef
        mov byte[di], ah
        inc di
        mov byte[di], al
        dec di

        mov si, valuef
        mov di, numf
        call transform2

        mov si, numf
        call inverte_str

        mov si, numf
        call PRINT

        mov si, remainderResult
        call PRINT

        mov si, value1
        mov ah, byte[si]
        inc si
        mov al, byte[si]

        mov si, value2
        mov bh, byte[si]
        inc si
        mov bl, byte[si]
        dec si

        xor dx, dx
        div bx

        mov ax, dx

        mov di, valuef
        mov byte[di], ah
        inc di
        mov byte[di], al
        dec di

        mov si, valuef
        mov di, numf
        call transform2

        mov si, numf
        call inverte_str

        mov si, numf
        call PRINT

        ; work div
        jmp .done

    .div.byZero:
	mov si, divByZero
	call PRINT

	jmp .done
    .error:
        mov di, command
        mov si, unknownCommand
        call PRINT

        jmp .done

    .done:
        ret

READ_NUMBER:
    mov di, num1
    call READ

    mov di, value1
    mov si, num1
    call transform

    mov di, num2
    call READ

    mov di, value2
    mov si, num2
    call transform

    mov di, value1
    mov ah, byte[di]
    inc di
    mov al, byte[di]
    dec di

    mov di, value2
    mov bh, byte[di]
    inc di
    mov bl, byte[di]
    dec di

    ret

transform2:
    mov bh, byte[si]
    inc si
    mov bl, byte[si]
    dec si
    cmp bx, 0
    je .end2
    mov ch, 0
    mov cl, 10
    .for1:
        cmp bx, 0
        je .end
        mov ax, bx
        mov dx, 0
        div cx
        mov bx, ax
        mov ax, dx
        add al, '0'
        stosb
        jmp .for1
    .end:
        mov al, 0
        stosb
        ret
    .end2:
    	mov al, '0'
    	stosb
    	mov al, 0
    	stosb
    	ret

transform:
    xor ax, ax
	xor bx, bx
    xor cl, cl
    .for1:
    	push si
    	mov ch, 0
    	add si, cx
    	mov ch, byte[si]
        cmp ch, 0
        je .end
    	sub ch, '0'
        mov ax, 0
        mov al, 10
        mul bl
        mov bx, ax
    	add bl, ch
    	inc cl
    	pop si
    	jmp .for1

    .end:
    	mov byte[di], bh
    	inc di
        mov byte[di], bl
        dec di
    	pop si
    	ret

inverte_str:
	xor cx, cx
	.for1:
		mov dx, si
		add si, cx
		cmp byte[si], 0
		je .endfor1
		movzx bx, byte[si]
		push bx
		mov si, dx
		inc cx
		jmp .for1


	.endfor1:
		mov si, dx
		xor ax, ax
		.for2:
			cmp ax, cx
			je .end
			mov dx, si
			add si, ax
			pop bx
			mov byte[si], bl
			inc ax
			mov si, dx
			jmp .for2
		.end:
			mov si, dx
			add si, cx
			mov byte[si], 10
			mov si, dx
			add si, cx
			add si, 1
			mov byte[si], 13
			add si, 1
			mov byte[si], 0
			ret

READ:
    xor cx, cx
    mov bl, 15

    .for1:
        mov ah, 0
        int 16h
        cmp al, 0x0d ;string end
        je .end
        cmp al, 0x08
        je .backspace
        mov ah, 0x0e
        int 10h
        inc cx
        stosb
        jmp .for1
    .backspace:
        cmp cl, 0 ; goes back if theres nothing to erase
        je .for1

        ; removing last character
        dec cx
        dec di

        mov ah, 0x0e
        mov al, 0x08 ;;printing backspace
        int 10h

        mov al, 0x20 ;;printing space
        int 10h

        mov al, 0x08 ;printing backspace again
        int 10h

        jmp .for1
    .end:
        mov al, 0
        stosb

        mov ah, 0x0e
        mov al, 10
        int 10h

        mov al, 13
        int 10h

        ret

PRINT_COLOR:
    lodsb
    cmp al, 0
    je .done

    mov ah, 0xe
    mov bl, 2
    int 10h

    jmp PRINT_COLOR

    .done:
        ret

PRINT:
    lodsb
    cmp al, 0
    je .done

    mov ah, 0xe
    mov bl, 15
    int 10h

    jmp PRINT
    .done:
        ret

CLEAR_SCREEN:
    mov dx, 4500
    xor cx, cx

    .while:
        mov ah, 0x0e
        mov al, 0x20 ;print space
        int 10h

        dec dx
        cmp dx, 0
        je .end
        jmp .while

    .end:
        mov ah, 2
        mov bh, 0
        mov dh, 0
        mov dl, 0
        int 10h

        jmp startBegin

PRINT_LOGO:
 	mov ah, 2
    mov bh, 0
    mov dh, 2
    mov dl, 7
   	int 10h

	mov si, line1
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 3
    mov dl, 7
   	int 10h

	mov si, line2
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 4
    mov dl, 7
   	int 10h

	mov si, line3
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 5
    mov dl, 7
   	int 10h

	mov si, line4
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 6
    mov dl, 7
   	int 10h

	mov si, line5
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 7
    mov dl, 7
   	int 10h

	mov si, line6
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 8
    mov dl, 7
   	int 10h

	mov si, line7
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 9
    mov dl, 7
   	int 10h

	mov si, line8
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 10
    mov dl, 7
   	int 10h

	mov si, line9
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 11
    mov dl, 7
   	int 10h

	mov si, line10
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 12
    mov dl, 7
   	int 10h

	mov si, line11
	call PRINT_COLOR

	mov ah, 2
    mov bh, 0
    mov dh, 13
    mov dl, 7
   	int 10h

	ret

end:
    jmp $

var:
    menos db '-', 0
    login db 'Type your login: ', 0
    aux db '@cin:~$  ', 0
    line1  db  ' .----------------.   .----------------.   .----------------. ', 10, 13, 0
	line2  db  '| .--------------. | | .--------------. | | .--------------. |', 10, 13, 0
	line3  db  '| |   _____      | | | |    _______   | | | | ____    ____ | |', 10, 13, 0
	line4  db  '| |  |_   _|     | | | |   / ____  |  | | | ||_   \  /   _|| |', 10, 13, 0
	line5  db  '| |    | |       | | | |  / /    \_|  | | | |  |   \/   |  | |', 10, 13, 0
	line6  db  '| |    | |   _   | | | |  | |         | | | |  | |\  /| |  | |', 10, 13, 0
	line7  db  '| |   _| |__/ |  | | | |  \ \_____/\  | | | | _| |_\/_| |_ | |', 10, 13, 0
	line8  db  '| |  |________|  | | | |   \_______/  | | | ||_____||_____|| |', 10, 13, 0
	line9  db  '| |              | | | |              | | | |              | |', 10, 13, 0
	line10 db  '| |--------------| | | |--------------| | | |--------------| |', 10, 13, 0
	line11 db  ' ------------------   ------------------   ------------------ ', 10, 13, 0
    username: times 20 db 0
    command: times 20 db 0
    num1: times 10 db 0
    num2: times 10 db 0
    numf: times 10 db 0
    value1: times 4 db 0
    value2: times  4 db 0
    valuef: times 4 db 0
    temp: times 10 db 0
    guess: times 10 db 0
    generated: times 6 db 0
    answer: times 6 db 0
    guessNumber: times 20 db 0
    startHeader1 db 'LCM Terminal - Version 16.23.49.1', 10, 13, 0
    startHeader2 db 'Type ', 0
    startHeader3 db '"help" ', 0
    startHeader4 db 'for more information.', 10, 13, 0
    startHeader5 db '---------------------------------', 10, 13, 0
    askInput db 'Enter your guess: (positive integer): ', 0
    numberIsLower  db '---- The answer is lower than your input  ----', 10, 13, 0
    numberIsHigher db '---- The answer is higher than your input ----', 10, 13, 0
    correctAnswer1 db 10, '******************************************************', 10, 13, 0
    correctAnswer2 db     '****** You guessed the number! Congratulations! ******', 10, 13, 0
    correctAnswer3 db     '******************************************************', 10, 10, 13, 0
    wrongAnswer1 db 10, '**************************************************************', 10, 13, 0
    wrongAnswer2 db     '****** You took too long to find the number. Try again! ******', 10, 13, 0
    wrongAnswer3 db     '**************************************************************', 10, 10, 13, 0
    gamePresentation1  db 10, '********************* SMART GUESSING *********************', 10, 13, 0
    gamePresentation2  db '** This games objective is to correctly guess which     **', 10, 13, 0
    gamePresentation3  db '** number the computer has randomly generated, ranging  **', 10, 13, 0
    gamePresentation4  db '** from 0 to 999 (inclusive). On each round, you will   **', 10, 13, 0
    gamePresentation5  db '** enter a number you think is the right one. If your   **', 10, 13, 0
    gamePresentation6  db '** number is higher than the answer, the computer will  **', 10, 13, 0
    gamePresentation7  db '** output LOWER, and HIGHER if it is lower. If you get  **', 10, 13, 0
    gamePresentation8  db '** a congratulation message, it means you chose the     **', 10, 13, 0
    gamePresentation9  db '** correct number and the game is terminated.           **', 10, 13, 0
    gamePresentation10 db '**                                                      **', 10, 13, 0
    gamePresentation11 db '** BE CAREFUL: YOU ONLY HAVE 10 TRIES. If you do not    **', 10, 13, 0
    gamePresentation12 db '** answer correctly in 10 tries, you will lose the game **', 10, 13, 0
    gamePresentation13 db '******************* INPUT "Y" TO BEGIN  ******************', 10, 13, 0
    debug db 'debug', 10, 13, 0
    help db 'help', 0
    exit db 'exit', 0
    menu1 db '(op) Operations', 10, 13, 0
    menu2 db '(cr) Credits', 10, 13, 0
    getHelpChoice db 10, 'Your choice: ', 0
    choice1 db 'op', 0
    choice2 db 'cr', 0
    creditsHelp db 10, 13, 'Type credits on the terminal to see that section.', 10, 13, 0
    creditsCommand db 'credits', 0
    addCommand db 'add', 0
    subCommand db 'sub', 0
    multCommand db 'mult', 0
    divCommand db 'div', 0
    gameCommand db 'play game', 0
    quotientResult db 'Quotient: ', 0
    remainderResult db 'Remainder: ', 0
    clearCommand db 'clear', 0
    availableCommands1 db 10, 13, 'There are 7 commands you can use: ', 10, 13, 0
    availableCommands2 db 'Addition: type "add" for more info.', 10, 13, 0
    availableCommands3 db 'Subtraction: type "sub" for more info.', 10, 13, 0
    availableCommands4 db 'Multiplication: type "mult" for more info.', 10, 13, 0
    availableCommands5 db 'Division: type "div" for more info.', 10, 13, 0
    availableCommands6 db 'Clear screen: type "clear".', 10, 13, 0
    availableCommands7 db 'Guessing game: type "play game".', 10, 13, 0
    availableCommands8 db 'Exit terminal: type "exit".', 10, 13, 0
    unknownCommand db 'Unknown command. Type help for more information.', 10, 13, 0
    ctz db 'Are you sure you want to exit the program?', 10, 13, '[Y/N]', 10, 13, 0
    escolha db 'Input two numbers to be added, one on each line: ', 10, 13, 0
    escolhaMult db 'Input two numbers to be multiplied, one on each line: ', 10, 13, 0
    escolhaDiv db 'Input two numbers to be divided, one on each line: ', 10, 13, 0
    escolhaSub db 'Input two numbers to be subtracted, one on each line: ', 10, 13, 0
    divByZero db 'You cant divide by zero. Choose another number and try again.', 10, 13, 0
    y db 'Y', 0
    zeroString db '0', 0
    credits0 db 10, '-----------------------------------------', 10, 13, 0
    credits1 db '------- Bootloader created by:   --------', 10, 13, 0
    credits2 db '------- Gabriel Mendes  - @ggml  --------', 10, 13, 0
    credits3 db '------- Matheus Leon    - @mlan  --------', 10, 13, 0
    credits4 db '------- Clodes Fernando - @cfms3 --------', 10, 13, 0
    credits5 db '-----------------------------------------', 10, 10, 13, 0

; 10 is \n
; 13 is tab to go back to line begin
