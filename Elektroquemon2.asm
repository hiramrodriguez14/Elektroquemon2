;-------------------------------------------------------------------------------
;Elektroquemon 2
;Autor: Hiram Rodriguez
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
;-------------------------------------------------------------------------------

; Definición de posiciones en la memoria LCD
pos1	.equ	9
pos2	.equ	5
pos3 	.equ	3
pos4 	.equ	18
pos5	.equ	14
pos6    .equ    7

record		.word 999
time		.word 0xFFFF

; Data para el LCD
teamH .byte 0x80, 0x9F, 0xEF, 0x6C, 0xE0
teamL .byte 0x50, 0x00, 0x00, 0xA0, 0x00

lucasH .byte 0x1C, 0x7C, 0x9C, 0xEF, 0xB7
lucasL .byte 0x00, 0x00, 0x00, 0x00, 0x00

hiramH .byte 0x6F, 0x00, 0xCF, 0xEF, 0x6C
hiramL .byte 0x00, 0x50, 0x02, 0x00, 0xA0

joseH .byte 0x98, 0xFC, 0xB7, 0x9F
joseL .byte 0x50, 0x00, 0x00, 0x00

josueH .byte 0x98, 0xFC, 0xB7, 0x7C, 0x9F
josueL .byte 0x50, 0x00, 0x00, 0x00, 0x00

resetNoH .byte 0xCF, 0x9F, 0xB7, 0x9F, 0x80, 0x6C
resetNoL .byte 0x02, 0x00, 0x00, 0x00, 0x50, 0x82

resetSiH .byte 0xCF, 0x9F, 0xB7, 0x9F, 0x80, 0xB7
resetSiL .byte 0x02, 0x00, 0x00, 0x00, 0x50, 0x00

recH .byte 0xCF, 0x9F, 0x9C
recL .byte 0x02, 0x00, 0x00

niv1H .byte 0x6C, 0x00, 0x7C, 0x00
niv1L .byte 0x82, 0x50, 0x00, 0x50

niv2H .byte 0x6C, 0x00, 0x7C, 0xDB
niv2L .byte 0x82, 0x50, 0x00, 0x00

niv3H .byte 0x6C, 0x00, 0x7C, 0xF3
niv3L .byte 0x82, 0x50, 0x00, 0x00

numerosH .byte 0xFC, 0x00, 0xDB, 0xF3, 0x67, 0xB7, 0xBF, 0xE0, 0xFF, 0xE7
numerosL .byte 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

numerosJuegoH .byte  0x00, 0xDB, 0xF3, 0x67, 0xB7, 0xBF, 0xE0, 0xFF, 0xE7, 0xEF, 0x3F, 0x9C
numerosJuegoL .byte  0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

amibaH .byte 0xEF, 0x6C, 0x00, 0x3F, 0xEF
amibaL .byte 0x00, 0xA0, 0x50, 0x00, 0x00

moscaH .byte 0x6F, 0xFC, 0xB7, 0x9C, 0xEF
moscaL .byte 0xA0, 0x00, 0x00, 0x00, 0x00

coboH .byte 0x9C, 0xFC, 0x3F, 0xFC
coboL .byte 0x00, 0x00, 0x00, 0x00

ratonH .byte 0xCF, 0xEF, 0x80, 0xFC, 0x6C
ratonL .byte 0x02, 0x00, 0x50, 0x00, 0x82

gatoH .byte 0xBD, 0xEF, 0x80, 0xFC
gatoL .byte 0x00, 0x00, 0x50, 0x00

loroH .byte 0x1C, 0xFC, 0xCF, 0xFC
loroL .byte 0x00, 0x00, 0x02, 0x00

lemurH .byte 0x1C, 0x9F, 0x6F, 0x7C, 0xCF
lemurL .byte 0x00, 0x00, 0xA0, 0x00, 0x02

pepitoH .byte 0xCF, 0x9F, 0xCF, 0x00, 0x80, 0xFC
pepitoL .byte 0x00, 0x00, 0x00, 0x50, 0x50, 0x00

perdioH .byte  0xCF, 0x9F, 0xCF, 0x7B, 0x00, 0xFC
perdioL .byte 0x00, 0x00, 0x02, 0x00, 0x50, 0x00

ganoH .byte 0x9E, 0xEF, 0x6C, 0xFC
ganoL .byte 0x02, 0x00, 0x82, 0x00


;-------------------------------------------------------------------------------
; Reset Vector
;-------------------------------------------------------------------------------
RESET:
            MOV.w   #__STACK_END, SP           ; Initialize stack pointer
            MOV.w   #WDTPW | WDTHOLD, &WDTCTL  ; Stop watchdog timer

			MOV.W   #0xFFFF, &LCDCPCTL0
			MOV.W   #0xFC3F, &LCDCPCTL1
			MOV.W   #0x0FFF, &LCDCPCTL2


