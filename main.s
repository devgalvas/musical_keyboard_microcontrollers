RCC_BASE EQU 0x40021000
RCC_APB1ENR EQU RCC_BASE+0x1C
RCC_APB2ENR EQU RCC_BASE+0x18

;Registros do AFIO (0x40010000 - 0x400103FF)
AFIO_MAPR   EQU 0x40010000+0x04

;Registros da GPIOA (0x40010800 - 0x40010BFF)
GPIOA_CRL   EQU 0x40010800
GPIOA_CRH   EQU 0x40010800+0x04
GPIOA_IDR   EQU 0x40010800+0x08
GPIOA_ODR   EQU 0x40010800+0x0C
GPIOA_BSRR  EQU 0x40010800+0x10
GPIOA_BRR   EQU 0x40010800+0x14

;Registros da GPIOB (0x40010C00 - 0x40010FFF)
GPIOB_CRL   EQU 0x40010C00
GPIOB_CRH   EQU 0x40010C00+0x04
GPIOB_IDR   EQU 0x40010C00+0x08
GPIOB_ODR   EQU 0x40010C00+0x0C
GPIOB_BSRR  EQU 0x40010C00+0x10
GPIOB_BRR   EQU 0x40010C00+0x14
	
; Registros da GPIOC (0x40011000 - 0x400113FF)
GPIOC_CRL   EQU 0x40011000        ; configuração pinos 0..7
GPIOC_CRH   EQU 0x40011000+0x04   ; configuração pinos 8..15
GPIOC_IDR   EQU 0x40011000+0x08   ; input data register
GPIOC_ODR   EQU 0x40011000+0x0C   ; output data register
GPIOC_BSRR  EQU 0x40011000+0x10   ; bit set/reset register
GPIOC_BRR   EQU 0x40011000+0x14   ; bit reset register

;Controlde do LCD
LCD_EN      EQU 0x1000     
LCD_RS      EQU 0x8000     
;LCD_RW      EQU 0x0400    ;10
;LCD_RS_RW   EQU LCD_RS+LCD_RW

;Máscaras de configuração
hab_gpiob_gpioa_afio EQU 0x0D       ;afion_0+iopaen_2+iopben_3=0x0D
JTAG_GPIO            EQU 0x02000000 ;remapeia JTAG para GPIO

; Registros do Timer 3
TIM3_BASE EQU 0x40000400
TIM3_CR1 EQU TIM3_BASE+0x00
TIM3_CCER EQU TIM3_BASE+0x20
TIM3_CCMR2 EQU TIM3_BASE+0x1C
TIM3_PSC EQU TIM3_BASE+0x28
TIM3_ARR EQU TIM3_BASE+0x2C
TIM3_CCR3 EQU TIM3_BASE+0x3C

;===========================================================
; Área de Dados
;===========================================================
		AREA DADOS, DATA, READONLY
PSC_TAB
        DCW 2750    ; SW5 (PB5) - C  (Dó)
        DCW 2450    ; SW6 (PB4) - D  (Ré)
        DCW 2183    ; SW7 (PB3) - E  (Mi)
        DCW 2060    ; SW8 (PA3) - F  (Fá)
        DCW 1835    ; SW9 (PA4) - G  (Sol)
        DCW 1635    ; SW10 (PB8) - A  (Lá)
        DCW 1456    ; SW11 (PB9) - B  (Si)
        DCW 0       ; SW12 - (sem nota)
        DCW 2596    ; SW13 (PB10) - C# (Dó sustenido)
        DCW 2313    ; SW14 (PA7) - D# (Ré sustenido)
        DCW 1944    ; SW15 (PC15) - F# (Fá sustenido)
        DCW 1732    ; SW16 (PC14) - G# (Sol sustenido)
        DCW 1543    ; SW17 (PC13) - A# (Lá sustenido)

		AREA DADOS2, DATA, READONLY
