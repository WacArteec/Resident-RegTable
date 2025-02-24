.model tiny
.code
org 100h
Start:
    xor ax, ax
	mov es, ax

	mov bx, 09h*4
	mov ax, es:[bx]
	mov Old09Seg, ax

	cli
	mov es:[bx], offset New09
	push cs
	pop ax
	mov es:[bx+2], ax
	sti

	mov ax, 3100h
	mov dx, offset EOP
	shr dx, 4
	inc dx
	int 21h

Exit:
	mov ax, 4c00h
	int 21h

New09	proc
	push ax di es

	mov ax, 0b800h
	mov es, ax
	mov ah, 4eh
	mov di, 5*80*2 + 40*2
	cld

	in al, 60h
	stosw
	jmp ChainOldISR

	in al, 61h
	mov ah, al
	or al, 80h
	out 61h, al
	mov al, ah
	out 61h, al
	mov al, 20h
	out 20h, al
	mov cs:Active, 1

	pop es di ax

iret
endp

ChainOldISR:
	pop es di ax
	db 0eah

.data
Old09Fs		dw 0
Old09Seg 	dw 0
Active		db 0

EOP:
end Start