;Usaremos el Registro 15 para controlar los estados
;IMPORTANTE no utilizar R15 para algo que no sean los estados, ni R12 para algo que no sea el record

	mov.w #0, R15 ; 0 es el INTRO_STATE

;Lista de estados: *Por el momento*
;0: INTRO_STATE, 1: RECORD_MODE, 2: RESETNO, 3:RESETSI, 4:NIV1 (Activado en ResetNoSelect y/o ResetSiSelect), 5: NIV2, 6: NIV3






UnlockGPIO:
        ; Disable de GPIO power-on default
        BIC.W   #LOCKLPM5,&PM5CTL0      ; high-impedance mode to activade
                                        ; previously configured port settings

Setup:

    bic.b   #0xFF, &P1SEL0             ; Configurar P1SEL0 y P1SEL1 a I/O digital
    bic.b   #0xFF, &P1SEL1             ; I/O digital es el valor por defecto

    mov.b   #11111001B, &P1DIR         ; Configurar P1.1 y P1.2 como entradas (0)
                                       ; y los demás pines de P1 como salidas (1)

    mov.b   #00000110B, &P1REN         ; Activar resistencias programables en P1.1 y P1.2
    bis.b   #00000110B, &P1OUT         ; Configurar resistencias en P1.1 y P1.2 como pull-up

    bis.b   #00000010B, &P1IE          ; Habilitar interrupción en P1.1
    bis.b   #00000100B, &P1IE          ; Habilitar interrupción en P1.2
    bis.b   #00000010B, &P1IES         ; Configurar flanco de bajada en P1.1
    bis.b   #00000100B, &P1IES         ; Configurar flanco de bajada en P1.2
    bic.b   #00000010B, &P1IFG         ; Limpiar cualquier bandera de interrupción en P1.1
    bic.b   #00000100B, &P1IFG         ; Limpiar cualquier bandera de interrupción en P1.2


            ; Initialize LCD_C
            ; ACLK, Divider = 1, Pre-divider = 16; 4-pin MUX
            MOV.W   #0x041e, &LCDCCTL0

            ; VLCD generated internally,
            ; V2-V4 generated internally, v5 to ground
            ; Set VLCD voltage to 2.60v
            ; Enable charge pump and select internal reference for it
            MOV.W   #0x0208, &LCDCVCTL

            MOV.W   #0x8000, &LCDCCPCTL   ; Clock synchronization enabled

            MOV.W   #2, &LCDCMEMCTL       ; Clear LCD memory

            ; LCD encendida
            BIS.W   #1, & LCDCCTL0





            ; Inicializar el índice del nombre en 0 (inicia con "TEAM7")
            MOV.B   #0, R6
            CALL    #DisplayTeam



MainLoop:
			MOV.W   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
			NOP
		    BIS.W #GIE+LPM0, SR   ; Habilita el modo de bajo consumo (LPM0) y las interrupciones globales

			NOP
            JMP     MainLoop                 ; Loop here forever

;-------------------------------------------------------------------------------

; Subrutina para mostrar el nombre actual en el LCD
DisplayTeam:
            CMP.B   #0, R6
            JEQ     ShowTeam7
            CMP.B   #1, R6
            JEQ     ShowHiram
            CMP.B   #2, R6
            JEQ     ShowJose
            CMP.B   #3, R6
            JEQ     ShowJosue
            CMP.B   #4, R6
            JEQ     ShowLucas
            ret

ShowTeam7:
            ; Código para mostrar "TEAM7" en el LCD
            MOV.B   #pos1, R14
            MOV.B   #0, R5
            MOV.B   teamH(R5), 0x0a20(R14)
            MOV.B   teamL(R5), 0x0a20+1(R14)

            MOV.B   #pos2, R14
            MOV.B   #1, R5
            MOV.B   teamH(R5), 0x0a20(R14)
            MOV.B   teamL(R5), 0x0a20+1(R14)

            MOV.B   #pos3, R14
            MOV.B   #2, R5
            MOV.B   teamH(R5), 0x0a20(R14)
            MOV.B   teamL(R5), 0x0a20+1(R14)

            MOV.B   #pos4, R14
            MOV.B   #3, R5
            MOV.B   teamH(R5), 0x0a20(R14)
            MOV.B   teamL(R5), 0x0a20+1(R14)

            MOV.B   #pos5, R14
            MOV.B   #4, R5
            MOV.B   teamH(R5), 0x0a20(R14)
            MOV.B   teamL(R5), 0x0a20+1(R14)

            ; Limpiar la posición 5 en el caso de nombres cortos(Ya que son 6 caracteres en el LCD)
            MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
            ret

