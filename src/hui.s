mov [0] 0
inc [0]
mov ax [0]
mul ax 2
mov R0 ax
mov ax [0]
sub ax R0
mov R0 ax
mov ax [0]
mul ax 5
mov R1 ax
mov ax R0
add ax R1
mov R0 ax
mov ax,R0
mov [4] ax
mov [9] -3.1
mov [17] 2
mov [21] 6.9
mov ax 0
mov bx 17
compare ax bx
JG Label0
jum Label1
Label0: mov ax 0
compare ax 1
JL Label2
jum Label1
Label1: mov ax 17
compare ax 4
JG Label2
jum Label7
Label2: mov ax,[17]
mov [0] ax
mov ax 0
compare ax 3
JL Label3
jum Label4
Label3: mov [0] 3
jum Label5
Label4: mov [0] 5
Label5: mov ax 0
compare ax 4
JL Label6
jum Label7
Label6: inc [0]
jum Label5
Label7: inc [0]
mov ax 0
mov bx 17
compare ax bx
JG Label9
jum Label8
Label8: mov ax 17
compare ax 3
JG Label9
jum Label10
Label9: inc [0]
inc [17]
jum Label13
Label10: dec [0]
dec [17]
Label11: mov ax 0
compare ax 10
JL Label12
jum Label13
Label12: inc [0]
jum Label11
Label13: mov [25] 0
Label14: mov ax 25
mov bx 0
compare ax bx
JL Label15
jum Label16
Label15: inc [25]
jum Label14
Label16: mov ax,[17]
mov [0] ax
Label17: mov ax,[25]
mov [17] ax
mov ax 0
mov bx 25
compare ax bx
JL Label18
jum Label19
Label18: jum Label17
Label19: end