PSC_TAB_OIT2
        DCW 1375    ; C  (523 Hz)
        DCW 1225    ; D  (587 Hz)
        DCW 1091    ; E  (659 Hz)
        DCW 1030    ; F  (698 Hz)
        DCW 917     ; G  (783 Hz)
        DCW 817     ; A  (880 Hz)
        DCW 728     ; B  (987 Hz)
        DCW 0       ; (sem nota)
        DCW 1298    ; C#
        DCW 1156    ; D#
        DCW 972     ; F#
        DCW 866     ; G#
        DCW 771     ; A#

		AREA VARIAVEIS, DATA, READWRITE
VALOR_DUTY DCW 50 ; começa com 50% 
ESTADO_OIT DCW 0; 0 = oitava 1 / 1 = oitava 2


		

;===========================================================
; Código Principal
;===========================================================
        EXPORT __main
        AREA atv1, CODE, READONLY
        
__main
		;Habilitando remapeamento da JTAG(0), GPIOA(2) e GPIOB(3)
        LDR R1,=RCC_APB2ENR
        LDR R0,[R1]
		ORR R0,R0, #hab_gpiob_gpioa_afio    
		STR R0,[R1]	   
                 
		;Remapeando JTAG para GPIO
		LDR R1,=AFIO_MAPR                  
		LDR R0,=JTAG_GPIO                   
		STR R0,[R1]     

        ; Habilita GPIOC
        LDR R1, =RCC_APB2ENR
        LDR R0, [R1]
        ORR R0, R0, #0x10
        STR R0, [R1]
		
		; ---------------------------------------------------------
		; 1. CONFIGURAÇÃO PORTA A (GPIOA)
		; ---------------------------------------------------------
		; --- GPIOA_CRL (Pinos 0-7) ---
		LDR R1, =GPIOA_CRL
		LDR R0, [R1]
		LDR R2, =0xFF0FF000     ; Limpa PA7, PA6, PA5, PA4, PA3
		BIC R0, R0, R2
		LDR R2, =0x83388000     ; Seta: PA7=8, PA6=3, PA5=3, PA4=8, PA3=8
		ORR R0, R0, R2          ; (Adicione 333 no final se quiser configurar PA0-2 aqui também)
		STR R0, [R1]

		; --- GPIOA_CRH (Pinos 8-15) ---
		LDR R1, =GPIOA_CRH
		LDR R0, [R1]
		LDR R2, =0xF00FF00F     ; Limpa PA15, PA12, PA11, PA8
		BIC R0, R0, R2
		LDR R2, =0x30033003     ; Seta: PA15=3, PA12=3, PA11=3, PA8=3
		ORR R0, R0, R2
		STR R0, [R1]

		; Ativar Pull-ups (Apenas nas entradas: PA3, PA4, PA7)
		LDR R1, =GPIOA_ODR
		LDR R0, [R1]
		LDR R2, =0x0098         ; Bits: 7(sw14), 4(sw9), 3(sw8)
		ORR R0, R0, R2
		STR R0, [R1]

		; ---------------------------------------------------------
		; 2. CONFIGURAÇÃO PORTA B (GPIOB)
		; ---------------------------------------------------------
		; --- GPIOB_CRL (Pinos 0 a 7) ---
		LDR R1, =GPIOB_CRL
		LDR R0, [R1]
		LDR R2, =0x00FFFF0F     ; Limpa PB5, PB4, PB3, PB1, PB0
		BIC R0, R0, R2
		LDR R2, =0x0088800B     ; Seta: PB5=8, PB4=8, PB3=8, PB0=B (Alt Func)
		ORR R0, R0, R2
		STR R0, [R1]

		; --- GPIOB_CRH (Pinos 8 a 15) ---
		LDR R1, =GPIOB_CRH
		LDR R0, [R1]
		LDR R2, =0xFFFF0FFF     ; Limpa PB12-15 e PB8-10
		BIC R0, R0, R2
		LDR R2, =0x88880888     ; Seta todos esses como 0x8
		ORR R0, R0, R2
		STR R0, [R1]

		; --- GPIOB_ODR (Ativar Pull-ups das Entradas) ---
		LDR R1, =GPIOB_ODR
		LDR R0, [R1]
		LDR R2, =0xF738         ; Ativa pull-ups apenas dos botões
		ORR R0, R0, R2
		STR R0, [R1]

		; ---------------------------------------------------------
		; 3. CONFIGURAÇÃO PORTA C (GPIOC)
		; ---------------------------------------------------------
		LDR R1, =GPIOC_CRH
		LDR R0, [R1]
		LDR R2, =0xFFF00000     ; Limpa PC13, PC14, PC15
		BIC R0, R0, R2
		LDR R2, =0x88800000     ; Configura como 0x8
		ORR R0, R0, R2
		STR R0, [R1]

		; Ativar Pull-ups (PC13, PC14, PC15)
		LDR R1, =GPIOC_ODR
		LDR R0, [R1]
		LDR R2, =0xE000         ; Bits 13, 14, 15
		ORR R0, R0, R2
		STR R0, [R1]
        
		
		; ---------------------------------------------------------
		; 4. CONFIGURAÇÃO TIMER 3
		; ---------------------------------------------------------
        ; Habilita Timer 3 (bit 1 do APB1ENR)
        LDR R0, =RCC_APB1ENR
        LDR R1, [R0]
        ORR R1, R1, #0x02       ; bit 1 para TIM3
        STR R1, [R0]
        
        ; Configura ARR = 99
        LDR R0, =TIM3_ARR
        MOV R1, #99
        STR R1, [R0]
        
        ; Configura CCR3 = 50 (ciclo de trabalho 50%)
        LDR R0, =TIM3_CCR3
        MOV R1, #50
        STR R1, [R0]
        
        ; Configura CCMR2 - Canal 3 como PWM mode 1
        ; OC3M = 110 (bits 6:4), OC3PE = 1 (bit 3)
        LDR R0, =TIM3_CCMR2
        MOV R1, #0x68           ; 0110 1000 = PWM mode 1 com preload enable
        STR R1, [R0]
        
        ; NÃO habilita CCER aqui - será habilitado em toca_nota
        