ShowLucas:
            MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   lucasH(R5),0x0a20(R14)
	        MOV.B   lucasL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   lucasH(R5),0x0a20(R14)
	        MOV.B   lucasL(R5),0x0a20+1(R14)

	        MOV.B   #pos3, R14
            MOV.B   #2, R5
            MOV.B   lucasH(R5), 0x0a20(R14)
            MOV.B   lucasL(R5), 0x0a20+1(R14)
			MOV.B   #pos4,R14

			MOV.B   #pos4, R14
			MOV.B	#3,R5
			MOV.B   lucasH(R5),0x0a20(R14)
	        MOV.B   lucasL(R5),0x0a20+1(R14)

			MOV.B   #pos5,R14
			MOV.B	#4,R5
			MOV.B   lucasH(R5),0x0a20(R14)
	        MOV.B   lucasL(R5),0x0a20+1(R14)

	        MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
            ret

ShowHiram:
            MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   hiramH(R5),0x0a20(R14)
	        MOV.B   hiramL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   hiramH(R5),0x0a20(R14)
	        MOV.B   hiramL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   hiramH(R5),0x0a20(R14)
	        MOV.B   hiramL(R5),0x0a20+1(R14)

			MOV.B   #pos4,R14
			MOV.B	#3,R5
			MOV.B   hiramH(R5),0x0a20(R14)
	        MOV.B   hiramL(R5),0x0a20+1(R14)

			MOV.B   #pos5,R14
			MOV.B	#4,R5
			MOV.B   hiramH(R5),0x0a20(R14)
	        MOV.B   hiramL(R5),0x0a20+1(R14)

	        MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
            ret

ShowJose:
            MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   joseH(R5),0x0a20(R14)
	        MOV.B   joseL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   joseH(R5),0x0a20(R14)
			MOV.B   joseL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   joseH(R5),0x0a20(R14)
	        MOV.B   joseL(R5),0x0a20+1(R14)

			MOV.B   #pos4,R14
			MOV.B	#3,R5
			MOV.B   joseH(R5),0x0a20(R14)
	        MOV.B   joseL(R5),0x0a20+1(R14)


   		    MOV.B   #pos5, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

   			MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
            ret

ShowJosue:
            MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   josueH(R5),0x0a20(R14)
	        MOV.B   josueL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   josueH(R5),0x0a20(R14)
	        MOV.B   josueL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   josueH(R5),0x0a20(R14)
	        MOV.B   josueL(R5),0x0a20+1(R14)

			MOV.B   #pos4,R14
			MOV.B	#3,R5
			MOV.B   josueH(R5),0x0a20(R14)
	        MOV.B   josueL(R5),0x0a20+1(R14)

			MOV.B   #pos5,R14
			MOV.B	#4,R5
			MOV.B   josueH(R5),0x0a20(R14)
	        MOV.B   josueL(R5),0x0a20+1(R14)

	        MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
            ret
;--------------------------------------------------------------------------------
RecordMode:
    MOV     #1, R15               ; Entra en modo de récord
    ; Mostrar "REC" en el display
    MOV.B   #pos1, R14
    MOV.B   #0, R5
    MOV.B   recH(R5), 0x0a20(R14)
    MOV.B   recL(R5), 0x0a20+1(R14)

    MOV.B   #pos2, R14
    MOV.B   #1, R5
    MOV.B   recH(R5), 0x0a20(R14)
    MOV.B   recL(R5), 0x0a20+1(R14)

    MOV.B   #pos3, R14
    MOV.B   #2, R5
    MOV.B   recH(R5), 0x0a20(R14)
    MOV.B   recL(R5), 0x0a20+1(R14)

    ; Calcular centenas, decenas y unidades del record
    mov.w   record,R12
    MOV.W   #100, R7
    CLR     R9
CentenasLoop:
    CMP.W   R7, R12
    JL      Decenas
    SUB.W   R7, R12
    INC     R9
    JMP     CentenasLoop

Decenas:
    MOV.W   #10, R7
    CLR     R8
DecenasLoop:
    CMP.W   R7, R12
    JL      Unidades
    SUB.W   R7, R12
    INC     R8
    JMP     DecenasLoop

