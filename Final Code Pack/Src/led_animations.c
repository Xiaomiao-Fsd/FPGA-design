/* led_animations.c */
#include "led_animations.h"
#include "soft_spi.h"
#include <math.h>

/* 定义8x8 LED矩阵缓冲区 */
static uint32_t led_matrix[8][8];
/* 动画状态变量 */
static uint8_t animation_step = 0;
/* 亮度等级 */
static uint8_t brightness = 5; /* 0-7，7为最亮 */

/* 初始化动画模块 */
void led_animations_init(void) {
    /* 初始化LED矩阵为黑色 */
    for (uint8_t i = 0; i < 8; i++) {
        for (uint8_t j = 0; j < 8; j++) {
            led_matrix[i][j] = COLOR_BLACK;
        }
    }
}

/* 设置亮度等级 */
void set_brightness(uint8_t bright) {
    if (bright <= 7) {
        brightness = bright;
    }
}

/* 生成彩虹颜色 */
static uint32_t get_rainbow_color(float position) {
    /* 将位置映射到0-360度的色相环 */
    float hue = fmodf(position, 1.0f) * 360.0f;
    uint8_t r, g, b;

    /* HSV到RGB转换 */
    if (hue < 60) {
        r = 255;
        g = (uint8_t)(hue * 4.25f);
        b = 0;
    } else if (hue < 120) {
        r = (uint8_t)(255 - (hue - 60) * 4.25f);
        g = 255;
        b = 0;
    } else if (hue < 180) {
        r = 0;
        g = 255;
        b = (uint8_t)((hue - 120) * 4.25f);
    } else if (hue < 240) {
        r = 0;
        g = (uint8_t)(255 - (hue - 180) * 4.25f);
        b = 255;
    } else if (hue < 300) {
        r = (uint8_t)((hue - 240) * 4.25f);
        g = 0;
        b = 255;
    } else {
        r = 255;
        g = 0;
        b = (uint8_t)(255 - (hue - 300) * 4.25f);
    }

    /* 返回RGB颜色值 */
    return (r << 16) | (g << 8) | b;
}

/* 彩虹波浪动画效果 */
void rainbow_wave_animation(void) {
    float x, wave, offset;

    /* 动画步长递增 */
    animation_step = (animation_step + 4) % 256;
    offset = (float)animation_step / 128.0f;

    /* 生成彩虹波浪图案 */
    for (uint8_t row = 0; row < 8; row++) {
        for (uint8_t col = 0; col < 8; col++) {
            /* 计算波浪偏移（使用row和col替代x,y，消除警告） */
            wave = sinf((float)col / 4.0f * 2.0f * 3.14159f + offset) * 2.0f;
            /* 计算当前位置的彩虹颜色 */
            float pos = ((float)row + wave) / 8.0f + offset;
            led_matrix[row][col] = get_rainbow_color(pos);
        }
    }

    /* 更新LED矩阵 */
    update_led_matrix((uint32_t *)led_matrix);
}

/* 更新LED矩阵数据到FPGA */
void update_led_matrix(uint32_t *matrix) {
    uint8_t spi_data[27]; /* 216位 = 27字节 */

    /* 构建SPI发送数据 */
    for (uint8_t row = 0; row < 8; row++) {
        for (uint8_t col = 0; col < 8; col++) {
            uint32_t color = matrix[row * 8 + col];
            uint8_t r = (color >> 16) & 0xFF;
            uint8_t g = (color >> 8) & 0xFF;
            uint8_t b = color & 0xFF;
            spi_data[row * 3 + 0] = r;
            spi_data[row * 3 + 1] = g;
            spi_data[row * 3 + 2] = b;
        }
    }

    /* 设置亮度值（正确移位2位，占据第2-4位，对应FPGA的212-210位） */
    spi_data[24] = (spi_data[24] & 0x1F) | ((uint32_t)brightness << 2);
    spi_data[25] = (spi_data[25] & 0x1F) | ((uint32_t)brightness << 2);
    spi_data[26] = (spi_data[26] & 0x1F) | ((uint32_t)brightness << 2);

    /* 通过SPI发送数据 */
    soft_spi_send_216bit(spi_data);
}
