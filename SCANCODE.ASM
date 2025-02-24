.model tiny
.code
org 100h
Start:
    mov bx, 0b800h
    mov es, bx
    mov bx, 5*80*2 + 40*2
    mov ah, 4eh

    Next:
        in al, 60h
        mov es:[bx], ax
        cmp al, 1
        jne Next

	mov ax, 4c00h
	int 21h

.data

end Start