loop_principal
		BL verifica_controles
		BL tecla_id             ; R4 = índice (0-12) ou 0xFF
		
        CMP R4, #0xFF
        BNE tecla_pressionada   ; Se tem tecla, vai tocar
        
        ; Nenhuma tecla: desabilita timer E saída
        LDR R0, =TIM3_CR1
        MOV R1, #0x00
        STR R1, [R0]
        
        LDR R0, =TIM3_CCER
        MOV R1, #0x0000          ; Desabilita CC3E
        STR R1, [R0]
        
        B loop_principal
        
tecla_pressionada
        BL toca_nota            ; R4 já tem o índice certo!
        B loop_principal

;===========================================================
; Sub-rotina: toca_nota 
; Entrada: R4 = índice da nota (0 a 12)
; Saída: nenhuma
; Descrição: Configura o PSC e habilita o Timer 3 para tocar a nota
;===========================================================
;toca_nota
;        PUSH {R0-R3, LR}
;        
;        ; Busca o valor de PSC na tabela
;        LDR R0, =PSC_TAB
;        LSL R1, R4, #1          ; multiplica índice por 2 (cada entrada tem 2 bytes)
;        LDRH R2, [R0, R1]       ; carrega o valor de PSC (halfword)
;        
;        ; Configura o PSC do Timer 3
;        LDR R0, =TIM3_PSC
;        STR R2, [R0]
;        
;        ; Habilita saída do canal 3 (CC3E = 1, bit 8)
;        LDR R0, =TIM3_CCER
;        MOV R1, #0x0100
;        STR R1, [R0]
;        
;        ; Habilita o Timer 3 (CEN = 1, bit 0 do CR1)
;        LDR R0, =TIM3_CR1
;        MOV R1, #0x01
;        STR R1, [R0]
;        
;        POP {R0-R3, PC}

