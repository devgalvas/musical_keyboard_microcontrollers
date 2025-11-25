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

- **Config (Hex)**: Valor para bits MODE/CNF em CRL/CRH.
  - `0xB`: Saída Função Alternada (LEDs, LCD, Tx)
  - `0xF`: Saída Open-Drain Alternada (I2C)
  - `0x8`: Entrada Digital (Botões)
  - `0x0`: Entrada Analógica (Potenciômetro)
  - `0x4`: Entrada Flutuante (Rx)
- **Máscara (Hex)**: Valor do bit posicional para ODR ou IDR.

---

### **Porta PA (GPIOA)**

**GPIO_CRL (Pinos 0-7)**
| Pino | Componente | Config (CRL) | Máscara de Bit (ODR/IDR) |
| :--- | :--- | :---: | :---: |
| `PA0` | **ld1** | **0xB** | **0x0001** |
| `PA1` | **ld2** | **0xB** | **0x0002** |
| `PA2` | **ld3** | **0xB** | **0x0004** |
| `PA3` | **sw8** | **0x8** | **0x0008** |
| `PA4` | **sw9** | **0x8** | **0x0010** |
| `PA5` | **lcd6-led7**| **0xB** | **0x0020** |
| `PA6` | **lcd5-led6**| **0xB** | **0x0040** |
| `PA7` | **sw14** | **0x8** | **0x0080** |

**GPIO_CRH (Pinos 8-15)**
| Pino | Componente | Config (CRH) | Máscara de Bit (ODR/IDR) |
| :--- | :--- | :---: | :---: |
| `PA8` | **lcd4-led5**| **0xB** | **0x0100** |
| `PA9` | **Tx** | **0xB** | **0x0200** |
| `PA10`| **Rx** | **0x4** | **0x0400** |
| `PA11`| **lcd7-led8**| **0xB** | **0x0800** |
| `PA12`| **lcd_en** | **0xB** | **0x1000** |
| `PA15`| **lcd_rs-led4**| **0xB**| **0x8000** |

---

### **Porta PB (GPIOB)**

**GPIO_CRL (Pinos 0-7)**
| Pino | Componente | Config (CRL) | Máscara de Bit (ODR/IDR) |
| :--- | :--- | :---: | :---: |
| `PB0` | **bz1** | **0xB** | **0x0001** |
| `PB1` | **pot** | **0x0** | **0x0002** |
| `PB3` | **sw7** | **0x8** | **0x0008** |
| `PB4` | **sw6** | **0x8** | **0x0010** |
| `PB5` | **sw5** | **0x8** | **0x0020** |
| `PB6` | **Scl** | **0xF** | **0x0040** |
| `PB7` | **Sda** | **0xF** | **0x0080** |

**GPIO_CRH (Pinos 8-15)**
| Pino | Componente | Config (CRH) | Máscara de Bit (ODR/IDR) |
| :--- | :--- | :---: | :---: |
| `PB8` | **sw10** | **0x8** | **0x0100** |
| `PB9` | **sw11** | **0x8** | **0x0200** |
| `PB10`| **sw13** | **0x8** | **0x0400** |
| `PB11`| **sw12** | **0x8** | **0x0800** |
| `PB12`| **sw1** | **0x8** | **0x1000** |
| `PB13`| **sw2** | **0x8** | **0x2000** |
| `PB14`| **sw3** | **0x8** | **0x4000** |
| `PB15`| **sw4** | **0x8** | **0x8000** |

---

### **Porta PC (GPIOC)**

**GPIO_CRH (Pinos 8-15)**
| Pino | Componente | Config (CRH) | Máscara de Bit (ODR/IDR) |
| :--- | :--- | :---: | :---: |
| `PC13`| **sw17** | **0x8** | **0x2000** |
| `PC14`| **sw16** | **0x8** | **0x4000** |
| `PC15`| **sw15** | **0x8** | **0x8000** |
