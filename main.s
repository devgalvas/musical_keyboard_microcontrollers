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

; Registros do ADC1
ADC1_BASE   EQU 0x40012400
ADC1_SR     EQU ADC1_BASE+0x0000
ADC1_DR     EQU ADC1_BASE+0x004C
ADC1_CR2    EQU ADC1_BASE+0x0008
ADC1_SQR3   EQU ADC1_BASE+0x0034
ADC1_SMPR2 EQU ADC1_BASE+0x0010 

;Máscaras de configuração
hab_gpiob_gpioa_afio EQU 0x0D       ;afion_0+iopaen_2+iopben_3=0x0D
JTAG_GPIO            EQU 0x02000000 ;remapeia JTAG para GPIO

; Registros do Timer 2
TIM2_BASE 	EQU 0x40000000
TIM2_CR1  	EQU TIM2_BASE+0x00
TIM2_SR     EQU TIM2_BASE+0x10       
TIM2_PSC    EQU TIM2_BASE+0x28       
TIM2_ARR    EQU TIM2_BASE+0x2C       
TIM2_EGR    EQU TIM2_BASE+0x14      

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
		
		; Configurar PA3, PA4, PA7 como entrada pull-up/pull-down
		LDR R1, =GPIOA_CRL
		LDR R0, [R1]
		LDR R2, =0xF00FF000 ; limpa PA3,4,7
		BIC R0, R0, R2
		LDR R2, =0x80088000 ; entrada pull-up/pull-down (0x8)
		ORR R0, R0, R2
		STR R0, [R1]

		; Ativar pull-ups em PA3, PA4, PA7
		LDR R1, =GPIOA_ODR
		LDR R0, [R1]
		ORR R0, R0, #0x98    ; bits 3, 4 e 7
		STR R0, [R1]

		; Configurar PB3, PB4, PB5 como entrada pull-up/pull-down
		LDR R1, =GPIOB_CRL
		LDR R0, [R1]
		LDR R2, =0x00FFF000 ; limpa PB3,4,5
		BIC R0, R0, R2
		LDR R2, =0x00888000 ; entrada pull-up/pull-down (0x8)
		ORR R0, R0, R2
		STR R0, [R1]

		; Ativar pull-ups em PB3, PB4, PB5
		LDR R1, =GPIOB_ODR
		LDR R0, [R1]
		ORR R0, R0, #0x38    ; bits 3, 4 e 5
		STR R0, [R1]

		; Configurar PB8, PB9, PB10 como entrada pull-up/pull-down
		LDR R1, =GPIOB_CRH
		LDR R0, [R1]
		LDR R2, =0x00000FFF ; limpa PB8,9,10
		BIC R0, R0, R2
		LDR R2, =0x00000888 ; entrada pull-up/pull-down (0x8)
		ORR R0, R0, R2
		STR R0, [R1]

		; Ativar pull-ups em PB8, PB9, PB10
		LDR R1, =GPIOB_ODR
		LDR R0, [R1]
		ORR R0, R0, #0x0700  ; bits 8, 9 e 10
		STR R0, [R1]
		
		; Configurar PB12, PB13, PB14 e PB15 como entrada pull-up/pull-down
		LDR R1, =GPIOB_CRH
		LDR R0, [R1]
		LDR R2, =0xFFFF0000 ; Limpa PB15, 14, 13, 12
		BIC R0, R0, R2
		LDR R2, =0x88880000	; Configurar cada pino como pull-up / pull-down
		ORR R0, R0, R2
		STR R0, [R1]
		
		; Ativar pull-ups em PB12, PB13, PB14 e PB15
		LDR R1, =GPIOB_ODR
		LDR R0, [R1]
		ORR R0, R0, #0xF000  ; bits 12, 13, 14 e 15
		STR R0, [R1]
		
		; Configurar PC13, PC14, PC15 como entrada pull-up/pull-down
		LDR R1, =GPIOC_CRH
		LDR R0, [R1]
		LDR R2, =0xFFF00000 ; limpa PC13,14,15
		BIC R0, R0, R2
		LDR R2, =0x88800000 ; entrada pull-up/pull-down (0x8)
		ORR R0, R0, R2
		STR R0, [R1]

		; Ativar pull-ups em PC13, PC14, PC15
		LDR R1, =GPIOC_ODR	
		LDR R0, [R1]
		ORR R0, R0, #0xE000  ; bits 13, 14 e 15
		STR R0, [R1]
        
        ; Configura PB0 como saída push-pull 50MHz (alternate function)
        ; Para PWM, precisa ser alternate function push-pull
        LDR R1, =GPIOB_CRL
        LDR R0, [R1]
        BIC R0, R0, #0xF
        ORR R0, R0, #0xB        ; 1011 = Alternate function output Push-pull, 50 MHz
        STR R0, [R1]
        
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
		
		; ---------------------------------------------------------
		; 5. CONFIGURAÇÃO ADC1 (Para o Potenciômetro PB1)
		; ---------------------------------------------------------
		; Selecionar canal 9 (PB1) na sequência 1
		LDR R0, =ADC1_SQR3
		MOV R1, #0x09           ; 0x09 = Canal 9
		STR R1, [R0]

		; Ligar o ADC1 (ADON = 1)
		LDR R0, =ADC1_CR2
		LDR R1, [R0]
		ORR R1, R1, #0x01       ; Seta bit ADON
		STR R1, [R0]
		
		; Delay curto para estabilização (sugerido pelo manual)
		MOV R0, #0xFF
