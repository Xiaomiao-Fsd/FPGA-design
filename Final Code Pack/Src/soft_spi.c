/* soft_spi.c */
#include "soft_spi.h"



/* 软件SPI初始化 */
void soft_spi_init(void) {
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    /* 使能GPIOB时钟 */
    __HAL_RCC_GPIOB_CLK_ENABLE();

    /* 配置SPI引脚为输出 */
    GPIO_InitStruct.Pin = SPI_CS_PIN | SPI_SCK_PIN | SPI_MOSI_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    /* 初始化为高电平 */
    HAL_GPIO_WritePin(SPI_CS_GPIO_PORT, SPI_CS_PIN, GPIO_PIN_SET);
    HAL_GPIO_WritePin(SPI_SCK_GPIO_PORT, SPI_SCK_PIN, GPIO_PIN_SET);
    HAL_GPIO_WritePin(SPI_MOSI_GPIO_PORT, SPI_MOSI_PIN, GPIO_PIN_SET);
}

/* 发送单个字节 */
void soft_spi_send_byte(uint8_t byte) {
    uint8_t i;

    for (i = 0; i < 8; i++) {
        /* SCK拉低 */
        HAL_GPIO_WritePin(SPI_SCK_GPIO_PORT, SPI_SCK_PIN, GPIO_PIN_RESET);

        /* 发送数据位（MSB优先） */
        if (byte & 0x80) {
            HAL_GPIO_WritePin(SPI_MOSI_GPIO_PORT, SPI_MOSI_PIN, GPIO_PIN_SET);
        } else {
            HAL_GPIO_WritePin(SPI_MOSI_GPIO_PORT, SPI_MOSI_PIN, GPIO_PIN_RESET);
        }

        /* 延时，确保时钟周期符合要求 */
        __NOP();
        __NOP();
        __NOP();

        /* SCK拉高，完成一个时钟周期 */
        HAL_GPIO_WritePin(SPI_SCK_GPIO_PORT, SPI_SCK_PIN, GPIO_PIN_SET);

        /* 延时 */
        __NOP();
        __NOP();
        __NOP();

        /* 左移一位，准备下一位 */
        byte <<= 1;
    }
}

/* 发送216位数据（对应FPGA的216位移位寄存器） */
void soft_spi_send_216bit(uint8_t *data) {
    uint16_t i;



    /* 片选拉低，开始通信 */
    HAL_GPIO_WritePin(SPI_CS_GPIO_PORT, SPI_CS_PIN, GPIO_PIN_RESET);

    /* 发送216位数据（27字节，每字节8位） */
    for (i = 0; i < 27; i++) {
        soft_spi_send_byte(data[i]);
    }

    /* 片选拉高，结束通信 */
    HAL_GPIO_WritePin(SPI_CS_GPIO_PORT, SPI_CS_PIN, GPIO_PIN_SET);
}
