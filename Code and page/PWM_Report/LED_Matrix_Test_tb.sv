`timescale 1ns / 1ps

module tb_LED_Matrix_Test();

// 参数定义
parameter p_frequency = 50_000_000;
parameter p_pwm_bits = 8;
parameter p_row_num = 8;
parameter p_column_num = 8;
parameter p_control_num = 3;
parameter CLK_PERIOD = 20; // 50MHz时钟周期为20ns

// 输入信号
reg clk;
reg rst_n;
reg start;
reg w_key_2;
reg w_key_3;
reg w_key_4;

// 输出信号
wire [p_row_num-1:0] w_row_anode;
wire [p_control_num-1:0] w_column_cell [0:p_column_num-1];
wire w_done;

// 方便观察的列信号扁平化
wire [p_control_num * p_column_num - 1:0] w_column_cell_flat;
genvar i;
generate
    for (i = 0; i < p_column_num; i = i + 1) begin
        assign w_column_cell_flat[(i+1)*p_control_num-1 : i*p_control_num] = w_column_cell[i];
    end
endgenerate

// 实例化被测模块
LED_Matrix_Test #(
    .p_frequency(p_frequency),
    .p_pwm_bits(p_pwm_bits),
    .p_row_num(p_row_num),
    .p_column_num(p_column_num),
    .p_control_num(p_control_num)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .w_key_2(w_key_2),
    .w_key_3(w_key_3),
    .w_key_4(w_key_4),
    .w_row_anode(w_row_anode),
    .w_column_cell(w_column_cell),
    .w_done(w_done)
);

// 时钟生成
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// 测试序列
initial begin
    // 初始化
    rst_n = 0;
    start = 0;
    w_key_2 = 1;
    w_key_3 = 1;
    w_key_4 = 1;
    
    // 复位
    #(CLK_PERIOD*2);
    rst_n = 1;
    #(CLK_PERIOD*2);
    
    // 测试单点灯模式
    $display("Testing Single LED mode...");
    w_key_2 = 0; // 选择单点灯模式
    start = 1;
    #CLK_PERIOD;
    start = 0;
    
    // 等待完成
    wait(w_done);
    #(CLK_PERIOD*10);
    
    // 测试行灯模式
    $display("Testing Row LED mode...");
    w_key_2 = 1;
    w_key_3 = 0; // 选择行灯模式
    start = 1;
    #CLK_PERIOD;
    start = 0;
    
    // 等待完成
    wait(w_done);
    #(CLK_PERIOD*10);
    
    // 测试流水灯模式
    $display("Testing Water Light mode...");
    w_key_3 = 1;
    w_key_4 = 0; // 选择流水灯模式
    start = 1;
    #CLK_PERIOD;
    start = 0;
    
    // 等待完成
    wait(w_done);
    #(CLK_PERIOD*10);
    
    // 测试PWM模式
    $display("Testing PWM mode...");
    w_key_2 = 0; 
    w_key_3 = 0; // 同时按下key2和key3选择PWM模式
    w_key_4 = 1;
    start = 1;
    #CLK_PERIOD;
    start = 0;
    
    // PWM模式没有完成标志，运行一段时间后停止
    #5000000; // 运行5ms观察PWM变化
    
    // 结束测试
    $display("All tests completed.");
    $finish;
end

// 监视输出
always @(posedge clk) begin
    if (w_done) begin
        $display("Done signal asserted at time %t", $time);
    end
    
    // 当输出变化时显示
    if (w_row_anode !== 0 || w_column_cell_flat !== 0) begin
        $display("Time %t: Row=0x%h, Columns=0x%h", 
                 $time, w_row_anode, w_column_cell_flat);
    end
end

endmodule