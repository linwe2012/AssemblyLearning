.386
data segment use16
	buffera db 6
		    db ?
		    db 6 dup(?)
	bufferb db 6
		    db ?
		    db 6 dup(?) 
	numa dw 0
	numb dw 0
	numres dd 0
	resultdec db 14 dup(0), 0Dh, 0Ah, '$'
	resulthex db 11 dup(0), 0Dh, 0Ah, '$'
	resultbin db 50 dup(0), 0Dh, 0Ah, '$'
	t db "0123456789ABCDEF"
data ends
code segment use16
	assume cs:code,ds:data
main:
	mov ax, data
	mov ds, ax
	mov dx, offset buffera
	call input_with_return
	mov dx, offset bufferb
	call input_with_return
	mov bx, offset numa
	mov ax, offset buffera
	mov si, ax
	call toNumber
	mov bx, offset numb
	mov ax, offset bufferb
	mov si, ax
	call toNumber
	mov bx, offset buffera;
	call output_buffer;
	mov ah, 2
	mov dl,'*'
	int 21h
	mov bx, offset bufferb;
	call output_buffer;
	mov ah, 2
	mov dl,'='
	int 21h
	mov ah, 2
	mov dl, 0Dh
	int 21h;\r
	mov ah,2
	mov dl,0Ah
	int 21h;\n
;^^^^^first line ^^^^^^^^^^^
;-----mutiple----------------
	xor eax, eax
	xor ebx, ebx
	mov ax, numa
	mov bx, numb
	mul ebx
	mov numres, eax
;------dec output----------
	mov ax, offset resultdec
	mov si, ax
	mov eax, numres
	call toString_dec;si:result address, eax:source
	mov dx, offset resultdec
	call output
;------hex output-----------
	xor eax,eax
	mov eax, numres
	mov di, offset resulthex
	call toString_hex
	mov dx, offset resulthex
	call output
;----------------------------
	call toString_binary;eax: source, si:result address
	mov eax, numres;
	mov si, offset resultbin
	call toString_hex
	mov dx, offset resultbin
	call output
done:
	mov ah, 4Ch
	int 21h
input_with_return:
	push ax
	mov ah, 0Ah
	int 21h
	mov ah, 2
	mov dl, 0Dh
	int 21h;\r
	mov ah,2
	mov dl,0Ah
	int 21h;\n
	pop ax
	ret
;before call: dx:offset
output:
	push ax
	mov ah, 9
	int 21h
	pop ax
	ret
;bx:buffer
output_buffer:
 push cx
 push eax
 inc bx
 xor cx, cx
 mov cl, [bx]
 jcxz output_buffer_done
output_buffer_again:
 inc bx
 mov ah,2
 mov dl,[bx]
 int 21h
 loop output_buffer_again
output_buffer_done:
 pop eax
 pop cx
 ret
;bx result address, si:source, bx,si subject to change
toNumber:
	push eax
	push dx
	push cx
	xor cx,cx
	mov cl, [si+1]
	inc si
	inc si
	xor eax, eax
toNumber_again:
	mov dx, 10
	mul dx;dx:ax
	xor dx, dx
	mov dl, [si]
	sub dl, '0'
	add ax, dx
	inc si;
	sub cx,1
	jnz toNumber_again
	mov [bx], ax;
	pop cx
	pop dx
	pop eax
	ret
;----------------------------------------
;si:result address, eax:source
toString_dec:
	push eax
	push ecx
	push ebx
	xor cx, cx
    mov bx, offset t;
toString_dec_next:
	push ebx
	mov ebx, 10
    div ebx;edx:eax / 除数 = eax .. edx
	pop ebx;
	mov dh, al;save al
	mov al, dl;remainder
	xlat
	push ax
	inc cx
	mov al, dh;restore eax
	mov edx, 0
	cmp eax, edx
	jne toString_dec_next
	mov al, 0Dh
	mov [si], al
	mov al, 0Ah
	inc si
	mov [si], al
	inc si
	mov al, '$'
	mov [si], al
	sub si, 2
toString_dec_again:
	dec cx
	pop ax;
	mov [si], al
	inc si
	jcxz toString_dec_done
	jmp toString_dec_again
toString_dec_done:
	pop ebx
	pop ecx
	pop eax
    ret
;---------------------------auto add 'h'
toString_hex:
   push bx
   push di
   push eax
   push ecx
   mov bx, offset t;
   mov ecx, 8
   push eax
toString_hex_clearzero:
	pop eax
	rol eax, 4;
	push eax
	and eax, 0Fh
	dec ecx
	jcxz toString_hex_clearzero_cleanup
	cmp eax, 0
	je toString_hex_clearzero
toString_hex_clearzero_cleanup:
	inc ecx
	pop eax
	ror eax, 4
toString_hex_next:
   rol eax, 4
   push eax
   and eax, 0Fh
   xlat; AL=ds:[bx+AL]
   mov [di], al
   inc di
   pop eax;               
   sub ecx, 1;            
   jnz toString_hex_next;--------
   mov ah, 'h'
   mov [di], ah
   inc di
   mov ah, 0Dh
   mov [di], ah
   inc di
   mov ah, 0Ah
   mov [di], ah
   inc di
   mov ah, '$'
   mov [di], ah
   pop ecx
   pop eax
   pop di
   pop bx
   ret
;eax: source, si:result address
toString_binary:
	push cx;
	push dx
	mov cx, 32
	mov dx, 4
	mov bx, offset t
toString_binary_again:
	rol eax, 1;
	push eax
	and al, 1
	xlat
	mov [si], al
	push dx
	mov ah,2
    mov dl,al
    int 21h
	pop dx
	pop eax
	inc si
	sub cx, 1;
	jz toString_binary_done
	sub dx, 1;
	jnz toString_binary_again
	mov dl, ' '
	mov [si], dl
	push eax
	mov ah,2
    int 21h
	pop eax
	inc si
	mov dx, 4
	jmp toString_binary_again
toString_binary_done:
	mov ah, 2
	mov dl, 'B'
	int 21h
	mov ah, 'B'
    mov [si], ah
    inc si
    mov ah, 0Dh
    mov [si], ah
    inc si
    mov ah, 0Ah
    mov [si], ah
    inc si
    mov ah, '$'
    mov [si], ah
	pop dx
	pop cx
	ret
code ends

end main
	
	
	