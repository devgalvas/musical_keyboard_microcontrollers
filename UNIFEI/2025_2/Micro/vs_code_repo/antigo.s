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
        
loop_principal
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
toca_nota
        PUSH {R0-R3, LR}
        
        ; Busca o valor de PSC na tabela
        LDR R0, =PSC_TAB
        LSL R1, R4, #1          ; multiplica índice por 2 (cada entrada tem 2 bytes)
        LDRH R2, [R0, R1]       ; carrega o valor de PSC (halfword)
        
        ; Configura o PSC do Timer 3
        LDR R0, =TIM3_PSC
        STR R2, [R0]
        
        ; Habilita saída do canal 3 (CC3E = 1, bit 8)
        LDR R0, =TIM3_CCER
        MOV R1, #0x0100
        STR R1, [R0]
        
        ; Habilita o Timer 3 (CEN = 1, bit 0 do CR1)
        LDR R0, =TIM3_CR1
        MOV R1, #0x01
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
		
lcd_command
             PUSH {LR,R4,R5,R7,R8,R10,R11}
			 ;nibble mais significativo
             AND R5,R4,#0xF0            ;elimina o nible menos significativo
             LSR R5,R5,#4
             AND R7,R5,#0x08            ;separando o bit 7
             LSL R10,R7,#8
             AND R7,R5,#0x04            ;separando o bit 6
             LSL R7,R7,#3
	     ORR R10,R10,R7
             AND R7,R5,#0x02            ;separando o bit 5
             LSL R7,R7,#5
	     ORR R10,R10,R7
             AND R7,R5,#0x01            ;separando o bit 4
             LSL R7,R7,#8
			 ORR R10,R10,R7
             
			 LDR R11,=LCD_RS
			 BIC  R10,R10,R11
             BIC R10, R10, #LCD_EN
             LDR R8,=GPIOA_ODR
             STR R10,[R8]                ;EN=0, RS=0
             BL  delay                  ;minimo 40ns
             ORR R10,R10, #LCD_EN         ;EN=1, RS=0, RW=0
             STR R10,[R8]
             BL delay                   ;minimo 230ns
             BIC R10,R10,#LCD_EN
             STR R10,[R8]                ;EN=0, RS=0, RW=0
             BL delay                   ;minimo 10ns
			
			;nible menos significativos
             AND R5,R4,#0x0F
             AND R7,R5,#0x08            ;separando o bit 7
             LSL R10,R7,#8
             AND R7,R5,#0x04            ;separando o bit 6
             LSL R7,R7,#3
			 ORR R10,R10,R7
             AND R7,R5,#0x02            ;separando o bit 5
             LSL R7,R7,#5
			 ORR R10,R10,R7
             AND R7,R5,#0x01            ;separando o bit 4
             LSL R7,R7,#8
			 ORR R10,R10,R7
             
			 LDR R11,=LCD_RS
			 BIC R6,R6,R11
             BIC R10, R10, #LCD_EN
             LDR R9,=GPIOA_ODR
             STR R10,[R8]                ;EN=0, RS=1, RW=1
             BL  delay                  ;minimo 40ns
			 BIC  R10, R10, R11
             STR R10,[R8]
             BL  delay                  ;minimo 40ns
             ORR R10,R10, #LCD_EN         ;EN=1, RS=0, RW=0
             STR R10,[R8]
             BL delay                   ;minimo 230ns
             BIC R10,R10,#LCD_EN
             STR R10,[R8]
             BL delay                   ;minimo 10ns
             POP {R11,R10,R8,R7,R5,R4,LR}
             BX  LR

lcd_data
			 PUSH {LR,R4,R5,R7,R8,R10,R11}
             AND R5,R4,#0xF0            ;elimina o nible menos significativo
             LSR R5,R5,#4
             AND R7,R5,#0x08            ;separando o bit 7
             LSL R10,R7,#8
             AND R7,R5,#0x04            ;separando o bit 6
             LSL R7,R7,#3
			 ORR R10,R10,R7
             AND R7,R5,#0x02            ;separando o bit 5
             LSL R7,R7,#5
			 ORR R10,R10,R7
             AND R7,R5,#0x01            ;separando o bit 4
             LSL R7,R7,#8
			 ORR R10,R10,R7

			 LDR R11,=LCD_RS
			 ORR R10, R10, R11
             BIC R10, R10, #LCD_EN
             LDR R8,=GPIOA_ODR
             STR R10,[R8]                ;EN=0, RS=1, RW=1
             BL  delay                  ;minimo 40ns
             ORR R10,R10, #LCD_EN         ;EN=1, RS=0, RW=0
             STR R10,[R8]
             BL delay                   ;minimo 230ns
             BIC R10,R10,#LCD_EN
             STR R10,[R8]
             BL delay                   ;minimo 10ns

             AND R5,R4,#0x0F
             AND R7,R5,#0x08            ;separando o bit 7
             LSL R10,R7,#8
             AND R7,R5,#0x04            ;separando o bit 6
             LSL R7,R7,#3
			 ORR R10,R10,R7
             AND R7,R5,#0x02            ;separando o bit 5
             LSL R7,R7,#5
			 ORR R10,R10,R7
             AND R7,R5,#0x01            ;separando o bit 4
             LSL R7,R7,#8
			 ORR R10,R10,R7
             
			 ORR R10, R10, R11
             BIC R6, R6, #LCD_EN
             LDR R8,=GPIOA_ODR
             STR R10,[R8]                ;EN=0, RS=1, RW=1
             BL  delay                  ;minimo 40ns
             ORR R10,R10, #LCD_EN         ;EN=1, RS=0, RW=0
             STR R10,[R8]
             BL delay                   ;minimo 230ns
             BIC R10,R10,#LCD_EN
             STR R10,[R8]
             BL delay                   ;minimo 10ns
             POP {R11,R10,R8,R7,R5,R4,LR}
			 BX  LR

lcd_init
            PUSH {LR,R4}
            MOV R4,#0x33
            BL   lcd_command
            MOV R4,#0x32
            BL   lcd_command
            MOV R4,#0x20
            BL   lcd_command
            MOV R4,#0x0E
            BL   lcd_command
            MOV R4,#0x01
            BL   lcd_command
            BL   delay
            MOV R4,#0x06
            BL   lcd_command
            POP {R4,LR}
            BX   LR   

;subrotina de delay
delay
        PUSH {LR,R0,R1}
	LDR R0,= 1         ; R0 = 48, modify for different delays
d_L1	LDR R1,= 100000	; R1 = 250, 000 (inner loop count)
d_L2	SUBS R1,R1,#1		
	BNE	d_L2			
	SUBS R0,R0,#1
	BNE d_L1
        POP {R1,R0,LR}
	BX	LR

        END