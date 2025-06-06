/* main.c */
#include "main.h"

/* 延时函数，用于精确控制刷新率 */
static void delay_us(uint32_t us) {
    uint32_t start = DWT->CYCCNT;
    uint32_t cycles = us * (SystemCoreClock / 1000000);

    while ((DWT->CYCCNT - start) < cycles);
}

/* 初始化DWT延时函数 */
static void init_delay(void) {
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
    DWT->CYCCNT = 0;
}

int main(void) {
    /* 初始化HAL库 */
    HAL_Init();

    /* 配置系统时钟为72MHz */
    SystemClock_Config();

    /* 初始化延时函数 */
    init_delay();

    /* 初始化软件SPI */
    soft_spi_init();

    /* 定义8x8 LED矩阵缓冲区 */
    static uint32_t led_matrix[8][8];

    /* 初始化LED动画模块 */
    void led_animations_init(void) {
        /* 初始化LED矩阵为黑色 */
        for (uint8_t i = 0; i < 8; i++) {
            for (uint8_t j = 0; j < 8; j++) {
                led_matrix[i][j] = COLOR_BLACK;
            }
        }
    }

    static uint8_t brightness = 5; /* 0-7，7为最亮 */

    /* 设置亮度等级 */
    void set_brightness(uint8_t bright) {
        if (bright <= 7) {
            brightness = bright;
        }
    }


    /* 设置亮度为中等（4/7） */
    set_brightness(2);

    /* 主循环 */
    /* 主循环 */
    while (1) {
        /* 执行彩虹波浪动画 */
        rainbow_wave_animation();

        /* 控制刷新率为100Hz（10ms） */
        delay_us(5);
    }
}


/* 系统时钟配置 */
void SystemClock_Config(void) {
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /* 配置HSI为系统时钟源，分频为4MHz作为PLL输入 */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI_DIV2;  // 修正为HSI分频
    RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
    HAL_RCC_OscConfig(&RCC_OscInitStruct);

    /* 配置系统时钟为72MHz */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                                |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
    HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2);
}


