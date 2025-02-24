.model tiny
.code
org 100h

INT08H      equ 4*08h ; timer interrupt number
INT09H      equ 4*09h ; keyboard interrupt number
START_KEY   equ 2ah ; scancode '[ {'
STOP_KEY    equ 36h ; scancode '] }'
RED         equ 04h ; red color code
TWIDTH      equ 07h ; reg table width 
THEIGTH     equ 10h ; reg table heigth
SCREENWIDTH equ 00a0h ; width of screen in DOS
SCRENHEIGTH equ 0019h ;
VIDEOSEG    equ 0b800h ; addr of video segment

Start:

    call ChangeInt09h
    ;call ChangeInt08h

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
	    mov es:[bx], offset NewInt09h

	    push cs
	    pop ax

	    mov es:[bx+2], ax
	sti

ret
endp

;==========ChangeInt08h================= change timer interruption to my func that update RegTable
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
	    mov es:[bx], offset NewInt08h

	    push cs
	    pop ax

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
    je start_resident

    dont_start_res:

	in al, 61h
	mov ah, al
	or al, 80h
	out 61h, al
	and al, not 80h	
	out 61h, al
	mov al, 20h
	out 20h, al

    pop ax

iret

    start_resident:
        call DrawRegTable
    jmp dont_start_res

endp


;==========NewInt08h====================
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
NewInt08h   proc

ret
endp

;==========DrawRegTable==================== draw a table with registers (RegTable)
;Entry:
;Exit:
;ASsumes:
;Destroy:
;========================================
DrawRegTable   proc

    mov ax, VIDEOSEG
    mov es, ax

    xor ax, ax
    lea si, clearing

    xor di, di
    lodsb
    mov cx, 20h ;SCREENWIDTH * SCRENHEIGTH ;0fa0h
    rep stosw

ret
endp

.data

clearing    db ' '

OldOffset08h	dw 0
OldSeg08h       dw 0
OldOffset09h	dw 0
OldSeg09h       dw 0

EOP:
end Start