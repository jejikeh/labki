.model small
 
.stack 100h
 
.data
        String          db      '    bgh ety avc ckn dre '
        StrLen          dw      $-String
                        db      0Dh, 0Ah, '$'
        DelimChar       db      ' '     ;??????, ??????????? ????
        CrLf            db      0Dh, 0Ah, '$'
        msgPressAnyKey  db      'Press any key to exit...', '$'
 
        ;?????????????? ???????? ???????????? ?????
        ptrMinWord      dw      ?       ;????? ???????? ?????
        LenMinWord      dw      ?       ;????? ???????? ?????
        ;???????, ? ??????? ????? ???????????? ???????????
        ;?? ?????????? ? ?????? ????
        ptrPosition     dw      ?
.code
 
main    proc
        mov     ax,     @data
        mov     ds,     ax
 
        ;????? ???????? ??????
        mov     ah,     09h
        lea     dx,     [String]
        int     21h
 
        ;?????????? ? ?????????? ????????? ?????????? ??????
        cld
        mov     ax,     ds
        mov     es,     ax
 
        lea     si,     [String]
        mov     cx,     [StrLen]
        jcxz    @@Break
        @@ForEachWord:
                ;???????? ?????, ?? ??????? ??? ???????? ??
                ;?????????? ? ?????? ????
                call    GetNextWord
                jcxz    @@Break
                push    cx
                mov     [ptrPosition],  si
                mov     [ptrMinWord],   si
                mov     [LenMinWord],   bx
 
                @@SearchMinWord:
                        add     si,     bx      ;??????? ? ?????????? ?????
                        sub     cx,     bx      ;?.?. ? bx ????? ???????????????
                        call    GetNextWord
                        jcxz    @@ReplaceWords
                        push    si
                        push    cx
                        push    bx
 
                        mov     di,     si      ;?????? ??????
                        mov     bx,     bx
                        mov     si,     [ptrMinWord]    ;?????? ??????
                        mov     cx,     [LenMinWord]
 
                        call    SCmp
                        jle     @@SearchNext
                                ;???????? ???????? ? ??????????? ??????
                                mov     [ptrMinWord],   di
                                mov     [LenMinWord],   bx
                @@SearchNext:
                        pop     bx
                        pop     cx
                        pop     si
                jmp     @@SearchMinWord
        @@ReplaceWords:
                ;???????? ??????
                mov     si,     [ptrPosition]
                mov     ax,     [ptrMinWord]
                sub     ax,     si
                mov     cx,     ax
                add     cx,     [LenMinWord]
                call    ArrRotateLeft
 
                sub     cx,     [LenMinWord]
                add     si,     [LenMinWord]
                call    ArrRotateRight
                ;?????????????? ????????? ??????
                pop     cx
                mov     si,     [ptrPosition]
                ;??????? ? ??????????? ????? ?????
                add     si,     [LenMinWord]
                sub     cx,     [LenMinWord]
 
        jnz     @@ForEachWord
@@Break:
 
        ;????? ???????????
        mov     ah,     09h
        lea     dx,     [String]
        int     21h
 
        mov     ah,     09h
        lea     dx,     [CrLf]
        int     21h
@@Exit:
        mov     ax,     4C00h
        int     21h
main    endp
 
;????????? ???? ?????
;?? ?????:
; ds:si - ????? ?????? ??????
; cx    - ????? ?????? ??????
; ds:di - ????? ?????? ??????
; bx    - ????? ?????? ??????
;?? ??????:
;  CY=1 ZF=0, ??? S1<S2
;  CY=0 ZF=1, ??? S1=S2
;  CY=0 ZF=0, ??? S1>S2
SCmp    proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    es
 
        push    ds
        pop     es
 
        ;ax=cx=len1
        ;cx=min(len1, len2)
        ;bx=len2-min(len1, len2)=0 ??? ???????? ????
        push    cx
        push    bx
        sub     bx,     cx
        sbb     ax,     ax
        and     ax,     bx
        add     cx,     ax
        pop     bx
        pop     ax
        sub     bx,     ax
        ;???????? ????????? ??????????? ?????
        repe    cmpsb
        jnz     @@scExit
