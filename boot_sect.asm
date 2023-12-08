use16
org 0x7C00

    ; load program
    mov ah, 0x02        ; load sector
    mov al, 1           ; sectors count
    mov dl, 0x80        ; drive (0x80 = first hard drive)
    mov ch, 0           ; cylinder
    mov dh, 0           ; head 
    mov cl, 2           ; sector
    xor bx, bx
    mov es, bx
    mov bx, startbuf       ; buffer address
    int 0x13

    jmp start

    ; Magic bytes.    
    times ((0x200 - 2) - ($ - $$)) db 0x00
    dw 0xAA55

startbuf    equ 0x00007E00
; dir_addr    equ 0x00000500
; dir_up      equ 0
; dir_right   equ 1
; dir_down    equ 2
; dir_left    equ 3
headx       equ 0x00000502
heady       equ 0x00000504
arenaw      equ 50
arenah      equ 50
border      equ 4

draw_pixel:
    push cx
    push dx

    mov ah, 0x0C
    lea cx, [border + 4 * ecx]
    lea dx, [border + 4 * edx]
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

start:
    ; set mode 
    mov ax, 0x0013
    int 0x10

    mov word [headx], 0x0
    mov word [heady], 0x0

repeat:
    mov ah, 0
    int 0x16

    mov cx, word [headx]
    mov dx, word [heady]

    cmp ah, 0x48
    je _up
    
    cmp ah, 0x50
    je _down

    cmp ah, 0x4B
    je _left

    cmp ah, 0x4D
    je _right

    jmp repeat
_up:
    dec word [heady]
    jge _move
    add word [heady], arenah 
    jmp _move
_down:
    inc word [heady]
    cmp word [heady], arenah
    jl _move
    sub word [heady], arenah
    jmp _move
_left:
    dec word [headx]
    jge _move
    add word [headx], arenaw
    jmp _move
_right:
    inc word [headx]
    cmp word [headx], arenaw
    jl _move
    sub word [headx], arenaw   

_move:
    mov al, 0x03
    call draw_pixel

    mov al, 0x04
    mov cx, word [headx]
    mov dx, word [heady]
    call draw_pixel

    jmp repeat



    ; Print 'a'.
    ; mov ax, 0x0C02
    ; mov cx, 0x01
    ; mov dx, 0x01
    ; int 0x10
    ;
    jmp $
    ; cli
    ; hlt

    ; Pad image to multiple of 512 bytes.
    ; times ((0x400) - ($ - $$)) db 0x00
