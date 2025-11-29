.model small
.stack 100h

                     ;      DATA SEGMENT
 ;**************************************************************
.data
    TitleMessage                db 13,10,' Daily Calorie Calculator',13,10
                                db ' ================================================',13,10,'$'

    MessageEnterWeight          db 13,10,'Enter your weight in kg (40-200): $'
    MessageEnterHeight          db 13,10,'Enter your height in cm (100-250): $'
    MessageEnterAge             db 13,10,'Enter your age (10-100): $'
    MessageEnterGender          db 13,10,'Enter gender (0=Male, 1=Female): $'
    MessageEnterActivityLevel   db 13,10,'Activity level (0=Sedentary, 1=Moderate, 2=Active): $'

    MessageShowBMR              db 13,10,' Your daily calories (basic) : $'
    MessageShowTDEE             db 13,10,'  Your daily calories (total) : $'

    SeparatorLine               db 13,10,'============================================',13,10,'$'
    NewLine                     db 13,10,'$'

    ;****************************   Variables ***********************************
    UserWeight                  dw ?
    UserHeight                  dw ?
    UserAge                     dw ?
    UserGender                  dw ?        ; 0 = Male, 1 = Female
    UserActivityLevel           dw ?        ; 0=Sedentary, 1=Moderate, 2=Active

    BasalMetabolicRate          dw ?
    TotalDailyEnergyExpenditure dw ?

   
    ;     CODE SEGMENT
        ;************************************************************
.code
main proc
    .startup                         ; Simplified directive

    ;******************** Display title ***************
    lea dx, TitleMessage
    call PrintString

    ;********************** Input  data **************************
    lea dx, MessageEnterWeight
    call PrintString
    call ReadNumber
    mov UserWeight, ax

    lea dx, MessageEnterHeight
    call PrintString
    call ReadNumber
    mov UserHeight, ax

    lea dx, MessageEnterAge
    call PrintString
    call ReadNumber
    mov UserAge, ax

    lea dx, MessageEnterGender
    call PrintString
    call ReadNumber
    mov UserGender, ax

    lea dx, MessageEnterActivityLevel
    call PrintString
    call ReadNumber
    mov UserActivityLevel, ax

    ;************************** Calculate BMR  ***************************************
    mov ax, UserWeight
    mov bx, 10
    mul bx                      ; AX = 10 * weight
    mov bx, ax

    mov ax, UserHeight
    mov dx, 25
    mul dx                      ; AX = 25 * height
    shl ax, 2                   ; mul by 4
    shr ax, 4                   ; div by 16
    add bx, ax

    mov ax, UserAge
    mov dx, 5
    mul dx
    sub bx, ax                  ; sub 5 * age

    cmp UserGender, 0
    je MaleBMR
    sub bx, 161                 ; Female
    jmp BMRCalculated
MaleBMR:
    add bx, 5                   ; Male
BMRCalculated:
    mov BasalMetabolicRate, bx

    lea dx, MessageShowBMR
    call PrintString
    mov ax, BasalMetabolicRate
    call PrintNumber
    lea dx, SeparatorLine
    call PrintString

    ;********************** Calculate TDEE based on activity level ************************************
    mov ax, BasalMetabolicRate

    cmp UserActivityLevel, 0
    je SedentaryLevel
    cmp UserActivityLevel, 1
    je ModerateLevel
    ; Active ? mul 1.9
    mov bx, 19
    mul bx
    mov bx, 10
    div bx
    jmp TDEECalculated

SedentaryLevel:                 ; mul 1.2
    mov bx, 12
    mul bx
    mov bx, 10
    div bx
    jmp TDEECalculated

ModerateLevel:                  ; mul 1.55
    mov bx, 155
    mul bx
    mov bx, 100
    div bx

TDEECalculated:
    mov TotalDailyEnergyExpenditure, ax

    lea dx, MessageShowTDEE
    call PrintString
    mov ax, TotalDailyEnergyExpenditure
    call PrintNumber
    lea dx, SeparatorLine
    call PrintString

    .exit                           ; Simplified directive
main endp

 ;                        PROCEDURES
 ;****************************************************************

PrintString proc near
    mov ah, 09h
    int 21h
    ret
PrintString endp

ReadNumber proc near
    push bx
    push cx
    push dx
    xor bx, bx                      ; BX  hold the final number

ReadLoop:
    mov ah, 01h
    int 21h
    cmp al, 13                      ; Enter key
    je ReadingFinished
    cmp al, '0'
    jb ReadLoop
    cmp al, '9'
    ja ReadLoop
    sub al, '0'
    mov ah, 0
    mov dx, bx
    shl bx, 1                       ; BX = BX * 2
    shl dx, 3                       ; DX = old BX * 8
    add bx, dx                      ; BX = BX*10
    add bx, ax
    jmp ReadLoop

ReadingFinished:
    mov ax, bx
    pop dx
    pop cx
    pop bx
    ret
ReadNumber endp

PrintNumber proc near
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    xor cx, cx                      ;  counter

DivideLoop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz DivideLoop

PrintDigitsLoop:
    pop dx
    mov ah, 02h
    int 21h
    loop PrintDigitsLoop

    lea dx, NewLine
    call PrintString

    pop dx
    pop cx
    pop bx
    pop ax
    ret
PrintNumber endp

end main
