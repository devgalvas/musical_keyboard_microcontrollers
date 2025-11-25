# Referência de Hardware e GPIO - Blue Pill

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

## 2. Mapeamento de Pinos com Máscaras de Configuração (HEX) - Corrigido

## Legenda de Valores (Nibble de Configuração)

- **0xB**: Saída Função Alternada (Push-Pull, 50MHz) -> Para LEDs, LCD, Buzzer, UART TX
- **0x8**: Entrada Digital (Pull-up/Pull-down) -> Para Botões (Switches)
- **0x0**: Entrada Analógica -> Para Potenciômetro
- **0xF**: Saída Função Alternada (Open-Drain, 50MHz) -> Para I2C (SCL/SDA)
- **0x4**: Entrada Flutuante -> Para UART RX

---

### **Porta PA (GPIOA)**

**GPIO_CRL (Pinos 0-7)**

- `PA0` - **ld1** : Saída Alt. Function PP 50MHz - **0xB**
- `PA1` - **ld2** : Saída Alt. Function PP 50MHz - **0xB**
- `PA2` - **ld3** : Saída Alt. Function PP 50MHz - **0xB**
- `PA3` - **sw8** : Entrada Pull-up/Pull-down - **0x8**
- `PA4` - **sw9** : Entrada Pull-up/Pull-down - **0x8**
- `PA5` - **lcd6-led7** : Saída Alt. Function PP 50MHz - **0xB**
- `PA6` - **lcd5-led6** : Saída Alt. Function PP 50MHz - **0xB**
- `PA7` - **sw14** : Entrada Pull-up/Pull-down - **0x8**

**GPIO_CRH (Pinos 8-15)**

- `PA8` - **lcd4-led5** : Saída Alt. Function PP 50MHz - **0xB**
- `PA9` - **Tx** : Saída Alt. Function PP 50MHz - **0xB**
- `PA10` - **Rx** : Entrada Floating (ou Pull-up) - **0x4**
- `PA11` - **lcd7-led8** : Saída Alt. Function PP 50MHz - **0xB**
- `PA12` - **lcd_en** : Saída Alt. Function PP 50MHz - **0xB**
- `PA15` - **lcd_rs-led4** : Saída Alt. Function PP 50MHz - **0xB**

### **Porta PB (GPIOB)**

**GPIO_CRL (Pinos 0-7)**

- `PB0` - **bz1** : Saída Alt. Function PP 50MHz - **0xB**
- `PB1` - **pot** : Entrada Analógica - **0x0**
- `PB3` - **sw7** : Entrada Pull-up/Pull-down - **0x8**
- `PB4` - **sw6** : Entrada Pull-up/Pull-down - **0x8**
- `PB5` - **sw5** : Entrada Pull-up/Pull-down - **0x8**
- `PB6` - **Scl** : Saída Alt. Function OD 50MHz - **0xF**
- `PB7` - **Sda** : Saída Alt. Function OD 50MHz - **0xF**

**GPIO_CRH (Pinos 8-15)**

- `PB8` - **sw10** : Entrada Pull-up/Pull-down - **0x8**
- `PB9` - **sw11** : Entrada Pull-up/Pull-down - **0x8**
- `PB10` - **sw13** : Entrada Pull-up/Pull-down - **0x8**
- `PB11` - **sw12** : Entrada Pull-up/Pull-down - **0x8**
- `PB12` - **sw1** : Entrada Pull-up/Pull-down - **0x8**
- `PB13` - **sw2** : Entrada Pull-up/Pull-down - **0x8**
- `PB14` - **sw3** : Entrada Pull-up/Pull-down - **0x8**
- `PB15` - **sw4** : Entrada Pull-up/Pull-down - **0x8**

### **Porta PC (GPIOC)**

**GPIO_CRH (Pinos 8-15)**

- `PC13` - **sw17** : Entrada Pull-up/Pull-down - **0x8**
- `PC14` - **sw16** : Entrada Pull-up/Pull-down - **0x8**
- `PC15` - **sw15** : Entrada Pull-up/Pull-down - **0x8**