Unidades:
    MOV.B   R12, R7           ; Guardar unidades en R7

	MOV.B   #pos4, R14        ; Posición para centenas
	MOV.B   R9, R5            ; Valor de centenas en R5
	CALL    #ShowDigit

	MOV.B   #pos5, R14        ; Posición para decenas
	MOV.B   R8, R5            ; Valor de decenas en R5
	CALL    #ShowDigit

	MOV.B   #pos6, R14        ; Posición para unidades
	MOV.B   R7, R5            ; Valor de unidades en R5
	CALL    #ShowDigit

	reti

; Subrutina para mostrar un dígito en el display en la posición dada por R14
; y el valor en R5 (0-9)
ShowDigit:
    MOV.B   numerosH(R5), 0x0a20(R14)     ; Alto byte del dígito
    MOV.B   numerosL(R5), 0x0a20+1(R14)   ; Bajo byte del dígito
    ret
;-------------------------------------------------------------------------------
ResetNo:
	mov		#2, R15 ;Nuevo modo

	        MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   resetNoH(R5),0x0a20(R14)
	        MOV.B   resetNoL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   resetNoH(R5),0x0a20(R14)
	        MOV.B   resetNoL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   resetNoH(R5),0x0a20(R14)
	        MOV.B   resetNoL(R5),0x0a20+1(R14)

			MOV.B   #pos4,R14
			MOV.B	#3,R5
			MOV.B   resetNoH(R5),0x0a20(R14)
	        MOV.B   resetNoL(R5),0x0a20+1(R14)

			MOV.B   #pos5,R14
			MOV.B	#4,R5
			MOV.B   resetNoH(R5),0x0a20(R14)
	        MOV.B   resetNoL(R5),0x0a20+1(R14)

	        MOV.B   #pos6,R14
			MOV.B	#5,R5
			MOV.B   resetNoH(R5),0x0a20(R14)
	        MOV.B   resetNoL(R5),0x0a20+1(R14)
			reti
;-------------------------------------------------------------------------------
ResetNoSelect:
	MOV #4, R15 ;Nuevo modo

	 		MOV.B   #pos1, R14
            MOV.B   #0, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos2, R14
            MOV.B   #1, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos3, R14
            MOV.B   #2, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos4, R14
            MOV.B   #3, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos5, R14
            MOV.B   #4, R5
    		MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

            MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
			reti
;-------------------------------------------------------------------------------
ResetSi:
		MOV		#3, R15 ;Nuevo modo

	        MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   resetSiH(R5),0x0a20(R14)
	        MOV.B   resetSiL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   resetSiH(R5),0x0a20(R14)
	        MOV.B   resetSiL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   resetSiH(R5),0x0a20(R14)
	        MOV.B   resetSiL(R5),0x0a20+1(R14)

			MOV.B   #pos4,R14
			MOV.B	#3,R5
			MOV.B   resetSiH(R5),0x0a20(R14)
	        MOV.B   resetSiL(R5),0x0a20+1(R14)

			MOV.B   #pos5,R14
			MOV.B	#4,R5
			MOV.B   resetSiH(R5),0x0a20(R14)
	        MOV.B   resetSiL(R5),0x0a20+1(R14)

	        MOV.B   #pos6,R14
			MOV.B	#5,R5
			MOV.B   resetSiH(R5),0x0a20(R14)
	        MOV.B   resetSiL(R5),0x0a20+1(R14)
			reti
;-------------------------------------------------------------------------------
ResetSiSelect:
	mov #4, R15 ;Nuevo modo
	mov #999, R12 ;Reiniciar record a 999

		 	MOV.B   #pos1, R14
            MOV.B   #0, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos2, R14
            MOV.B   #1, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos3, R14
            MOV.B   #2, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos4, R14
            MOV.B   #3, R5
            MOV.B   niv1H(R5), 0x0a20(R14)
            MOV.B   niv1L(R5), 0x0a20+1(R14)

            MOV.B   #pos5, R14
            MOV.B   #4, R5
    		MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

            MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

			reti
;-------------------------------------------------------------------------------
Niv1Select:
	 mov #500000, &TA0CCR1       ; Nivel 1: 1 Hz
	 mov #0, R6
	 call #ShowLevel
	 reti
;-------------------------------------------------------------------------------
Niv2:
	mov #5, R15 ;Nuevo modo

	 		MOV.B   #pos1, R14
            MOV.B   #0, R5
            MOV.B   niv2H(R5), 0x0a20(R14)
            MOV.B   niv2L(R5), 0x0a20+1(R14)

            MOV.B   #pos2, R14
            MOV.B   #1, R5
            MOV.B   niv2H(R5), 0x0a20(R14)
            MOV.B   niv2L(R5), 0x0a20+1(R14)

            MOV.B   #pos3, R14
            MOV.B   #2, R5
            MOV.B   niv2H(R5), 0x0a20(R14)
            MOV.B   niv2L(R5), 0x0a20+1(R14)

            MOV.B   #pos4, R14
            MOV.B   #3, R5
            MOV.B   niv2H(R5), 0x0a20(R14)
            MOV.B   niv2L(R5), 0x0a20+1(R14)

            MOV.B   #pos5, R14
            MOV.B   #4, R5
    		MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

            MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
			reti
