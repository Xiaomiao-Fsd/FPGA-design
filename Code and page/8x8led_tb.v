module tb_led_matrix();

reg clk;
reg rst_n;  // 低电平有效的复位
reg key2, key3, key4;
wire [7:0] row;
wire [2:0] rgb0, rgb1, rgb2, rgb3, rgb4, rgb5, rgb6, rgb7;

// 实例化控制器
led_matrix_controller uut (
    .clk(clk),
    .rst_n(rst_n),
    .key2(key2),
    .key3(key3),
    .key4(key4),
    .row(row),
    .rgb0(rgb0),
    .rgb1(rgb1),
    .rgb2(rgb2),
    .rgb3(rgb3),
    .rgb4(rgb4),
    .rgb5(rgb5),
    .rgb6(rgb6),
    .rgb7(rgb7)
);

// 时钟生成 (50MHz)
initial begin
    clk = 0;
    forever #10 clk = ~clk; // 20ns周期
end

// 测试序列
initial begin
    // 初始化
    rst_n = 0; // 复位有效（低电平）
    key2 = 1; key3 = 1; key4 = 1;
    #100;
    rst_n = 1; // 释放复位
    #100;
    
    // 测试1: 按键2 (亮一个灯)
    $display("测试1: 按键2 - 亮一个灯");
    key2 = 0;
    #100;
    key2 = 1;
    #200;
    
    // 测试2: 按键3 (亮一排灯)
    $display("测试2: 按键3 - 亮一排灯");
    key3 = 0;
    #100;
    key3 = 1;
    #200;
    
    // 测试3: 按键4 (流水灯)
    $display("测试3: 按键4 - 流水灯");
    key4 = 0;
    #100;
    key4 = 1;
    #1000; // 观察流水效果
    
    // 测试4: 按键2+3 (呼吸灯)
    $display("测试4: 按键2+3 - 呼吸灯");
    key2 = 0; key3 = 0;
    #100;
    key2 = 1; key3 = 1;
    #2000; // 观察呼吸效果
    
    $display("仿真结束");
    $finish;
end

// 监控输出
always @(posedge clk) begin
    $display("Time=%t | State=%d | Row=%b | RGB0=%b", 
             $time, uut.state, row, rgb0);
end

endmodule