delay_adc
		SUBS R0, R0, #1
		BNE delay_adc
        
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
; Sub-rotina: toca_nota  (MODIFICADA)
; Entrada: R4 = índice da nota (0 a 12)
; Saída: nenhuma
; Descrição: Configura o PSC e habilita o Timer 3 para tocar a nota, dependendo da oitava selecionada
;===========================================================

toca_nota
	PUSH {R0-R3, LR}
	
	; Verifica em qual oitava estamos
	LDR R0, =ESTADO_OIT
	LDRH R3, [R0]
	CMP R3, #1				; É a oit 2?
	BEQ carrega_oit2		; Sim, pula pra carregar tabela 2
	
	; --- Caminho da 1a Oitava ---
	; Considerando que ele nao pulou pra 2a
	LDR R0, =PSC_TAB		; R0 aponta pra tab 1
	B configura_psc

carrega_oit2
	; --- Caminho da 2a Oitava ---
	LDR R0, =PSC_TAB_OIT2	; Carrega tabela 2

configura_psc
	
	; 1. R0 agora tem o endereco da tabela correta
	LSL R1, R4, #1 		; 2 * indice (offset)
	LDRH R2, [R0, R1]	; carrega o valor de PSC da tabela escolhida

	; 2. Escreve no Timer
	LDR R0, =TIM3_PSC
	STR R2, [R0]
	
	; 3. Garante que o Duty Cicle atual esta aplicado
	LDR R0, =VALOR_DUTY
	LDRH R3, [R0]
	LDR R0, =TIM3_CCR3
	STR R3, [R0]
	
	; 4. Habilita a saida e timer 
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
	
	; --- Checagem SW1 (Oitava 1) ---
	TST R1, #0x1000		; testa bit 12
	BNE check_sw2		; se 1 (nao pressionado), pula
	
	LDR R2, =ESTADO_OIT
	MOV R3, #0			; Oitava Normal (1a padrao)
	STRH R3, [R2]
	BL delay_tim2
	B fim_controles
	
check_sw2
	; --- Checagem SW2 (PB13) -> Oitava 2 ---
	TST R1, #0x2000 ; testa bit 13
	BNE check_sw3
	
	LDR R2, =ESTADO_OIT
	MOV R3, #1		; oitava mais aguda
	STRH R3, [R2]
	BL delay_tim2
	B fim_controles
	