;-------------------------------------------------------------------------------
Niv2Select:
	mov #62500,  R12      ; Nivel 2: 2 Hz
	mov #0, R6
	call #ShowLevel
	reti
;-------------------------------------------------------------------------------
Niv3:
	mov #6, R15 ;Nuevo modo

	 		MOV.B   #pos1, R14
            MOV.B   #0, R5
            MOV.B   niv3H(R5), 0x0a20(R14)
            MOV.B   niv3L(R5), 0x0a20+1(R14)

            MOV.B   #pos2, R14
            MOV.B   #1, R5
            MOV.B   niv3H(R5), 0x0a20(R14)
            MOV.B   niv3L(R5), 0x0a20+1(R14)

            MOV.B   #pos3, R14
            MOV.B   #2, R5
            MOV.B   niv3H(R5), 0x0a20(R14)
            MOV.B   niv3L(R5), 0x0a20+1(R14)

            MOV.B   #pos4, R14
            MOV.B   #3, R5
            MOV.B   niv3H(R5), 0x0a20(R14)
            MOV.B   niv3L(R5), 0x0a20+1(R14)

            MOV.B   #pos5, R14
            MOV.B   #4, R5
    		MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

            MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
	reti
;-------------------------------------------------------------------------------
Niv3Select:
	  mov #31250, R12     ; Nivel 3: 4 Hz
	  mov #0, R6
	  call #ShowLevel
	  reti
;-------------------------------------------------------------------------------
ShowLevel:
	;Usaremos R6 para monitorear el nivel inicialmente 0
	  		CMP.B   #0, R6
            JEQ     ShowAmiba
            CMP.B   #1, R6
            JEQ     ShowMosca
            CMP.B   #2, R6
            JEQ     ShowCobo
            CMP.B   #3, R6
            JEQ     ShowRaton
            CMP.B   #4, R6
            JEQ     ShowGato
            CMP.B   #5, R6
            JEQ     ShowLoro
            CMP.B   #6, R6
            JEQ     ShowLemur
            CMP.B   #7, R6
            JEQ     ShowPepito
            ret
;-------------------------------------------------------------------------------
ShowAmiba:
            MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   amibaH(R5),0x0a20(R14)
	        MOV.B   amibaL(R5),0x0a20+1(R14)

			MOV.B   #pos2,R14
			MOV.B	#1,R5
			MOV.B   amibaH(R5),0x0a20(R14)
			MOV.B   amibaL(R5),0x0a20+1(R14)

			MOV.B   #pos3,R14
			MOV.B	#2,R5
			MOV.B   amibaH(R5),0x0a20(R14)
	        MOV.B   amibaL(R5),0x0a20+1(R14)

			MOV.B   #pos4,R14
			MOV.B	#3,R5
			MOV.B   amibaH(R5),0x0a20(R14)
	        MOV.B   amibaL(R5),0x0a20+1(R14)


   		    MOV.B   #pos5, R14
   			MOV.B	#4,R5
			MOV.B   amibaH(R5),0x0a20(R14)
	        MOV.B   amibaL(R5),0x0a20+1(R14)

   			MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
			call #WaitASecond

            ret
ShowMosca:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   moscaH(R5),0x0a20(R14)
	        MOV.B   moscaL(R5),0x0a20+1(R14)

	  	    MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   moscaH(R5),0x0a20(R14)
	        MOV.B   moscaL(R5),0x0a20+1(R14)

		  	MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   moscaH(R5),0x0a20(R14)
	        MOV.B   moscaL(R5),0x0a20+1(R14)

		  	MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   moscaH(R5),0x0a20(R14)
	        MOV.B   moscaL(R5),0x0a20+1(R14)


   			MOV.B   #pos5,R14
			MOV.B	#4,R5
  		    MOV.B   moscaH(R5),0x0a20(R14)
	        MOV.B   moscaL(R5),0x0a20+1(R14)

   			MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
        	call #WaitASecond
            ret
ShowCobo:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   coboH(R5),0x0a20(R14)
	        MOV.B   coboL(R5),0x0a20+1(R14)

	        MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   coboH(R5),0x0a20(R14)
	        MOV.B   coboL(R5),0x0a20+1(R14)

	        MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   coboH(R5),0x0a20(R14)
	        MOV.B   coboL(R5),0x0a20+1(R14)

	        MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   coboH(R5),0x0a20(R14)
	        MOV.B   coboL(R5),0x0a20+1(R14)

	        MOV.B   #pos5,R14
			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

	      	MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
	        call #WaitASecond
   			ret
