# FPGA-design
一个关于FPGA的LED显示阵列课程设计

## 阅前提醒
*如果想要参考开发过程，可以去翻阅Code and page
*如果想要看最终成果代码，可以翻阅Final Code Pack
*中期报告是report.md, PWM_Report是pwm波仿真报告

## 代码组成
*spi.vs: 将Zynq-AX7020开发板与STM32通信的Verilog代码，写入FPGA中让开发板能够接收stm32的通信，需要遵守SPI通信协议。附：如果想用PC直接通信，可以使用CH340通过Uart协议实现usb转ttl，也可以FPGA与FPGA实现通信。
*led.xdc: 用来用来定义spi.vs中需要输入目标led矩阵的每个变量对应的端口位置，需要阅读开发板的数据手册和目标led矩阵板的数据手册去将端口一一对应。
*Src文件夹: 包含stm32的所有.c文件，另一个Inc文件夹则是包含所有.h文件，需要编写的是main, soft_spi, led_animations，如果无意外，传输SPI协议的端口在stm32上应该是PB12, PB13和PB15.