@@scCmpLen:
        ;???? ????????? ?????, ?? ????????? ?????
        xor     ax,     ax
        cmp     ax,     bx
@@scExit:
        pop     es
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
SCmp    endp
 
;??????? ? ?????????? ????? ? ??????
;?? ?????:
; ds:si - ????? ??????
; cx    - ????? ??????
;?? ??????:
; ds:si - ????? ??????? ??????? ????? ? ??????
; cx    - ????? ?????? ?? ??????? ??????? ?????? ?????
; bx    - ????? ?????????? ?????
GetNextWord     proc
        push    ax
        ;push   bx
        ;push   cx
        push    dx
        ;push   si
        push    di
        push    es
        xor     bx,     bx
        jcxz    @@gnwExit
        mov     al,     [DelimChar]
        ;??????? ???????????? (????????)
        @@SkipDelimiters:
                cmp     al,     [si]
                jne     @@NewWord
                inc     si
        loop    @@SkipDelimiters
        jcxz    @@gnwExit       ;???? ?????? ??????????? - ?????
        ;??????? ????? ?????
@@NewWord:
        ;?????????? ??? ????? ????? ?? ???????????
        ;????????? ????? ?????
        push    cx
        mov     di,     si
        xor     bx,     bx              ;bx - ????? ?????????? ?????
        @@WhileWord:
                cmp     al,     [di]
                je      @@gnwBreak
                inc     bx              ;??????????? ????? ?????
                inc     di              ;????????? ? ?????????? ???????
        loop    @@WhileWord
@@gnwBreak:
        pop     cx
@@gnwExit:
        push    ds
        pop     es
        pop     es
        pop     di
        ;pop    si
        pop     dx
        ;pop    cx
        ;pop    bx
        pop     ax
        ret
GetNextWord     endp
 
;???????? ??????? ???? ?????
;?? ?????:
; ds:si - ????? (?????????) ?? ??????
; cx    - ????? ???????
; ax    - ???????? ??????
;Reversal algorithm for array rotation
;Function to left rotate arr[] of size n by d
;  reverse(arr[], 0, d-1)
;  reverse(arr[], d, n-1)
;  reverse(arr[], 0, n-1)
ArrRotateLeft   proc
        push    ax
        push    cx
        push    dx
        push    si
        push    di
 
        or      ax,     ax
        jz      @@arlExit
        mov     dx,     si
        ;  reverse(arr[], 0, d-1)
        mov     si,     dx
        mov     di,     si
        add     di,     ax
        dec     di
        call    ArrReverse
        ;  reverse(arr[], d, n-1)
        mov     si,     dx
        mov     di,     dx
        add     si,     ax
        add     di,     cx
        dec     di
        call    ArrReverse
        ;  reverse(arr[], 0, n-1)
        mov     si,     dx
        mov     di,     dx
        add     di,     cx
        dec     di
        call    ArrReverse
@@arlExit:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     ax
        ret
ArrRotateLeft   endp
 
;?????? ????????? ???????
;?? ?????:
; ds:si - ????? (?????????) ?? ?????? ??????? ???????
; ds:di - ????? (?????????) ?? ????????? ??????? ???????
ArrReverse      proc
        push    ax
        @@reverse:
                mov     al,     [si]
                mov     ah,     [di]
                mov     [si],   ah
                mov     [di],   al
                inc     si
                dec     di
                cmp     si,     di
        jb      @@reverse
        pop     ax
        ret
ArrReverse      endp
 
;???????? ??????? ???? ?????? ?? 1 ???????
;?? ?????:
; ds:si - ????? (?????????) ?? ??????
; cx    - ????? ???????
ArrRotateRight  proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
 
        or      ax,     ax
        jz      @@arrExit
        cmp     cx,     1
        jbe     @@arrExit
 
        dec     cx
        mov     bx,     si
 
        mov     di,     si
        add     di,     cx
 
        mov     al,     [di]
 
        mov     si,     di
        dec     si
 
        std
        rep     movsb
        mov     [bx],   al
        cld
 
@@arrExit:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
ArrRotateRight  endp
 
end     main