ShowRaton:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   ratonH(R5),0x0a20(R14)
	        MOV.B   ratonL(R5),0x0a20+1(R14)

	  	    MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   ratonH(R5),0x0a20(R14)
	        MOV.B   ratonL(R5),0x0a20+1(R14)

		  	MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   ratonH(R5),0x0a20(R14)
	        MOV.B   ratonL(R5),0x0a20+1(R14)

		  	MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   ratonH(R5),0x0a20(R14)
	        MOV.B   ratonL(R5),0x0a20+1(R14)


   			MOV.B   #pos5,R14
			MOV.B	#4,R5
  		    MOV.B   ratonH(R5),0x0a20(R14)
	        MOV.B   ratonL(R5),0x0a20+1(R14)

   			MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
	        call #WaitASecond
            ret
ShowGato:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   gatoH(R5),0x0a20(R14)
	        MOV.B   gatoL(R5),0x0a20+1(R14)

	  	    MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   gatoH(R5),0x0a20(R14)
	        MOV.B   gatoL(R5),0x0a20+1(R14)

		  	MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   gatoH(R5),0x0a20(R14)
	        MOV.B   gatoL(R5),0x0a20+1(R14)

		  	MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   gatoH(R5),0x0a20(R14)
	        MOV.B   gatoL(R5),0x0a20+1(R14)


   		    MOV.B   #pos5,R14
			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

	      	MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
	        call #WaitASecond
            ret
ShowLoro:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   loroH(R5),0x0a20(R14)
	        MOV.B   loroL(R5),0x0a20+1(R14)

	  	    MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   loroH(R5),0x0a20(R14)
	        MOV.B   loroL(R5),0x0a20+1(R14)

		  	MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   loroH(R5),0x0a20(R14)
	        MOV.B   loroL(R5),0x0a20+1(R14)

		  	MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   loroH(R5),0x0a20(R14)
	        MOV.B   loroL(R5),0x0a20+1(R14)


   		    MOV.B   #pos5,R14
			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo

	      	MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
	        call #WaitASecond
            ret
ShowLemur:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   lemurH(R5),0x0a20(R14)
	        MOV.B   lemurL(R5),0x0a20+1(R14)

	  	    MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   lemurH(R5),0x0a20(R14)
	        MOV.B   lemurL(R5),0x0a20+1(R14)

		  	MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   lemurH(R5),0x0a20(R14)
	        MOV.B   lemurL(R5),0x0a20+1(R14)

		  	MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   lemurH(R5),0x0a20(R14)
	        MOV.B   lemurL(R5),0x0a20+1(R14)


   			MOV.B   #pos5,R14
			MOV.B	#4,R5
  		    MOV.B   lemurH(R5),0x0a20(R14)
	        MOV.B   lemurL(R5),0x0a20+1(R14)

   			MOV.B   #pos6, R14
   			MOV.B   #0, 0x0a20(R14)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R14)  ; Limpiar el byte bajo
	        call #WaitASecond
            ret
ShowPepito:
		    MOV.B   #pos1,R14
			MOV.B	#0,R5
  		    MOV.B   pepitoH(R5),0x0a20(R14)
	        MOV.B   pepitoL(R5),0x0a20+1(R14)

	  	    MOV.B   #pos2,R14
			MOV.B	#1,R5
  		    MOV.B   pepitoH(R5),0x0a20(R14)
	        MOV.B   pepitoL(R5),0x0a20+1(R14)

		  	MOV.B   #pos3,R14
			MOV.B	#2,R5
  		    MOV.B   pepitoH(R5),0x0a20(R14)
	        MOV.B   pepitoL(R5),0x0a20+1(R14)

		  	MOV.B   #pos4,R14
			MOV.B	#3,R5
  		    MOV.B   pepitoH(R5),0x0a20(R14)
	        MOV.B   pepitoL(R5),0x0a20+1(R14)


   			MOV.B   #pos5,R14
			MOV.B	#4,R5
  		    MOV.B   pepitoH(R5),0x0a20(R14)
	        MOV.B   pepitoL(R5),0x0a20+1(R14)

   			MOV.B   #pos6, R14
   			MOV.B	#5,R5
  		    MOV.B   pepitoH(R5),0x0a20(R14)
	        MOV.B   pepitoL(R5),0x0a20+1(R14)
	        call #WaitASecond
            ret
