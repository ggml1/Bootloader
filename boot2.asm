org 0x500
jmp 0x0000:START

loadingKernelStructs db '- Loading structures for the kernel', 0
protectedModeSetup db '- Setting up protected mode', 0
loadingKernel db '- Loading kernel in memory', 0
running db '- Running kernel', 0
dot db '.', 0
blank db ' ', 0
newline db 10, 13, 0

START:
    xor ax, ax
    xor cx, cx
    mov ds, ax
    mov es, ax

    ; --------- video mode setup ---------
    mov ah, 0
    mov bh, 13h

    int 10h

    call COLOR_SCREEN

    mov si, loadingKernelStructs
    call PRINT_STRING
    call PRINT_DOT
    call PRINT_NEWLINE

    mov si, protectedModeSetup
    call PRINT_STRING
    call PRINT_DOT
    call PRINT_NEWLINE

    mov si, loadingKernel
    call PRINT_STRING
    call PRINT_DOT
    call PRINT_NEWLINE

    mov si, running
    call PRINT_STRING
    call PRINT_DOT
    call PRINT_NEWLINE

    call CLEAR_SCREEN

    jmp LOADKERNEL

CLEAR_SCREEN:
    mov dx, 2500

    .while:
        mov si, blank
        call PRINT_STRING
        dec dx
        cmp dx, 0
        je .end
        jmp .while
    .end:
        ; reset cursor to the top left corner
        mov ah, 0x2
        mov dx, 0
        mov bh, 0
        int 0x10

        ret

COLOR_SCREEN:
    mov ah, 0xB ; background coloring call
    mov bh, 0   ; selecting color palette
    mov bl, 1   ; blue background

    int 10h ; video interruption

    ret

DELAY:
    .begin:
        mov bp, dx
        .loopBP:
            dec bp

            cmp bp, 0
            jne .loopBP

            dec dx

            cmp dx, 0
            je .end

            jmp .begin
    .end:
        ret

PRINT_DOT:
    mov cx, 3

    .while:
        mov si, dot
        call PRINT_STRING
        mov dx, 15000 ;20000
        call DELAY
        dec cx
        cmp cx, 0
        je .end
        jmp .while
    .end:
        ret

PRINT_NEWLINE:
    mov si, newline
    call PRINT_STRING
    ret

PRINT_STRING:
    .begin:
        mov al, byte[si] ; passing current string character to al, equivalent to lodsb

        cmp al, 0 ; see if string end has been reached

        je .end

        inc si ; incrementing current string pointer

        mov ah, 0xE ; call to print a character on the screen
        mov bh, 0 ; page number
        mov bl, 4 ; character color
        int 10h ; interruption

        jmp PRINT_STRING

    .end:
        ret

LOADKERNEL:
    .reset:
        ; --- resetting floppy disk ---
        ; trying to reset the disk's sector
        ; and its trails and heads
        mov ah, 0
        mov dl, 0
        int 13h

        jc .reset ; try again in case it didnt work
    .load:
        mov ax, 0x7e0 ; 0x7e0 << 1 = 0x7e00
        mov es, ax  ; moving to the ES register
        xor bx, bx  ; resetting the offset (remember: memory is [ES:BX])

        mov ah, 0x02 ; reading disk's sector
        mov al, 310   ; amount of occupied disks
        mov dl, 0   ; floppy drive

        mov ch, 0  ; trail 0;
        mov cl, 3  ; sector 3
        mov dh, 0  ; head 0
        int 13h

        jc .load ; try again in case it didnt work
END:
    jmp 0x7e00

times 510-($-$$) db 0 ;512 bytes
dw 0xaa55             ;assinatura
