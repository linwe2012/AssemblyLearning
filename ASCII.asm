data segment
col db 0
row db 0
num db 0
count db 0FFh
position dw 0000h
hex db 4 dup(0)
data ends

code segment
assume ds:data, cs:code
main:
	;clear screen
	mov AX,0003h
	int 10h
	mov ax, data
    mov ds, ax
	mov ax, 0B800h
	mov es, ax
	mov cx, 0100h
	push cx
again:
	mov al, num;debug
	mov ah, 0Ch ; Background:black, foreground:red
	mov di, position
	mov word ptr es:[di], ax;
	;change to hex
    mov al, num
	mov ah, 00h
    mov cx, 4
    mov di, 0; 
transform_to_hex:
    push cx
    mov cl, 4 ; 
    rol ax, cl; 
    push ax
    and ax, 0000000000001111B; 000Fh
    cmp ax, 10
    jb is_digit
is_alpha:
    sub al, 10
    add al, 'A'
    jmp finish_4bits
is_digit:
    add al, '0'
finish_4bits:
    mov hex[di], al
    pop ax
    pop cx
    add di, 1
    sub cx, 1
    jnz transform_to_hex
    mov ah, 9
    mov dx, offset hex
	;print hex
	mov di, position
	mov ah, 0Ah
	add di, 2
	mov al, hex[2]
	mov word ptr es:[di], ax ;
	add di, 2
	mov al, hex[3]
	mov word ptr es:[di], ax ;
	;add number
	add position, 160
	add row, 1
	cmp row, 25
	jne continue
	;reach the last row
	mov row, 0
	add position, 14
	sub position, 4000
continue:
	add num, 1
	;sub count, 1
	pop cx
	sub cx, 1
	jz theend
	push cx
	jmp again
theend:
   mov ah, 1
   int 21h; 键盘输入，起到等待敲键的作用
   mov ah, 4Ch
   int 21h
code ends
end main