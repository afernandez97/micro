;_______________________________________________________________
; Autores: Adrián Fernández Amador
;          Aitor Arnaiz del Val
;
; Pareja: 11
;_______________________________________________________________

;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	PALABRA	DB 4 DUP(0)
	TAM		DW 28
	MATRIZ	DB 1, 0, 0, 0, 1, 1, 0
			DB 0, 1, 0, 0, 1, 0, 1
			DB 0, 0, 1, 0, 0, 1, 1
			DB 0, 0, 0, 1, 1, 1, 1
	BREAK	DB 13, 10, "$"
	PRINT1	DB "Input: ", 34, "       ", 34, "$"
	PRINT2	DB "Output: ", 34, "             ", 34, "$"
	PRINT3	DB "Computation:$"
	PRINT4	DB "     | P1 | P2 | D1 | P4 | D2 | D3 | D4$"
	PRINT5	DB "Word | ?  | ?  |    | ?  |    |    |   $"
	PRINT6	DB "P1   |    |    |    |    |    |    |   $"
	PRINT7	DB "P2   |    |    |    |    |    |    |   $"
	PRINT8	DB "P4   |    |    |    |    |    |    |   $"
DATOS ENDS
;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0)
PILA ENDS
;_______________________________________________________________
; DEFINICION DEL SEGMENTO EXTRA 
EXTRA SEGMENT 
	RES DB 7 DUP (0)
EXTRA ENDS 
;_______________________________________________________________
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS:CODE,DS:DATOS,ES:EXTRA,SS:PILA
;_______________________________________________________________
;COMIENZO DE LA RUTINA 
multMATRIZ PROC NEAR
	;GUARDAMOS EL INPUT EN EL SEGMENTO DE DATOS
	MOV PALABRA[0], DH
	MOV PALABRA[1], DL
	MOV PALABRA[2], BH
	MOV PALABRA[3], BL
	
	;INICIALIZACIONES
	MOV SI, 0H
	MOV DL, 7
	
	bucleMULT: MOV AX, SI
	DIV DL ;AL ES LA FILA Y AH ES LA COLUMNA
	MOV CX, AX ; GUARDAMOS AMBOS VALORES EN CX
	
	;MULT=PALABRA[AL]*MATRIZ[AL][AH]
	MOV BX, CX
	MOV BH, 0H
	MOV AL, PALABRA[BX] ;BL
	MUL MATRIZ[SI] ;EL RESULTADO ESTA EN AX
	
	;RES[AH]+=MULT
	MOV BX, CX
	MOV CL, 8
	SHR BX, CL
	MOV CX, 0H
	MOV CL, RES[BX] ;BH
	ADD CX, AX
	MOV RES[BX], CL ;BH
	
	;COMPROBAMOS LA CONDICION DE SALIDA
	INC SI
	CMP SI, TAM
	JNZ bucleMULT
	
	;CALCULAMOS EN MODULO 2
	MOV SI, 0
	MOV DL, 2
	MOV CL, 8
	modulo: MOV AX, 0H
	MOV AL, RES[SI]
	DIV DL
	SHR AX, CL
	MOV RES[SI], AL
	INC SI
	CMP SI, TAM
	JNZ modulo
	
	;GUARDAMOS LA DIRECCION EN DX:AX
	MOV DX, ES
	MOV AX, OFFSET RES
	RET