check_sw3
	; --- Checagem SW3 (PB14) -> Aumentar timbre em 50% ---
	TST R1, #0x4000 	; testa o bit 14
	BNE check_sw4
	
	LDR R2, =VALOR_DUTY		
	LDRH R3, [R2] 			; Carrega nosso valor atual
	SUB R3, R3, #5 			; Diminui 5
	
	CMP R3, #5				; Limite em 5%
	BGE salva_sw3			; Se R3 >= 5, pode salvar
	MOV R3, #5 				; Se não, joga pra 5
	
salva_sw3
	STRH R3, [R2]
	B atualiza_hardware
	
check_sw4
	; --- Checagem SW4 (PB15) -> Aumentar timbre em 50% ---
	TST R1, #0x8000 		; testa o bit 15
	BNE fim_controles		; se nada foi apertado, sai da sub-rotina
	
	LDR R2, =VALOR_DUTY		
	LDRH R3, [R2] 			; Carrega nosso valor atual
	ADD R3, R3, #5 			; Aumenta 5
	
	CMP R3, #95				; Limite em 95%
	BLE salva_sw4			; x <= 95, salva
	MOV R3, #95

salva_sw4
	STRH R3, [R2]

atualiza_hardware
	LDR R0, =TIM3_CCR3
	STR R3, [R0]
	
	BL delay_tim2			; Adiciona delay tim2
	B fim_controles
	
delay_tim2
	PUSH {R0-R2, LR}
	
	; 1. Habilitar o clock do tim2
	LDR R0, =RCC_APB1ENR
	LDR R1, [R0]
	ORR R1, R1, #0x01	; Bit 0 = TIM2 EN
	STR R1, [R0]
	
	; 2. Configurando o PSC para 10KHz
	LDR R0, =TIM2_PSC
	LDR R1, =7199
	STR R1, [R0]
	
	
	; 3. Configurando ARR para 50ms
	LDR R0, =TIM2_ARR
	LDR R1, =499		; 500 Ticks de 0.1ms = 50ms
	STR R1, [R0]
	
	; 4. Limpar flag de update (UIF) antes de começar
	LDR R0, =TIM2_SR
	MOV R1, #0
	STR R1, [R0]
	
	; 5. Habilita Contagem
	LDR R0, =TIM2_CR1
	MOV R1, #0x01		; CEN = 1
	STR R1, [R0]

wait_tim2
	; 6. Loop de espera pelo flag UIF
	LDR R0, =TIM2_SR
	LDR R1, [R0]
	TST R1, #0x01		; Verifica se bit 0 (UIF) subiu
	BEQ wait_tim2
	
	; 7. Desligar timer e limpar a flag
	LDR R0, =TIM2_SR
	MOV R1, #0
	STR R1, [R0]		; Limpa a flag
	
	LDR R0, =TIM2_CR1
	MOV R1, #0			
	STR R1, [R0]		; Desliga timer
	
	POP {R0-R2, PC}
	
	
fim_controles
	POP {R3, R2, R1, R0, PC}

;===========================================================
; Sub-rotina: ler_potenciometro
; Saída: R0 = Valor de 12 bits do ADC (0 a 4095)
;===========================================================
ler_potenciometro
		PUSH {R1, LR}
		
		; Iniciar a conversão (Seta ADON novamente)
		LDR R0, =ADC1_CR2
		LDR R1, [R0]
		ORR R1, R1, #0x01
		STR R1, [R0]

wait_eoc
		; Monitorar o final da conversão (Bit EOC no SR)
		LDR R0, =ADC1_SR
		LDR R1, [R0]
		TST R1, #0x02       ; Testa bit 1 (EOC)
		BEQ wait_eoc        ; Se 0, continua esperando

		; Ler o resultado
		LDR R0, =ADC1_DR
		LDR R0, [R0]        ; O valor convertido vai para R0
		
		POP {R1, PC}

    END
