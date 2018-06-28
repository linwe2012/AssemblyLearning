.386
data segment use16
filename 	db 100
			db 0
			db 100 dup(0)
buf db 256 dup(0)
hi db "Please input filename:",0Dh,0Ah,'$'
errorFile db "Cannot open file!",0Dh, 0Ah, '$'
handle dw 0
file_size dd 0
foffset dd 0
bytes_in_buf dw 0
t db "0123456789ABCDEF"
pattern db "00000000:            |           |           |                             "
s db 75 dup(0), 0
data ends
code segment use16
	assume cs:code,ds:data
main:
	mov ax, data
	mov ds, ax
	lea dx, [hi]
	mov ah, 9
	int 21h
	lea dx, [filename]
	mov ah, 0Ah
	int 21h
	mov ah, 2
	mov dl, 0Dh
	int 21h
	mov dl, 0Ah
	int 21h
	mov ah, 3Dh
    mov al, 0
	lea dx, [filename+2]
	mov bx, dx
	add bl, filename[1]
	mov [bx], al
    int 21h
	jc fileError
    mov handle, ax
	mov ah, 42h
    mov al, 2
    mov bx, handle
    mov cx, 0
    mov dx, 0
    int 21h
    mov word ptr file_size[2], dx
    mov word ptr file_size[0], ax
	call myLoop
	jmp exit
fileError:
	lea dx, [errorFile]
	mov ah, 9
	int 21h
exit:
	mov ah, 4Ch
	int 21h
myLoop:
	mov ecx, file_size
	sub ecx, foffset
	cmp ecx, 256
	jb ml_cmp_n
	mov word ptr [bytes_in_buf], 256
	jmp ml_cmp_n_endif
ml_cmp_n:
	mov bytes_in_buf, cx;
ml_cmp_n_endif:
	mov ah, 42h
    mov al, 0
    mov bx, handle
    mov cx, word ptr foffset[2]
    mov dx, word ptr foffset[0]
    int 21h
	mov ah, 3Fh
    mov bx, handle
    mov cx, bytes_in_buf
    mov dx, data
    mov ds, dx
    lea dx, [buf]
    int 21h
	lea di, [buf]
	call show_this_page
	mov ah, 0
    int 16h
	mov ecx, foffset;
	cmp ax, 4900h
	je PgUp
	cmp ax, 5100h
	je PgDn;
	cmp ax, 4700h
	je Home
	cmp ax, 4f00h
	je mEnd
	cmp ax, 011Bh
	je myLoop_finish
PgUp:
	sub ecx,256
	jns myLoop_endswitch
	jmp Home
PgDn:
	mov edx, ecx 
	add edx, 257
	cmp edx, file_size
	ja myLoop_endswitch
	add ecx, 256
	jmp myLoop_endswitch
Home:
	xor ecx, ecx
	jmp myLoop_endswitch
mEnd:
	mov ecx, file_size
	and cl, 0FF00h
	cmp ecx, file_size
	jne myLoop_endswitch
	sub ecx, 256
myLoop_endswitch:
	mov foffset, ecx
	jmp myLoop
myLoop_finish:
	mov ah, 3Eh
    mov bx, handle
    int 21h
	ret
show_this_page:
	call clear_this_page
	mov cx, bytes_in_buf
	add cx, 15
	shr cx, 4
	lea si, [buf]
	mov edx, foffset
	xor eax, eax
	mov bx, cx
	dec bx
stp_again:
	push cx
	cmp ax, bx
	je stpa_if
	mov ecx, 16
	jmp stpa_endif
stpa_if:
	shl eax, 4
	mov cx, bytes_in_buf
	sub cx, ax
	shr eax, 4
stpa_endif:
	call show_this_row
	add si, 16
	add edx,16
	inc ax
	pop cx
	loop stp_again
	ret
clear_this_page:
	mov ax, 0B800h
	mov es, ax
	mov di, 0000h
	mov cx, 500h
	cld
	mov ax, 0020h
	rep stosw
	ret
char2hex:
	push bx
	lea bx, [t]
	ror ax, 4
	and al, 0Fh
	xlat
	mov [di], al
	rol ax, 4
	and al, 0Fh
	xlat
	mov [di+1], al
	pop bx
	ret
long2hex:
	push cx
	push di
	mov cx,4
long2hex_again:
	rol edx, 8
	mov eax, edx
	call char2hex
	add di, 2
	loop long2hex_again
	pop di
	pop cx
	ret
show_this_row:
	push bx
	push edx
	push ax
	push cx
	push si
	mov bp, sp
	mov ax, ds
	mov es, ax
	lea si, [pattern]
	lea di, [s]
	mov cx, 75
	rep movsb
	lea di, [s]
	call long2hex
	mov cx, [bp+2]
	add di, 10
	mov si, [bp]
row_xx:
	mov al, [si]
	call char2hex
	inc si
	add di, 3
	loop row_xx
	mov si, [bp]
	mov cx, [bp+2]
	lea di, [s]
	add di, 59
	rep movsb
	mov cx, 74
	xor eax, eax
	mov ax, [bp+4]
	mov bx, 160
	mul bx
	mov di, ax
	mov ax, 0B800h
	mov es, ax
	lea bx, [s]
	xor dx,dx
row_out:
	mov al, [bx]
	mov es:[di], al
	inc di
	cmp dx, 58
	ja row_out_else
	cmp al, '|'
	jne row_out_else
	mov al, 0Fh
	jmp row_out_endif
row_out_else:
	mov al, 07h
row_out_endif:
	mov es:[di], al
	inc dx
	inc di
	inc bx
	loop row_out
	pop si
	pop cx
	pop ax
	pop edx
	pop bx
	ret
code ends
end main