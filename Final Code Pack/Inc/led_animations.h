/* led_animations.h */
#ifndef LED_ANIMATIONS_H
#define LED_ANIMATIONS_H

#include "stm32f1xx_hal.h"

/* 定义颜色 */
#define COLOR_BLACK       0x000000
#define COLOR_RED         0xFF0000
#define COLOR_GREEN       0x00FF00
#define COLOR_BLUE        0x0000FF
#define COLOR_YELLOW      0xFFFF00
#define COLOR_CYAN        0x00FFFF
#define COLOR_MAGENTA     0xFF00FF
#define COLOR_WHITE       0xFFFFFF

/* 函数声明 */
void led_animations_init(void);
void rainbow_wave_animation(void);
void update_led_matrix(uint32_t *matrix);
void set_brightness(uint8_t brightness);

#endif /* LED_ANIMATIONS_H */
