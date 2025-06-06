/* soft_spi.h */
#ifndef SOFT_SPI_H
#define SOFT_SPI_H

#include "stm32f1xx_hal.h"

/* SPI引脚定义 - 对应FPGA的B12, B13, B15 */
#define SPI_CS_PIN        GPIO_PIN_12
#define SPI_CS_GPIO_PORT  GPIOB
#define SPI_SCK_PIN       GPIO_PIN_13
#define SPI_SCK_GPIO_PORT GPIOB
#define SPI_MOSI_PIN      GPIO_PIN_15
#define SPI_MOSI_GPIO_PORT GPIOB

/* 函数声明 */
void soft_spi_init(void);
void soft_spi_send_216bit(uint8_t *data);
void soft_spi_send_byte(uint8_t byte);

#endif /* SOFT_SPI_H */