;------------------------------------------------------------------------------
WaitASecond:
	MOV     #CCIE, &TA0CCTL0        ; Enable TACCR0 interrupt

    MOV     #TASSEL_2+MC_1+ID_3, &TA0CTL  ;Set timer according to next table
    NOP
        ; Uses SMCLK and up mode
        ; TASSELx        MCx (mode control)                IDx (input divider)
        ; 00 -> TACLK    00 -> Stop                        00 -> /1
        ; 01 -> ACLK     01 -> Up mode (up to TACCR0)      01 -> /2
        ; 10 -> SMCLK    10 -> Continuous (up to 0FFFFh)   02 -> /4
        ; 11 -> INCLK    11 -> Up/down (top on TACCR0)     03 -> /8

        ; period = cycles * divider / SMLCK
        ; Assuming SMLCK = 1 MHz, divider = 8 and period = 0.5 seg
        ; cycles = 62500.  With period = 0.5 LED turn on every 1 second
        MOV     #125000, &TA0CCR0        ; Set the timer capture compare register 0
        BIC     #CCIFG, &TA0CCTL1
		BIC     #CCIFG, &TA0CCTL2
	ret
;--------------------------------------------------------------------------------
EnableGame:


	      	 ; Configurar TA0CCR1 para el conteo de segundos transcurridos
	        MOV     #CCIE, &TA0CCTL1      ; Habilitar interrupción en TACCR1
	        MOV     #125000, &TA0CCR1      ; Setear 1 Hz (para segundos) usando el divisor

	        ; Configurar TA0CCR2 para el conteo en la posición extrema derecha
	        MOV     #CCIE, &TA0CCTL2      ; Habilitar interrupción en TACCR2
	        MOV     R12, &TA0CCR2      ; Setear también 1 Hz para el conteo



	        MOV #0xFFFF, R6       ; Esto servira en StartGame:
	        ret
;--------------------------------------------------------------------------------
ShowSeconds:
    ; Incrementar el tiempo transcurrido
    INC     time                ; Incrementar la variable time (almacena el tiempo en segundos)


    ; Calcular centenas, decenas y unidades
    MOV.W   time,R12
    MOV.W   #100, R7
    CLR     R9
CentenasLoop2:
    CMP.W   R7, R12
    JL      Decenas2
    SUB.W   R7, R12
    INC     R9
    JMP     CentenasLoop2

Decenas2:
    MOV.W   #10, R7
    CLR     R8
DecenasLoop2:
    CMP.W   R7, R12
    JL      Unidades2
    SUB.W   R7, R12
    INC     R8
    JMP     DecenasLoop2

Unidades2:
    MOV.B   R12, R7           ; Guardar unidades en R7


   	MOV.B   #pos1, R14        ; Posición para centenas
	MOV.B   R9, R5            ; Valor de centenas en R5
	CALL    #ShowDigit

	MOV.B   #pos2, R14        ; Posición para decenas
	MOV.B   R8, R5            ; Valor de decenas en R5
	CALL    #ShowDigit

	MOV.B   #pos3, R14        ; Posición para unidades
	MOV.B   R7, R5            ; Valor de unidades en R5
	CALL    #ShowDigit
    ret
;--------------------------------------------------------------------------------
StartGame:
			INC R6
			CMP #12, R6
			JEQ     ResetCounter

	   		MOV.B   #pos4,R13
			MOV.B   #0, 0x0a20(R13)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R13)  ; Limpiar el byte bajo

	      	MOV.B   #pos5, R13
   			MOV.B   #0, 0x0a20(R13)    ; Limpiar el byte alto
   			MOV.B   #0, 0x0a20+1(R13)  ; Limpiar el byte bajo


			MOV.B   #pos6,R13
  		    MOV.B   numerosJuegoH(R6),0x0a20(R13)
	        MOV.B   numerosJuegoL(R6),0x0a20+1(R13)
	        ret

ResetCounter:
			MOV	#0,R6
			ret

;--------------------------------------------------------------------------------
; Rutina de servicio de interrupción del temporizador
TIMER_A0_ISR:
Timer0:
    ; Verificar si la interrupción fue causada por TACCR0
    BIT    #CCIFG, &TA0CCTL0        ; Verifica si el bit CCIFG está activo
    JNZ     Timer1                      ; Si no es 1 (la interrupción no fue por CCR0), salimos
    ; Si la interrupción fue por TACCR0, procesar la actualización de LCD
    BIS     #CCIFG, &TA0CCTL0        ; Poner en 1 la bandera de interrupción de TACCR0
	call    #EnableGame
	BIC     #CCIE, &TA0CCTL0

