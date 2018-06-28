.386
data segment use16
filename 	db 100
			db 0
			db 100 dup(0)
buf db 256 dup(0)
greeting db "Please input filename:",0Dh,0Ah,'$'
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
	lea dx, [greeting]
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
    mov al, 0; 对应_open()的第2个参数, 表示只读方式
	lea dx, [filename+2]
	mov bx, dx
	add bl, filename[1]
	mov [bx], al
    int 21h
	jc fileError
    mov handle, ax
	mov ah, 42h
    mov al, 2; 对应lseek()的第3个参数, ; 表示以EOF为参照点进行移动
    mov bx, handle
    mov cx, 0; \ 对应lseek()的第2个参数
    mov dx, 0; /
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
	jb myLoop_cmp_n
	mov word ptr [bytes_in_buf], 256
	jmp myLoop_cmp_n_endif
myLoop_cmp_n:
	mov bytes_in_buf, cx;
myLoop_cmp_n_endif:
	mov ah, 42h
    mov al, 0; 对应lseek()的第3个参数, ; 表示以偏移0作为参照点进行移动
    mov bx, handle
    mov cx, word ptr foffset[2]; \cx:dx合一起构成
    mov dx, word ptr foffset[0]; /32位值=offset
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
	cmp ax, 4900h;PgUp
	je myLoop_PgUp
	cmp ax, 5100h;PgDn
	je myLoop_PgDn;
	cmp ax, 4700h;Home
	je myLoop_Home
	cmp ax, 4f00h;End
	je myLoop_End
	cmp ax, 011Bh;Esc
	je myLoop_finish
myLoop_PgUp:
	sub ecx,256
	jns myLoop_endswitch
	jmp myLoop_Home
myLoop_PgDn:
	mov edx, ecx 
	add edx, 257
	cmp edx, file_size
	ja myLoop_endswitch
	add ecx, 256
	jmp myLoop_endswitch
myLoop_Home:
	xor ecx, ecx
	jmp myLoop_endswitch
myLoop_End:
	mov ecx, file_size
	and cl, 0FF00h;offset = file_size - file_size % 256
	cmp ecx, file_size
	jne myLoop_endswitch
	sub ecx, 256
myLoop_endswitch:
	mov foffset, ecx
	jmp myLoop
myLoop_finish:
	;close file
	mov ah, 3Eh
    mov bx, handle
    int 21h
	ret
;<&buf[0]>:di, <offset>:global, <bytes_in_buf>:global
show_this_page:
	call clear_this_page
	mov cx, bytes_in_buf
	add cx, 15
	shr cx, 4;rows = (bytes_in_buf + 15) / 16
	lea si, [buf]
	mov edx, foffset
	xor eax, eax;ax = i
	mov bx, cx
	dec bx; bx = rows-1
show_this_page_again:
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
	;<row>:ax, <offset>:edx, <bytes_on_row>:cx, <&buf[?]>:si
	call show_this_row
	add si, 16
	add edx,16
	inc ax
	pop cx
	loop show_this_page_again
	ret
clear_this_page:
	push di
	push ax
	push es
	push cx
	mov ax, 0B800h
	mov es, ax
	mov di, 0000h
	mov cx, 500h;16*80
	cld
	mov ax, 0020h
	rep stosw
	pop cx
	pop es
	pop ax
	pop di
	ret
;di:result add ax:source(modified)
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
;<char s[]>di:result add, <offset>: edx
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
;<row>:ax, <offset>:edx, <bytes_on_row>:cx, <&buf[?]>:si
show_this_row:
	push bx
	push edx
	push bp
	push ax
	push cx
	push si
	mov bp, sp
	mov ax, ds
	mov es, ax
	lea si, [pattern]
	lea di, [s] ;di = &s[0]
	mov cx, 75
	rep movsb
	lea di, [s] ;di = &s[0]
	call long2hex;edx already=offset
	mov cx, [bp+2]
	add di, 10
	mov si, [bp]
row_xx:
	mov al, [si]
	call char2hex
	inc si
	add di, 3
	loop row_xx
	mov si, [bp];restore es already=ds
	mov cx, [bp+2]
	lea di, [s]
	add di, 59
	rep movsb
	;<cx = strlen(s)-1>: lea di, [s];mov cx, 0FFFFh;mov al, 0;cld;repne scasb;inc cx;not cx;dec cx;
	mov cx, 74
	xor eax, eax
	mov ax, [bp+4]
	mov bx, 160
	mul bx
	mov di, ax
	mov ax, 0B800h
	mov es, ax
	lea bx, [s];bx = &s[0]
	xor dx,dx; <i>: dx
row_out:
	mov al, [bx]
	mov es:[di], al
	inc di
	cmp dx, 58;dx<i> < 59
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
row_end:
	pop si
	pop cx
	pop ax
	pop bp
	pop edx
	pop bx
	ret
code ends
end main