multMATRIZ ENDP
;FIN DE LA RUTINA 
;_______________________________________________________________
;COMIENZO DE LA RUTINA 
imprimirRES PROC
	;ORDENAMOS EL RESULTADO CORRECTAMENTE
	MOV ES, DX ;OBTENEMOS SEGMENTO
	MOV BP, AX ;OBTENEMOS OFFSET
	ADD BP, 4
	MOV CL, ES:[BP]  ;CARGAMOS P1 EN CL
	MOV CL, ES:[BP]  ;CARGAMOS P1 EN CL
	SUB BP, 4
	XCHG CL, ES:[BP] ;CAMBIAMOS D1 POR P1
	ADD BP, 2
	XCHG CL, ES:[BP] ;CAMBIAMOS D3 POR D1
	ADD BP, 3
	XCHG CL, ES:[BP] ;CAMBIAMOS P2 POR D3
	SUB BP, 4
	XCHG CL, ES:[BP] ;CAMBIAMOS D2 POR P2
	ADD BP, 3
	MOV ES:[BP], CL  ;GUARDAMOS CL EN P1
	SUB BP, 1
	MOV CL, ES:[BP]  ;CARGAMOS D4 EN CL
	ADD BP, 3
	XCHG CL, ES:[BP] ;CAMBIAMOS P4 POR D4
	SUB BP, 3
	MOV ES:[BP], CL  ;GUARDAMOS CL EN D4
	
	;ACTUALIZAMOS LOS VALORES A IMPRIMIR
	;VALOR DE INPUT
	MOV CL, PALABRA[0]
	ADD CL, 48
	MOV PRINT1[8], CL
	MOV CL, PALABRA[1]
	ADD CL, 48
	MOV PRINT1[10], CL
	MOV CL, PALABRA[2]
	ADD CL, 48
	MOV PRINT1[12], CL
	MOV CL, PALABRA[3]
	ADD CL, 48
	MOV PRINT1[14], CL
	
	;VALOR DE OUTPUT
	;BIT 0
	MOV ES, DX
	MOV BP, AX
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[9], CL
	MOV PRINT6[7], CL
	INC BP
	
	;BIT 1
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[11], CL
	MOV PRINT7[12], CL
	INC BP
	
	;BIT 2
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[13], CL
	MOV PRINT5[18], CL
	MOV PRINT6[18], CL
	MOV PRINT7[18], CL
	INC BP
	
	;BIT 3
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[15], CL
	MOV PRINT8[22], CL
	INC BP
	
	;BIT 4
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[17], CL
	MOV PRINT5[28], CL
	MOV PRINT6[28], CL
	MOV PRINT8[28], CL
	INC BP
	
	;BIT 5
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[19], CL
	MOV PRINT5[33], CL
	MOV PRINT7[33], CL
	MOV PRINT8[33], CL
	INC BP
	
	;BIT 6
	MOV CL, ES:[BP]
	ADD CL, 48
	MOV PRINT2[21], CL
	MOV PRINT5[38], CL
	MOV PRINT6[38], CL
	MOV PRINT7[38], CL
	MOV PRINT8[38], CL
	
	;IMPRIMIMOS LOS RESULTADOS
	;INPUT
	MOV AH, 9
	MOV DX, OFFSET PRINT1
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;OUTPUT
	MOV DX, OFFSET PRINT2
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;COMPUTATION
	MOV DX, OFFSET PRINT3
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;LISTA DE BITS
	MOV DX, OFFSET PRINT4
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;WORD
	MOV DX, OFFSET PRINT5
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;P1
	MOV DX, OFFSET PRINT6
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;P2
	MOV DX, OFFSET PRINT7
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	
	;P4
	MOV DX, OFFSET PRINT8
	INT 21H
	MOV DX, OFFSET BREAK
	INT 21H
	RET
imprimirRES ENDP
;FIN DE LA RUTINA 
;_______________________________________________________________
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL (START)
START PROC
	;INICIALIZA LOS REGISTROS DE SEGMENTO CON SUS VALORES 
	MOV AX, DATOS 
	MOV DS, AX 

	MOV AX, EXTRA 
	MOV ES, AX 

	MOV AX, PILA 
	MOV SS, AX 
	;FIN DE LAS INICIALIZACIONES
	
	;COMIENZO DEL PROGRAMA 
	MOV DX, 0100H
	MOV BX, 0101H
	CALL multMATRIZ
	CALL imprimirRES
	;FIN DEL PROGRAMA 
	
	MOV AX, 4C00H
	INT 21H

START ENDP
;FIN DEL SEGMENTO DE CODIGO
CODE ENDS
;FIN DE PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END START