Timer1:

	BIT    #CCIFG, &TA0CCTL1        ; Verifica si el bit CCIFG está activo
	JZ     Timer2
	BIC    #CCIFG, &TA0CCTL1       ; Poner en 0 la bandera de interrupción de TACCR0
	call   #ShowSeconds

Timer2:

	BIT    #CCIFG, &TA0CCTL2       ; Verifica si el bit CCIFG está activo
	JZ     fin
	BIC    #CCIFG, &TA0CCTL2       ; Poner en 0 la bandera de interrupción de TACCR0
	call   #StartGame


fin:
    ; Regresar de la ISR
    reti

;------------------------------------------------------------------------------
; Rutina de servicio de interrupción del puerto 1 (para botón S1)
;-------------------------------------------------------------------------------
PORT1_ISR:
    bit.b   #0x02, &P1IFG         ; Verifica si P1.1 generó la interrupción
    jnz     S1_ISR                ; Si P1.1 generó la interrupción, salta a S1_ISR

    bit.b   #0x04, &P1IFG         ; Verifica si P1.2 generó la interrupción
    jnz     S2_ISR                ; Si P1.2 generó la interrupción, salta a S2_ISR

    reti                            ; Regresa de la interrupción

S1_ISR:
    bic.b   #0x02, &P1IFG          ; Limpia el flag de interrupción de P1.1

    ; Debouncing
    CALL    #DebounceDelay         ; Llamar a la rutina de debouncing

    ; Verificar si el botón sigue presionado (lectura del pin)
    bit.b   #0x02, &P1IN            ; Leer el estado de P1.1
    jnz     NoPressS1              ; Si el botón no está presionado, salir

    ; Si S1 está presionado, realizar la acción correspondiente dependiendo el estado de R15
    CMP     #0, R15
    JEQ     NextMember
    CMP		#2, R15
    JEQ		ResetSi
    CMP		#3, R15
    JEQ		ResetNo
    CMP		#4, R15
    JEQ		Niv2
    CMP		#5, R15
    JEQ		Niv3
    CMP		#6, R15
    JEQ		ResetNoSelect

    reti

NoPressS1:
    reti

NextMember:
    ; Incrementar el índice en R6 y volver a "TEAM7" después de "LUCAS"
    INC.B   R6
    CMP.B   #5, R6                 ; Si R6 == 5, reinicia a 0
    JL      UpdateDisplay
    MOV.B   #0, R6                 ; Reiniciar a "TEAM7"
	call	#DisplayTeam
    reti

UpdateDisplay:
    CALL    #DisplayTeam           ; Actualizar el LCD
    reti

;-----------------------------------------------------------------------------
; Rutina de servicio de interrupción del puerto 1 (para botón S2)
;-----------------------------------------------------------------------------
S2_ISR:
    BIC.B   #0x04, &P1IFG          ; Limpia el flag de interrupción de P1.2

    ; Debouncing: Esperar un tiempo para filtrar el rebote del botón S2
    CALL    #DebounceDelay         ; Llamar a la rutina de debouncing

    ; Verificar si el botón sigue presionado (lectura del pin)
    bit.b   #0x04, &P1IN            ; Leer el estado de P1.2
    jnz     NoPressS2              ; Si el botón no está presionado, salir

    ; Si S2 está presionado, realizar la acción correspondiente dependiendo el estado de R15
    CMP     #0, R15
    JEQ     RecordMode
    CMP 	#1, R15
    JEQ		ResetNo
    CMP		#2, R15
    JEQ		ResetNoSelect
    CMP		#3, R15
    JEQ		ResetSiSelect
    CMP		#4, R15
    JEQ		Niv1Select
    CMP		#5, R15
    JEQ		Niv2Select
    CMP		#6, R15
    JEQ		Niv3Select
    NOP
    reti

NoPressS2:
    reti

;------------------------------------------------------------------------------------
; Rutina de delay para debouncing (espera un tiempo para filtrar el rebote del botón)
;------------------------------------------------------------------------------------
DebounceDelay:
    ; Realizamos un simple loop de espera que crea un pequeño delay
    ; Cambiar el valor de 500 para un debounce más fuerte o más débil según lo necesario.
    MOV     #500, R10             ; Cargar un valor de delay
DelayLoop:
    NOP                           ; No hace nada, solo espera
    DEC     R10                   ; Decrementa el contador
    JNZ     DelayLoop             ; Si R10 != 0, repite el loop
    RET

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
	.global __STACK_END
	.sect   ".stack"
	.align  2
	.word   0x0200

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
	.sect   ".reset"
	.short  RESET

	.sect   ".int37"
	.short  PORT1_ISR               ; P1 interrupt vector

	.sect   ".int44"
    .short  TIMER_A0_ISR
	.end
