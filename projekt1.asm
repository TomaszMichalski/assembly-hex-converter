dane segment
;kazda cyfra jest rozmiaru 7x9 (wys x szer)
zero db	'   ###  $','  #   # $',3 dup (' #     #$'),'  #   # $','   ###  $'
one db '    #   $','   ##   $','  # #   $',3 dup ('    #   $'),'  ##### $'
newline db 10,13,'$'
errmsg db 'Bledna liczba$'

dane ends

kod segment

start:
	;inicjalizacja stosu
	mov ax,seg top1
	mov ss,ax
	mov sp,offset top1
	
	;wczytanie do AL kodu ascii znaku - cyfry w systemie szesnastkowym z STDIN (instrukcja przerwania 21h, AH=08h)
	mov ah,8
	int 21h
	
	;=============================================
	;konwersja z systemu szesnastkowego na binarny
	
	;porownanie al z '0' (sprawdzenie warunku koniecznego do wypisania banneru: [Al]>=48d)
	cmp al,'0'
	;blad
	jb errormessage
	
	;porownanie al z '9' (znak w przedziale 48d - 57d)
	cmp al,'9'
	jg cmp1
	;zamiana cyfry
	sub al,'0' ;odejmujemy 48d
	jmp prepare

cmp1:
	;porownanie al<'A' (znak w przedziale 58d - 64d)
	cmp al,'A'
	;blad
	jb errormessage
	
	;porownanie al z 'F' (znak w przedziale 65d - 70d)
	cmp al,'F'
	jg cmp2
	;zamiana cyfry
	sub al,'A' ;odejmujemy 65d
	add al,10 ;dodajemy 10 zeby otrzymac liczbe dwucyfrowa z przedzialu 10 - 15
	jmp prepare
	
cmp2:
	;porownanie al<'a' (znak w przedziale 71d - 96d)
	cmp al,'a'
	;blad
	jb errormessage
	
	;porownanie al z 'f' (znak w przedziale 97d - 102d)
	cmp al,'f'
	jg errormessage
	;zamiana cyfry
	sub al,'a' ;odejmujemy 97d
	add al,10 ;dodajemy 10 zeby otrzymac liczbe dwucyfrowa z przedzialu 10-15
	jmp prepare
	
	;koniec konwersji
	;================
	
	;===========
	;wypisywanie
	
prepare:
	push ax ;ustawienie DS
	mov ax,seg zero
	mov ds,ax
	pop ax
	mov cl,4
	shl al,cl
	mov bx,0 ;przesuniecie na zadany element bitu (zwiekszane o 9 (szerokosc bitu) po kazdym wierszu)
	mov cx,7 ;licznik petli zewnetrznej - wypisywanie i-tego wiersz	
	jmp write
	
write:
	push ax ;umieszczamy pierwotna wartosc ax na stosie
	push cx ;umieszczamy licznik petli zewnetrznej na stosie
	
	mov cx,4 ;licznik petli wewnetrznej - wypisywanie czesci j-tego bitu
	jmp writeLine
writeLine:
	shl al,1 ;przesuniecie bitow z o 1 w lewo (do sprawdzenia CF) i skok do odpowiedniego wypisania
	jc writeOne
	jnc writeZero
	
writeOne:
    push ax ;umieszczamy aktualne ax na stosie
	mov dx,offset one
	add dx,bx
	mov ah,9 ;wypisanie elementu
	int 21h
	pop ax ;pobieramy wczesniej umieszczone aktualne ax ze stosu
	jmp innerLoop
writeZero:
    push ax ;umieszczamy aktualne ax na stosie
	mov dx,offset zero
	add dx,bx
	mov ah,9 ;wypisanie elementu
	int 21h
	pop ax ;pobieramy wczesniej umieszczone aktualne ax ze stosu
	jmp innerLoop
innerLoop:
	loop writeLine
	
	push ax
	mov dx,offset newline
	mov ah,9
	int 21h
	pop ax
	
	add bx,9 ;zwiekszamy przesuniecie na element bitu
	pop cx ;pobranie licznika petli zewnetrznej ze stosu
	pop ax ;pobranie pierwotnej wartosci ax ze stosu
	loop write
	
	;koniec wypisywania
	;==================
	
	jmp exit ;konczymy program po wypisaniu
	
errormessage: ;odpowiada za wyswietlenie informacji o bledzie
	mov ax,seg errmsg
	mov ds,ax
	mov dx,offset errmsg
	;wyswietlenie zawartosci ds:dx
	mov ah,9
	int 21h
	jmp exit
	
exit: ;odpowiada za wyjscie z programu i powrot do DOS
	
	mov ah,4ch
	int 21h

kod ends

stos1 segment stack

	 dw	200 dup(?)
top1 dw ?

stos1 ends

end start