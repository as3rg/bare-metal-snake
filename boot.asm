use16
org 0x7C00

    ; load program
    mov ah, 0x02
    mov al, 1
    mov dl, 0x80
    mov ch, 0
    mov dh, 0 
    mov cl, 2
    xor bx, bx
    mov es, bx
    mov bx, stage2_addr
    int 0x13

    jmp stage2_addr

    ; Magic bytes.    
    times ((0x200 - 2) - ($ - $$)) db 0x00
    dw 0xAA55

stage2_addr     equ 0x00007E00
clock_addr      equ 0x0000046C
stack_addr      equ 0x00007C00
dir_addr        equ 0x00000500
dir_up          equ 0
dir_right       equ 1
dir_down        equ 2
dir_left        equ 3
head_addr       equ 0x00000502
tail_addr       equ 0x00000504
bodyx_addr      equ 0x00000510
bodyy_addr      equ 0x00000BC2

food_cntr_addr  equ 0x00000506
food_period     equ 45

arenaw          equ 45
arenah          equ 45
maxlen          equ 2025
pixel_size      equ 4
border          equ 4
startlen        equ 3

food_color      equ 0x9
bord_color      equ 0xF
snake_color     equ 0x4

start:
    mov sp, stack_addr

    ; set mode 
    mov ax, 0x0013
    int 0x10

    ; todo fill zeros
    mov word [head_addr], startlen
    mov word [tail_addr], 1
    mov byte [dir_addr], -1
    mov cx, 0
    mov dx, 0
    mov byte [food_cntr_addr], 1
   
    call draw_border
    jmp repeat

; cx = x, dx = y on the field
; al = color
draw_pixel:
    push cx
    push dx

    mov ch, 0
    mov dh, 0

    mov ah, 0x0C
    lea cx, [border + pixel_size * ecx]
    lea dx, [border + pixel_size * edx]
    int 0x10
    inc cx
    int 0x10
    inc dx
    int 0x10
    dec cx
    int 0x10

    pop dx
    pop cx
    ret

; cx = x, dx = y on the field
; color of a pixel returned in al
get_pixel:
    push cx
    push dx

    mov ch, 0
    mov dh, 0

    mov ah, 0x0D
    lea cx, [border + pixel_size * ecx]
    lea dx, [border + pixel_size * edx]
    int 0x10

    pop dx
    pop cx
    ret

handle_press:
    mov ax, 0x0100
    int 0x16

    jz .ret

    mov ax, 0x0000
    int 0x16

    cmp ah, 0x48
    je .up
    
    cmp ah, 0x50
    je .down

    cmp ah, 0x4B
    je .left

    cmp ah, 0x4D
    je .right
    
    ret

.up:
    cmp byte [dir_addr], dir_down
    je .ret
    mov byte [dir_addr], dir_up
    ret
.down:
    cmp byte [dir_addr], dir_up
    je .ret
    mov byte [dir_addr], dir_down
    ret 
.left:
    cmp byte [dir_addr], dir_right
    je .ret
    mov byte [dir_addr], dir_left
    ret
.right:
    cmp byte [dir_addr], dir_left
    je .ret
    mov byte [dir_addr], dir_right
.ret:
    ret

draw_border:
    push cx
    push dx

    mov ah, 0x0C
    mov al, bord_color
    mov cx, 2
    mov dx, 2
    lea bp, [arenah * pixel_size + border]

.draw1:
    int 0x10
    inc dx
    cmp dx, bp
    jl .draw1

    dec dx
    lea bp, [arenaw * pixel_size + border]
.draw2:
    int 0x10
    inc cx
    cmp cx, bp
    jl .draw2
    
    dec cx
.draw3:
    int 0x10
    dec dx
    cmp dx, 1
    jg .draw3
    
    inc dx
.draw4:
    int 0x10
    dec cx
    cmp cx, 1
    jg .draw4

    pop dx
    pop cx
    ret

move:
    mov ah, byte [dir_addr]

    cmp ah, dir_up
    je .up
    
    cmp ah, dir_down
    je .down

    cmp ah, dir_left
    je .left

    cmp ah, dir_right
    je .right

    ret
.up:
    dec dl
    jge .redraw
    add dl, arenah 
    jmp .redraw
.down:
    inc dl
    cmp dl, arenah
    jl .redraw
    sub dl, arenah
    jmp .redraw
.left:
    dec cl
    jge .redraw
    add cl, arenaw
    jmp .redraw
.right:
    inc cl
    cmp cl, arenaw
    jl .redraw
    sub cl, arenaw   

.redraw:
    push cx
    push dx

    mov bp, word [head_addr]
    inc bp
    cmp bp, maxlen
    jl .skip
    sub bp, maxlen
.skip:
    mov word [head_addr], bp
    mov byte [bp + bodyx_addr], cl
    mov byte [bp + bodyy_addr], dl
    call get_pixel
    cmp al, snake_color
    je start
    cmp al, food_color
    je .plus_len
    mov al, snake_color
    call draw_pixel

    mov bp, word [tail_addr]
    mov cl, byte [bp + bodyx_addr]
    mov dl, byte [bp + bodyy_addr]
    mov al, 0x00
    call draw_pixel

    inc bp
    cmp bp, maxlen
    jl .skip2
    sub bp, maxlen
.skip2:
    mov word [tail_addr], bp
    jmp .ret

.plus_len:
    mov al, snake_color
    call draw_pixel
.ret:
    pop dx
    pop cx
    ret

repeat:
    call handle_press
    call move
    call wait_
    call make_food
    jmp repeat

wait_:
    push cx
    push dx
    mov ax, 0x8600
    mov cx, 0x0001
    mov dx, 0x86A0
    int 0x15
    pop dx
    pop cx
    ret

make_food:
    push cx
    push dx

    dec byte [food_cntr_addr]
    jnz .ret
    mov byte [food_cntr_addr], food_period

    mov ax, [clock_addr]
    mov dx, 0

    mov ebp, arenaw
    div ebp
    mov cl, dl

    mov ebp, arenah
    div ebp

    call get_pixel
    cmp al, snake_color
    je .ret
    mov al, food_color
    call draw_pixel

.ret:
    pop dx
    pop cx
    ret