;===========================================================
; Sub-rotina: toca_nota  (MODIFICADA)
; Entrada: R4 = índice da nota (0 a 12)
; Saída: nenhuma
; Descrição: Configura o PSC e habilita o Timer 3 para tocar a nota, dependendo da oitava selecionada
;===========================================================

toca_nota
	PUSH {R0-R3, LR}
	
	; 00. Verifica em qual oitava estamos
	LDR R0, =ESTADO_OIT
	LDRH R3, [R0]
	CMP R3, #1
	BEQ carrega_oit2
	
	; 1. Busca o valor base PSC na tabela
	LDR R0, =PSC_TAB
	LSL R1, R4, #1          ; multiplica índice por 2 (cada entrada tem 2 bytes)
	LDRH R2, [R0, R1]       ; carrega o valor de PSC (halfword)
	
	; 2. Verifica em qual oitava estamos
	LDR R0, =ESTADO_OIT
	LDRH R3, [R0]				
	BNE configura_psc		; se nao usa o valor normal
	
	; e se for a 2a?
	LSR R2, R2, #1			; vamos dividir PSC por 2

carrega_oit2
	; Carrega a tabela 2 (AGUDA)
	LDR R0, =PSC_TAB_OIT2

configura_psc
	
	; R0 agora tem o endereco da tabela correta
	LSL R1, R4, #1 		; indice * 2 (offset)
	LDRH R2, [R0, R1]	; carrega o valor de PSC da tabela escolhida

	; 3. Escreve no Timer
	LDR R0, =TIM3_PSC
	STR R2, [R0]
	
	; 4. Garante que o Duty Cicle atual esta aplicado
	LDR R0, =VALOR_DUTY
	LDRH R3, [R0]
	LDR R0, =TIM3_CCR3
	STR R3, [R0]
	
	; 5. Habilita a saida e timer 
	LDR R0, =TIM3_CCER
	MOV R1, #0x0100         ; CC3E enable
    STR R1, [R0]
        
    LDR R0, =TIM3_CR1
    MOV R1, #0x01           ; CEN enable
    STR R1, [R0]
        
    POP {R0-R3, PC}
		
;===========================================================
; Sub-rotina: tecla_id
; Identifica qual tecla está pressionada
; Saída: R4 = índice da tabela PSC (0-12) ou 0xFF se nenhuma
;===========================================================
tecla_id
        PUSH {R0-R3, LR}
        
        MOV R4, #0xFF           ; Assume nenhuma tecla pressionada
        
        ; Verifica PB5 (SW5 - índice 0)
        LDR R0, =GPIOB_IDR
        LDR R1, [R0]
        TST R1, #0x20           ; testa bit 5
        BNE check_pb4           ; se 1 (não pressionada), próxima
        MOV R4, #0              ; SW5 = índice 0
        B tecla_id_fim
        
check_pb4
        ; Verifica PB4 (SW6 - índice 1)
        TST R1, #0x10           ; testa bit 4
        BNE check_pb3
        MOV R4, #1              ; SW6 = índice 1
        B tecla_id_fim
        
check_pb3
        ; Verifica PB3 (SW7 - índice 2)
        TST R1, #0x08           ; testa bit 3
        BNE check_pa3
        MOV R4, #2              ; SW7 = índice 2
        B tecla_id_fim
        
check_pa3
        ; Verifica PA3 (SW8 - índice 3)
        LDR R0, =GPIOA_IDR
        LDR R1, [R0]
        TST R1, #0x08           ; testa bit 3
        BNE check_pa4
        MOV R4, #3              ; SW8 = índice 3
        B tecla_id_fim
        
check_pa4
        ; Verifica PA4 (SW9 - índice 4)
        TST R1, #0x10           ; testa bit 4
        BNE check_pb8
        MOV R4, #4              ; SW9 = índice 4
        B tecla_id_fim
        
check_pb8
        ; Verifica PB8 (SW10 - índice 5)
        LDR R0, =GPIOB_IDR
        LDR R1, [R0]
        TST R1, #0x0100         ; testa bit 8
        BNE check_pb9
        MOV R4, #5              ; SW10 = índice 5
        B tecla_id_fim
        
