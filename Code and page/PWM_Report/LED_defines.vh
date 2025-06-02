`ifndef __LED_DEFINES_VH__
`define __LED_DEFINES_VH__

// ================================================
// 颜色定义（RGB控制）
// ================================================
`define COLOR_OFF  3'b000  // 关闭状态
`define COLOR_RED  3'b100  // 红色
`define COLOR_GREEN 3'b010 // 绿色
`define COLOR_BLUE 3'b001  // 蓝色
`define COLOR_YELLOW 3'b110 // 黄色（红+绿）
`define COLOR_PURPLE 3'b101 // 紫色（红+蓝）
`define COLOR_CYAN  3'b011  // 青色（绿+蓝）
`define COLOR_WHITE 3'b111  // 白色（全亮）

// ================================================
// 状态机状态定义（与主模块匹配）
// ================================================
`define ST_IDLE  4'd0
`define ST_SL    4'd1  // 单灯模式
`define ST_RL    4'd2  // 行灯模式
`define ST_WL    4'd3  // 流水灯模式
`define ST_PWM   4'd4  // PWM模式
`define ST_DONE  4'd5

// ================================================
// 系统参数（可选，可在主模块覆盖）
// ================================================
`ifndef PWM_BITS_DEFAULT
`define PWM_BITS_DEFAULT 8       // 默认PWM分辨率
`endif

`ifndef BRIGHTNESS_STEP_MS
`define BRIGHTNESS_STEP_MS 10    // 默认亮度步进时间(ms)
`endif

`endif // __LED_DEFINES_VH__