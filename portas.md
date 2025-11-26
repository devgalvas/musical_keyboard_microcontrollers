# Referência de Hardware e GPIO - Blue Pill (Final + Dados)

## 1. Regras de Configuração (Registradores de Controle)

Cada pino possui 4 bits de configuração (2 para MODE, 2 para CNF).

### Seleção de Registrador

- **GPIOx_CRL (Low):** Configura os pinos **0 ao 7**. (Offset: 0x00)
- **GPIOx_CRH (High):** Configura os pinos **8 ao 15**. (Offset: 0x04)

### Tabela A: Bits MODE (Direção e Frequência)

| MODE[1:0] | Direção     | Frequência Máx. |
| :-------: | :---------- | :-------------- |
|   `00`    | **Entrada** | -               |
|   `01`    | Saída       | 10 MHz          |
|   `10`    | Saída       | 2 MHz           |
|   `11`    | Saída       | 50 MHz          |

### Tabela B: Bits CNF (Configuração Funcional)

#### Se MODE = 00 (Entrada):

| CNF[1:0] | Configuração        | Detalhes                            |
| :------: | :------------------ | :---------------------------------- |
|   `00`   | Analógico           | Entrada de conversor A/D            |
|   `01`   | Floating            | Entrada flutuante (Alta impedância) |
|   `10`   | Pull-up / Pull-down | **Definido pelo ODR** (veja abaixo) |
|   `11`   | Reservado           | -                                   |

#### Se MODE > 00 (Saída):

| CNF[1:0] | Configuração     | Detalhes                                   |
| :------: | :--------------- | :----------------------------------------- |
|   `00`   | Push-Pull        | Propósito Geral (Gera 0 e 1)               |
|   `01`   | Open-Drain       | Dreno Aberto (Precisa de Pull-up externo)  |
|   `10`   | Alt. Function PP | Função Alternada Push-Pull (Ex: UART, SPI) |
|   `11`   | Alt. Function OD | Função Alternada Open-Drain (Ex: I2C)      |

---

## 2. Regras de Dados (ODR e IDR)

Baseado nas imagens dos registradores, aqui está como manipular os dados:

### **GPIOx_ODR (Output Data Register)**

- **Offset:** `0x0C`
- **Acesso:** Leitura e Escrita.
- **Função (se pino for SAÍDA):** Define o nível lógico.
  - Bit `1`: Saída Alta (3.3V).
  - Bit `0`: Saída Baixa (0V).
- **Função (se pino for ENTRADA):** Define o resistor interno.
  - Bit `1`: Ativa resistor **Pull-up**.
  - Bit `0`: Ativa resistor **Pull-down**.

### **GPIOx_IDR (Input Data Register)**

- **Offset:** `0x08`
- **Acesso:** Somente Leitura.
- **Função:** Lê o estado lógico atual do pino.
  - Bit `1`: Tensão Alta detectada.
  - Bit `0`: Tensão Baixa detectada.

---

## 3. Mapeamento Completo (Configuração + Máscaras)

### Legenda de Valores

- **Config (Hex):** Valor para CRL/CRH (`0x3`, `0xB`, `0x8`, `0x0`).
- **Máscara (Hex):** Valor do bit posicional para usar com `ORR`/`BIC` (no ODR) ou `TST` (no IDR).

### **Porta PA (GPIOA)**

**GPIO_CRL (Pinos 0-7)**

| Pino  | Componente    | Config (CRL) | Máscara Bit (IDR/ODR) | Tipo                      |
| :---- | :------------ | :----------: | :-------------------: | :------------------------ |
| `PA0` | **ld1**       |   **0x3**    |      **0x0001**       | Saída GPIO Push-Pull      |
| `PA1` | **ld2**       |   **0x3**    |      **0x0002**       | Saída GPIO Push-Pull      |
| `PA2` | **ld3**       |   **0x3**    |      **0x0004**       | Saída GPIO Push-Pull      |
| `PA3` | **sw8**       |   **0x8**    |      **0x0008**       | Entrada Pull-up/Pull-down |
| `PA4` | **sw9**       |   **0x8**    |      **0x0010**       | Entrada Pull-up/Pull-down |
| `PA5` | **lcd6-led7** |   **0x3**    |      **0x0020**       | Saída GPIO Push-Pull      |
| `PA6` | **lcd5-led6** |   **0x3**    |      **0x0040**       | Saída GPIO Push-Pull      |
| `PA7` | **sw14**      |   **0x8**    |      **0x0080**       | Entrada Pull-up/Pull-down |