check_pb9
        ; Verifica PB9 (SW11 - índice 6)
        TST R1, #0x0200         ; testa bit 9
        BNE check_pb10
        MOV R4, #6              ; SW11 = índice 6
        B tecla_id_fim
        
check_pb10
        ; Verifica PB10 (SW13 - índice 8)
        TST R1, #0x0400         ; testa bit 10
        BNE check_pa7
        MOV R4, #8              ; SW13 = índice 8
        B tecla_id_fim
        
check_pa7
        ; Verifica PA7 (SW14 - índice 9)
        LDR R0, =GPIOA_IDR
        LDR R1, [R0]
        TST R1, #0x80           ; testa bit 7
        BNE check_pc15
        MOV R4, #9              ; SW14 = índice 9
        B tecla_id_fim
        
check_pc15
        ; Verifica PC15 (SW15 - índice 10)
        LDR R0, =GPIOC_IDR
        LDR R1, [R0]
        TST R1, #0x8000         ; testa bit 15
        BNE check_pc14
        MOV R4, #10             ; SW15 = índice 10
        B tecla_id_fim
        
check_pc14
        ; Verifica PC14 (SW16 - índice 11)
        TST R1, #0x4000         ; testa bit 14
        BNE check_pc13
        MOV R4, #11             ; SW16 = índice 11
        B tecla_id_fim
        
check_pc13
        ; Verifica PC13 (SW17 - índice 12)
        TST R1, #0x2000         ; testa bit 13
        BNE tecla_id_fim
        MOV R4, #12             ; SW17 = índice 12
        
tecla_id_fim
        POP {R0-R3, PC}

;===========================================================
; Sub-rotina: verifica_controles
; Lê SW1-SW4 e atualiza Duty Cycle e Oitava
;===========================================================
verifica_controles
	PUSH {R0-R3, LR}
	
	; Ler GPIOB_IDR
	LDR R0, =GPIOB_IDR
	LDR R1, [R0]
	
	; --- Checagem SW1 (PB12) -> Oitava 1 ---
	TST R1, #0x1000		; testa bit 12
	BNE check_sw2		; se 1 (nao pressionado), pula
	LDR R2, =ESTADO_OIT
	MOV R3, #0			; Oitava Normal (1a padrao)
	STRH R3, [R2]
	B fim_controles
	
check_sw2
	; --- Checagem SW2 (PB13) -> Oitava 2 ---
	TST R1, #0x2000 ; testa bit 13
	BNE check_sw3
	LDR R2, =ESTADO_OIT
	MOV R3, #1		; oitava mais aguda
	STRH R3, [R2]
	B fim_controles
	
check_sw3
	; --- Checagem SW3 (PB14) -> Aumentar timbre em 50% ---
	TST R1, #0x4000 	; testa o bit 14
	BNE check_sw4
	
	LDR R2, =VALOR_DUTY		
	LDRH R3, [R2] 			; Carrega nosso valor atual
	SUB R3, R3, #5 			; Diminui 5
	CMP R3, #5				; Limite em 5%
	BLT atualiza_duty		; Se for menor que 5 nao salva
	STRH R3, [R2]
	B atualiza_duty
	
	
check_sw4
	; --- Checagem SW4 (PB15) -> Aumentar timbre em 50% ---
	TST R1, #0x8000 		; testa o bit 15
	BNE fim_controles
	
	LDR R2, =VALOR_DUTY		
	LDRH R3, [R2] 			; Carrega nosso valor atual
	ADD R3, R3, #5 			; Aumenta 5
	CMP R3, #95				; Limite em 95%
	BGT atualiza_duty		; Se for maior que 95 nao salva
	STRH R3, [R2]
	B atualiza_duty

atualiza_duty
	; Atualiza o registrador do Timer imediatamente
	LDR R0, =TIM3_CCR3
	STR R3, [R0]
	LDR R0, =0xFFFF

fim_controles
	POP {R3, R2, R1, R0, PC}

        END