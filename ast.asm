%define STRING_SIZE 300
%define OPERATOR 48
%define MINUS 45

section .data
    delim db " \n", 0
    string times STRING_SIZE dd 0     ; string-ul initial
    parsed dd 0                       ; cuvant parsat pana la ' '

section .bss
    root resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern malloc
extern strtok
extern strdup
extern strlen

global create_tree
global iocla_atoi
global alloc_struct
global create_subtree

iocla_atoi:
    push    ebp
    mov     ebp, esp

    push ebx
    mov ecx, [ebp + 8]           ; token
    xor eax, eax                 ; in eax voi avea numarul de returnat
    ; TODO


    xor edx, edx
    mov ebx, 1
    mov dl, [ecx]
    cmp dl, MINUS                ; daca e numarul negativ
    je  add_sign

costruct:
    xor edx, edx
    mov dl, [ecx]                ; verific fiecare caracter din token

    cmp dl, ' '                  ; am ajuns la un '\0' sau ' '
    jbe end

    imul eax, 10
    lea eax, [eax + edx - '0']   ; eax = eax * 10 + [ecx] - '0'

    inc ecx
    jmp costruct

add_sign:
    mov ebx, -1                  ; retin ca numarul e negativ
    inc ecx                      ; sar peste primul caracter
    jmp costruct

end:
    imul eax, ebx                ; ii adaug semnul

    pop ebx
    leave
    ret


alloc_struct:                    ; functia aloca o structura Node
    enter 0, 0
    push edi

    xor eax, eax

    mov ebx, [ebp + 8]

    push 12
    call malloc
    add esp, 4

    xor edi, edi
    mov edi, eax                 ; salvez pointerul structurii in edi

    push ebx                     ; aloc spatiu pentru data
    call strdup
    add esp, 4

    mov dword [edi], eax   

    mov eax, edi                 ; returnez structura

    pop edi
    leave
    ret

verif_is_operator:
    mov edx, ebx
    inc edx
    cmp byte [edx], 0x0          ; intr-adevar am 'operator\0'
    je is_operator
    jmp not_operator

create_tree:
    ; TODO
    enter 0, 0
    xor eax, eax
    push ebx

    mov ecx, dword [ebp + 8]     ; pointerul la string memorat in ecx
    push ecx
    push dword [root]            ; memorez si root-ul
    call create_subtree          ; apelez functia recursiva cu root si string-ul
                                 ; initial
    add esp, 8
    jmp return


create_subtree:
    enter 0, 0
    xor eax, eax
    xor edi, edi

    mov ecx, dword [ebp + 8]     ; root-ul
    mov edi, dword [ebp + 12]    ; string-ul initial

    mov dword [root], ecx        ; memorez si in memorie root-ul
    

parse_input:
    push delim                   ; apelez strtok
    push edi
    call strtok                  ; cuvantul parsat se afla in eax
    add esp, 8
    
    mov dword [parsed], eax      ; memorez cuvantul parsat
    push eax
    call alloc_struct            ; aloc memorie pentru noul Node ce va contine
                                 ; in data cuvantul abia parsat
    add esp, 4
    mov [root], eax              ; memorez noul root

    mov ecx, dword [parsed]
    push ecx
    call strlen                  ; calculez lungimea cuvantului parsat
    add esp, 4

    inc eax                      ; sar peste cuvantul parsat din string
    add edi, eax                 ; string += strlen(cuvant) + 1

    
    cmp byte [ebx], OPERATOR     ; poate fi operator sau numar negativ
    jb verif_is_operator

not_operator:                    ; nu era operator
    mov eax, dword [root]        ; return root

    jmp final_return

is_operator:
    mov ecx, dword[root]         ; retin root-ul dinaintea apelului recursiv
    push ecx

    push edi
    push dword [ecx + 4]         ; apelez recursiv pentru root->left
    call create_subtree
    add esp, 8

    pop ecx
    mov dword [ecx + 4], eax     ; retin noul root

    push ecx

    push edi
    push dword [ecx + 8]         ; apelez recursiv pentru root->right
    call create_subtree
    add esp, 8

    pop ecx
    mov dword [root], ecx        ; restaurez root-ul
    mov dword [ecx + 8], eax
    
return:
    mov eax, dword [root]        ; returnez noul root
    pop ebx
    leave
    ret 

final_return:
    leave
    ret