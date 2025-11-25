# Referência de Hardware e GPIO - Blue Pill (Final)

## 1. Regras de Configuração (Registradores)

Cada pino possui 4 bits de configuração (2 para MODE, 2 para CNF).

### Seleção de Registrador

- **GPIOx_CRL (Low):** Configura os pinos **0 ao 7**. (Offset: 0x00)
- **GPIOx_CRH (High):** Configura os pinos **8 ao 15**. (Offset: 0x04)

### Tabela A: Bits MODE (Direção e Frequência)

Define se o pino é entrada ou saída.

| MODE[1:0] | Direção     | Frequência Máx. |
| :-------: | :---------- | :-------------- |
|   `00`    | **Entrada** | -               |
|   `01`    | Saída       | 10 MHz          |
|   `10`    | Saída       | 2 MHz           |
|   `11`    | Saída       | 50 MHz          |

### Tabela B: Bits CNF (Configuração Funcional)

A função destes bits depende do valor de MODE.

#### Se MODE = 00 (Entrada):

| CNF[1:0] | Configuração        | Detalhes                            |
| :------: | :------------------ | :---------------------------------- |
|   `00`   | Analógico           | Entrada de conversor A/D            |
|   `01`   | Floating            | Entrada flutuante (Alta impedância) |
|   `10`   | Pull-up / Pull-down | ODR=1: Pull-up, ODR=0: Pull-down    |
|   `11`   | Reservado           | -                                   |

#### Se MODE > 00 (Saída):

| CNF[1:0] | Configuração     | Detalhes                                       |
| :------: | :--------------- | :--------------------------------------------- |
|   `00`   | Push-Pull        | Propósito Geral (Gera 0 e 1)                   |
|   `01`   | Open-Drain       | Dreno Aberto (Gera 0, precisa de Pull-up ext.) |
|   `10`   | Alt. Function PP | Função Alternada Push-Pull (Ex: UART, SPI)     |
|   `11`   | Alt. Function OD | Função Alternada Open-Drain (Ex: I2C)          |

---

## 2. Mapeamento de Pinos com Máscaras de Configuração (HEX)

### Legenda de Valores (Nibble de Configuração)

- **0x3**: Saída GPIO Comum (Push-Pull, 50MHz) -> **Para LEDs e LCD** (Controle manual por software)
- **0xB**: Saída Função Alternada (Push-Pull, 50MHz) -> **Para Buzzer (PWM) e UART TX**
- **0x8**: Entrada Digital (Pull-up/Pull-down) -> **Para Botões**
- **0x0**: Entrada Analógica -> **Para Potenciômetro**
- **0xF**: Saída Função Alternada (Open-Drain, 50MHz) -> **Para I2C (SCL/SDA)**
- **0x4**: Entrada Flutuante -> **Para UART RX**

---

### **Porta PA (GPIOA)**

**GPIO_CRL (Pinos 0-7)**

| Pino  | Componente    | Config (CRL) | Tipo                      |
| :---- | :------------ | :----------: | :------------------------ |
| `PA0` | **ld1**       |   **0x3**    | Saída GPIO Push-Pull      |
| `PA1` | **ld2**       |   **0x3**    | Saída GPIO Push-Pull      |
| `PA2` | **ld3**       |   **0x3**    | Saída GPIO Push-Pull      |
| `PA3` | **sw8**       |   **0x8**    | Entrada Pull-up/Pull-down |
| `PA4` | **sw9**       |   **0x8**    | Entrada Pull-up/Pull-down |
| `PA5` | **lcd6-led7** |   **0x3**    | Saída GPIO Push-Pull      |
| `PA6` | **lcd5-led6** |   **0x3**    | Saída GPIO Push-Pull      |
| `PA7` | **sw14**      |   **0x8**    | Entrada Pull-up/Pull-down |

**GPIO_CRH (Pinos 8-15)**

| Pino   | Componente      | Config (CRH) | Tipo                       |
| :----- | :-------------- | :----------: | :------------------------- |
| `PA8`  | **lcd4-led5**   |   **0x3**    | Saída GPIO Push-Pull       |
| `PA9`  | **Tx**          |   **0xB**    | Saída Alt. Function (UART) |
| `PA10` | **Rx**          |   **0x4**    | Entrada Floating           |
| `PA11` | **lcd7-led8**   |   **0x3**    | Saída GPIO Push-Pull       |
| `PA12` | **lcd_en**      |   **0x3**    | Saída GPIO Push-Pull       |
| `PA15` | **lcd_rs-led4** |   **0x3**    | Saída GPIO Push-Pull       |

### **Porta PB (GPIOB)**

**GPIO_CRL (Pinos 0-7)**

| Pino  | Componente | Config (CRL) | Tipo                        |
| :---- | :--------- | :----------: | :-------------------------- |
| `PB0` | **bz1**    |   **0xB**    | Saída Alt. Function (PWM)   |
| `PB1` | **pot**    |   **0x0**    | Entrada Analógica           |
| `PB3` | **sw7**    |   **0x8**    | Entrada Pull-up/Pull-down   |
| `PB4` | **sw6**    |   **0x8**    | Entrada Pull-up/Pull-down   |
| `PB5` | **sw5**    |   **0x8**    | Entrada Pull-up/Pull-down   |
| `PB6` | **Scl**    |   **0xF**    | Saída Alt. Open-Drain (I2C) |
| `PB7` | **Sda**    |   **0xF**    | Saída Alt. Open-Drain (I2C) |

**GPIO_CRH (Pinos 8-15)**

| Pino   | Componente | Config (CRH) | Tipo                      |
| :----- | :--------- | :----------: | :------------------------ |
| `PB8`  | **sw10**   |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB9`  | **sw11**   |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB10` | **sw13**   |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB11` | **sw12**   |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB12` | **sw1**    |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB13` | **sw2**    |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB14` | **sw3**    |   **0x8**    | Entrada Pull-up/Pull-down |
| `PB15` | **sw4**    |   **0x8**    | Entrada Pull-up/Pull-down |

### **Porta PC (GPIOC)**

**GPIO_CRH (Pinos 8-15)**

| Pino   | Componente | Config (CRH) | Tipo                      |
| :----- | :--------- | :----------: | :------------------------ |
| `PC13` | **sw17**   |   **0x8**    | Entrada Pull-up/Pull-down |
| `PC14` | **sw16**   |   **0x8**    | Entrada Pull-up/Pull-down |
| `PC15` | **sw15**   |   **0x8**    | Entrada Pull-up/Pull-down |
