.model tiny
.code
org 100h

PUSH_ALL_REGS	macro

	push    ss es ds sp bp di si dx cx bx ax

endm

POP_ALL_REGS	macro

	pop     ax bx cx dx si di bp sp ds es ss

endm

INT08H      equ 4*08h  ; timer interrupt number
INT09H      equ 4*09h  ; keyboard interrupt number

START_KEY   equ 2ah    ; scancode 'Shift(L)'
STOP_KEY    equ 36h    ; scancode 'Shift(R)'

RED         equ 04h    ; red color code

TWIDTH      equ 07h    ; reg table width 
THEIGTH     equ 10h    ; reg table heigth

SCREENWIDTH equ 0050h  ; width of screen in DOS
SCRENHEIGTH equ 0019h  ; heigth of screen in DOS

VIDEOSEG    equ 0b800h ; addr of video segment

main:

    call ChangeInt09h
    call ChangeInt08h

    mov dx, offset EOP
    shr dx, 4
    inc dx

mov ah, 31h
int 21h

;==========ChangeInt09h===============
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
ChangeInt09h proc

    mov ax, 3509h
    int 21h

    mov OldOffset09h, bx
    mov OldSeg09h, es

    xor ax, ax
    mov es, ax

    mov bx, INT09H

	cli
	    push cs
	    pop ax

	    mov es:[bx], offset NewInt09h

	    mov es:[bx+2], ax
	sti

ret
endp

;==========ChangeInt08h=================
;Descr: Change timer interruption to my func that update RegTable
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
ChangeInt08h proc

    mov ax, 3508h
    int 21h

    mov OldOffset08h, bx
    mov OldSeg08h, es

    xor ax, ax
    mov es, ax

    mov bx, INT08H

	cli
	    push cs
	    pop ax

	    mov es:[bx], offset NewInt08h

	    mov es:[bx+2], ax
	sti

ret
endp

;==========NewInt09h====================
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
NewInt09h   proc

        push ax

        in al, 60h
        cmp al, START_KEY
        jne dont_start_res           ;; jne dont_...

        mov can_draw, 1

        jmp back_keyboard_control

    dont_start_res:

        cmp al, STOP_KEY
        jne dont_stop_res

        mov can_draw, 0

    back_keyboard_control:

        in al, 61h
        or al, 80h
        out 61h, al
        and al, not 80h	
        out 61h, al
        mov al, 20h
        out 20h, al

        pop ax

iret

    dont_stop_res:

        pop ax

        db 0EAh
        OldOffset09h	dw 0
        OldSeg09h       dw 0

endp


;==========NewInt08h====================
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
NewInt08h   proc

		cmp can_draw, 1
		jne dont_draw_regs

		PUSH_ALL_REGS								; push all registers

		Call DrawRegs

		POP_ALL_REGS								; pop all registers

	dont_draw_regs:

    db 0EAh
    OldOffset08h	dw 0
    OldSeg08h       dw 0

endp

;==========DrawRegs==================== draw values of registers
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
DrawRegs   proc

    mov ax, VIDEOSEG
    mov es, ax

    xor ax, ax
    lea si, clearing

    mov di, 500h
    lodsb
    mov cx, 100h ;SCREENWIDTH * SCRENHEIGTH = whole screen ;0fa0h
    rep stosw

    xor di, di
    mov ah, RED
    lea si, register_names

    mov cx, 0ch ; 12d registers

    push sp
    pop bp

    Draw_Regs:

        push cx

        mov cx, 3

        Draw_Reg_Name:

            lodsb
            stosw

        loop Draw_Reg_Name

        add bp, 2

        mov dx, [bp]

        call DrawValues

        add di, (SCREENWIDTH - 7) * 2

        pop cx
    
    loop Draw_Regs


ret
endp

;==========DrawValues==================== draw values of registers
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
DrawValues   proc

    push si
    
    mov bx, VIDEOSEG
    mov es, bx

    xor bx, bx

        lea si, Hex_Nums

        mov bl, dl
        and bl, 0fh

        add si, bx

        lodsb
        stosw


        lea si, Hex_Nums

        mov bl, dl
        shr bl, 4
        and bl, 0fh

        add si, bx

        lodsb
        stosw


        lea si, Hex_Nums

        mov bl, dh
        and bl, 0fh

        add si, bx

        lodsb
        stosw


        lea si, Hex_Nums

        mov bl, dh
        shr bl, 4
        and bl, 0fh

        add si, bx

        lodsb
        stosw

    pop si

ret
endp

.data

clearing        db ' ' ; надо будет убрать вместе с очисткой экрана

Hex_Nums        db '0123456789ABCDEF'
register_names  db 'ax=bx=cx=dx=si=di=bp=sp=ds=es=ss=cs='

reg_value   db 0
draw_mask   dw 0fh

can_draw    db 0

EOP:
end main