**GPIO_CRH (Pinos 8-15)**

| Pino   | Componente      | Config (CRH) | Máscara Bit (IDR/ODR) | Tipo                       |
| :----- | :-------------- | :----------: | :-------------------: | :------------------------- |
| `PA8`  | **lcd4-led5**   |   **0x3**    |      **0x0100**       | Saída GPIO Push-Pull       |
| `PA9`  | **Tx**          |   **0xB**    |      **0x0200**       | Saída Alt. Function (UART) |
| `PA10` | **Rx**          |   **0x4**    |      **0x0400**       | Entrada Floating           |
| `PA11` | **lcd7-led8**   |   **0x3**    |      **0x0800**       | Saída GPIO Push-Pull       |
| `PA12` | **lcd_en**      |   **0x3**    |      **0x1000**       | Saída GPIO Push-Pull       |
| `PA15` | **lcd_rs-led4** |   **0x3**    |      **0x8000**       | Saída GPIO Push-Pull       |

### **Porta PB (GPIOB)**

**GPIO_CRL (Pinos 0-7)**

| Pino  | Componente | Config (CRL) | Máscara Bit (IDR/ODR) | Tipo                        |
| :---- | :--------- | :----------: | :-------------------: | :-------------------------- |
| `PB0` | **bz1**    |   **0xB**    |      **0x0001**       | Saída Alt. Function (PWM)   |
| `PB1` | **pot**    |   **0x0**    |      **0x0002**       | Entrada Analógica           |
| `PB3` | **sw7**    |   **0x8**    |      **0x0008**       | Entrada Pull-up/Pull-down   |
| `PB4` | **sw6**    |   **0x8**    |      **0x0010**       | Entrada Pull-up/Pull-down   |
| `PB5` | **sw5**    |   **0x8**    |      **0x0020**       | Entrada Pull-up/Pull-down   |
| `PB6` | **Scl**    |   **0xF**    |      **0x0040**       | Saída Alt. Open-Drain (I2C) |
| `PB7` | **Sda**    |   **0xF**    |      **0x0080**       | Saída Alt. Open-Drain (I2C) |

**GPIO_CRH (Pinos 8-15)**

| Pino   | Componente | Config (CRH) | Máscara Bit (IDR/ODR) | Tipo                      |
| :----- | :--------- | :----------: | :-------------------: | :------------------------ |
| `PB8`  | **sw10**   |   **0x8**    |      **0x0100**       | Entrada Pull-up/Pull-down |
| `PB9`  | **sw11**   |   **0x8**    |      **0x0200**       | Entrada Pull-up/Pull-down |
| `PB10` | **sw13**   |   **0x8**    |      **0x0400**       | Entrada Pull-up/Pull-down |
| `PB11` | **sw12**   |   **0x8**    |      **0x0800**       | Entrada Pull-up/Pull-down |
| `PB12` | **sw1**    |   **0x8**    |      **0x1000**       | Entrada Pull-up/Pull-down |
| `PB13` | **sw2**    |   **0x8**    |      **0x2000**       | Entrada Pull-up/Pull-down |
| `PB14` | **sw3**    |   **0x8**    |      **0x4000**       | Entrada Pull-up/Pull-down |
| `PB15` | **sw4**    |   **0x8**    |      **0x8000**       | Entrada Pull-up/Pull-down |

### **Porta PC (GPIOC)**

**GPIO_CRH (Pinos 8-15)**

| Pino   | Componente | Config (CRH) | Máscara Bit (IDR/ODR) | Tipo                      |
| :----- | :--------- | :----------: | :-------------------: | :------------------------ |
| `PC13` | **sw17**   |   **0x8**    |      **0x2000**       | Entrada Pull-up/Pull-down |
| `PC14` | **sw16**   |   **0x8**    |      **0x4000**       | Entrada Pull-up/Pull-down |
| `PC15` | **sw15**   |   **0x8**    |      **0x8000**       | Entrada Pull-up/Pull-down |
