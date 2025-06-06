`timescale 1ns / 1ps

module spi_interface (
    // ϵͳ�ӿ�
    input wire clk,           // ϵͳʱ��(20MHz)
    input wire rst_n,         // ��λ�ź�(�͵�ƽ��Ч)
    
    // SPI�ӿ�(��STM32ͨ��)
    input wire spi_sck,       // SPIʱ��
    input wire spi_mosi,      // SPI������������
    output reg spi_cs_n,      // SPIƬѡ(�͵�ƽ��Ч)
    
    // LED������ƽӿ�
    output reg [7:0] row_anode,    // ����������(8��)
    output reg [7:0][2:0] column_cell  // �е�Ԫ�����(8�У�ÿ��R/G/B��ɫ)
);`timescale 1ns / 1ps
module led(
    input clk,          // 系统时钟 (50MHz)
    input rst_n,        // 复位信号（低有效）
    // SPI 接口 (保留 MISO 以便未来扩展)
    input spi_cs,       // 片选（低有效）
    input spi_sck,      // SPI时钟
    input spi_mosi,     // 主机输出（从机输入）
    // LED 控制接口 - 扩展为RGB三色
    output reg [7:0] row_sel,  // 行选通（低有效）
    output reg [23:0] col_data  // 列数据（高有效，8R+8G+8B）
);

// 参数定义
parameter CLK_FREQ = 50_000_000;  // 系统时钟频率（50MHz）
parameter REFRESH_RATE = 100;       // 刷新率（100Hz）
parameter LINE_TIME = (CLK_FREQ / (REFRESH_RATE * 8)) - 1; // 每行扫描时间

// SPI 接收状态机信号 - 扩展移位寄存器位宽
reg [7:0] bit_cnt;        // 位计数器（0-215，因为24*9=216位）
reg [215:0] shift_reg;     // 216位移位寄存器（9字节*24位）
reg [215:0] old_reg;       // 216位寄存器
reg data_valid;            // 数据有效标志（接收完24字节）
reg data_choose;           // 数据选择标志（接收完24字节）
reg [2:0] brightness;      // 亮度等级（0~7）
reg [2:0] saved_brightness; // 保存的亮度值

// 显示控制信号
reg [23:0] line_timer;     // 行扫描计时器
reg [2:0]  row_index;      // 当前扫描行索引（0~7）
reg [15:0] pwm_counter;    // PWM计数器（用于亮度控制）

// SPI 同步寄存器（抗亚稳态）
reg spi_cs_sync, spi_sck_sync, spi_mosi_sync; // 同步后的SPI信号
reg spi_cs_prev, spi_sck_prev;                // 上一拍的同步信号

// 同步信号边沿检测
wire spi_cs_fall = spi_cs_prev && !spi_cs_sync; // 片选下降沿（通信开始）
wire spi_cs_rise = !spi_cs_prev && spi_cs_sync; // 片选上升沿（通信结束）
wire spi_sck_rise = !spi_sck_prev && spi_sck_sync; // SCK上升沿（数据采样点）

// 同步输入信号（两级同步抗亚稳态）
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        {spi_cs_sync, spi_sck_sync, spi_mosi_sync} <= 3'b111; // 初始高电平（片选无效）
        {spi_cs_prev, spi_sck_prev} <= 2'b11;
    end else begin
        // 第一级同步
        spi_cs_sync <= spi_cs;
        spi_sck_sync <= spi_sck;
        spi_mosi_sync <= spi_mosi;
        // 第二级同步（保存上一拍状态）
        spi_cs_prev <= spi_cs_sync;
        spi_sck_prev <= spi_sck_sync;
    end
end

// 亮度值保存
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        saved_brightness <= 3'b000;     // 复位亮度
    end else if (data_valid) begin
        // 在数据有效时保存亮度值
        saved_brightness <= brightness;
    end
end

// SPI 数据接收逻辑 - 保持原有接收逻辑，仅修改位宽
reg [215:0] new_shift;  // 阻塞赋值中间变量
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_reg <= 216'h0;
        old_reg <= 216'h0;
        bit_cnt <= 8'h0;
        data_valid <= 1'b0;
        data_choose <= 1'b0;
        brightness <= 3'b000;
    end else begin
        data_valid <= 1'b0;  // 默认清除有效标志
        
        // 片选下降沿：复位计数器
        if (spi_cs_fall) begin
            bit_cnt <= 8'h0;
            data_choose <= ~data_choose;
        end 
        // 片选有效且SCK上升沿：接收数据
        else if (!spi_cs_sync && spi_sck_rise) begin
            // 使用阻塞赋值计算中间值
            if (data_choose)
                new_shift = {shift_reg[214:0], spi_mosi_sync};
            else
                new_shift = {old_reg[214:0], spi_mosi_sync};
                
            // 使用非阻塞赋值更新寄存器
            if (data_choose)
                shift_reg <= new_shift;
            else
                old_reg <= new_shift;
                
            // 位计数（0-215）
            if (bit_cnt == 8'd215) begin
                bit_cnt <= 8'h0;
                data_valid <= 1'b1;  // 标记数据有效
                brightness <= new_shift[212:210]; // 提取亮度值（保持与原代码相同位置）
            end else begin
                bit_cnt <= bit_cnt + 1;
            end
        end
    end
end

// 显示扫描控制逻辑 - 扩展为RGB三色显示
reg [23:0] current_row_data; // 当前行RGB数据

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        line_timer <= 24'h000000;
        row_index <= 3'b000;
        pwm_counter <= 16'h0000;
        row_sel <= 8'hFF;  // 初始所有行关闭（低有效）
        col_data <= 24'h000000; // 初始列数据为0
    end else begin
        // PWM计数器（控制亮度）
        pwm_counter <= pwm_counter + 1;
        
        // 行扫描计时（控制每行显示时长）
        if (line_timer >= LINE_TIME) begin
            line_timer <= 24'h000000;  // 重置计时器
            row_index <= (row_index == 3'd7) ? 3'd0 : row_index + 1; // 循环扫描
        end else begin
            line_timer <= line_timer + 1; // 未到阈值，继续计时
        end
        
        // 输出行选通信号（低有效，逐行点亮）
        row_sel <= 8'hFF;  // 默认所有行关闭
        row_sel[row_index] <= 1'b0;  // 选中当前行（低有效）
        
        // 根据data_choose选择数据来源
        if (data_choose) begin
            // 从old_reg中提取当前行RGB数据
            case(row_index)
                3'd0: current_row_data <= old_reg[215:192]; // 行0的RGB数据（24位）
                3'd1: current_row_data <= old_reg[191:168]; // 行1
                3'd2: current_row_data <= old_reg[167:144]; // 行2
                3'd3: current_row_data <= old_reg[143:120]; // 行3
                3'd4: current_row_data <= old_reg[119:96];  // 行4
                3'd5: current_row_data <= old_reg[95:72];   // 行5
                3'd6: current_row_data <= old_reg[71:48];   // 行6
                3'd7: current_row_data <= old_reg[47:24];   // 行7
                default: current_row_data <= 24'h000000;
            endcase
        end else begin
            // 从shift_reg中提取当前行RGB数据
            case(row_index)
                3'd0: current_row_data <= shift_reg[215:192]; // 行0
                3'd1: current_row_data <= shift_reg[191:168]; // 行1
                3'd2: current_row_data <= shift_reg[167:144]; // 行2
                3'd3: current_row_data <= shift_reg[143:120]; // 行3
                3'd4: current_row_data <= shift_reg[119:96];  // 行4
                3'd5: current_row_data <= shift_reg[95:72];   // 行5
                3'd6: current_row_data <= shift_reg[71:48];   // 行6
                3'd7: current_row_data <= shift_reg[47:24];   // 行7
                default: current_row_data <= 24'h000000;
            endcase
        end
        
        // 输出列数据（根据亮度控制亮灭时间）
        if (pwm_counter < (saved_brightness * 8192)) begin  // 8192 = 2^13
            col_data <= current_row_data;      // 显示当前行RGB数据
        end else begin
            col_data <= 24'h000000;             // 消隐（灭）
        end
    end
end

// ILA调试逻辑 - 扩展调试信号以匹配新的位宽
//ila_0 myila(
//    .clk(clk),
//    .probe0(rst_n),
//    .probe1(spi_cs),
//    .probe2(spi_sck),
//    .probe3(spi_mosi),
//    .probe4(row_sel),
//    .probe5(col_data),
//    .probe6(bit_cnt),//8位
//    .probe7(data_valid),
//    .probe8(brightness),//3位
//    .probe9(saved_brightness),//3位
//    .probe10(old_reg[215:192]),  // 行0 RGB数据
//    .probe11(old_reg[191:168]),  // 行1
//    .probe12(old_reg[167:144]),  // 行2
//    .probe13(old_reg[143:120]),  // 行3
//    .probe14(old_reg[119:96]),   // 行4
//    .probe15(old_reg[95:72]),    // 行5
//    .probe16(old_reg[71:48]),    // 行6
//    .probe17(old_reg[47:24]),    // 行7
    
//    .probe18(shift_reg[215:192]),  // 行0
//    .probe19(shift_reg[191:168]),  // 行1
//    .probe20(shift_reg[167:144]),  // 行2
//    .probe21(shift_reg[143:120]),  // 行3
//    .probe22(shift_reg[119:96]),   // 行4
//    .probe23(shift_reg[95:72]),    // 行5
//    .probe24(shift_reg[71:48]),    // 行6
//    .probe25(shift_reg[47:24]),    // 行7
//    .probe26(data_choose)
//);

endmodule

    // ״̬��״̬����
    localparam IDLE_STATE       = 3'b000;
    localparam RECEIVE_DATA     = 3'b001;
    localparam PROCESS_DATA     = 3'b010;
    localparam DISPLAY_DATA     = 3'b011;
    localparam WAIT_NEXT_FRAME  = 3'b100;
    
    // �Ĵ�������
    reg [2:0] current_state;    // ��ǰ״̬
    reg [2:0] next_state;       // ��һ״̬
    reg [7:0] bit_counter;      // λ������(0-201)
    reg [23:0] pixel_data;      // �������ص�24λRGB����(8R+8G+8B)
    reg [7:0][7:0][2:0] frame_buffer; // 8x8����֡������(RGB)
    reg [2:0] brightness_r, brightness_g, brightness_b; // ���ȿ���
    reg [7:0] row_counter;      // �м�����
    reg [7:0] column_counter;   // �м�����
    reg data_ready;             // ����׼���ñ�־
    
    // ��һ���̣�ʱ���߼������µ�ǰ״̬
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE_STATE;
            bit_counter <= 8'd0;
            pixel_data <= 24'd0;
            row_counter <= 8'd0;
            column_counter <= 8'd0;
            data_ready <= 1'b0;
            spi_cs_n <= 1'b1; // ��ʼʱƬѡ��Ч
        end else begin
            current_state <= next_state;
            
            // ����״̬��״̬���¿����ź�
            case (current_state)
                IDLE_STATE: begin
                    spi_cs_n <= 1'b1; // ����Ƭѡ��Ч
                end
                
                RECEIVE_DATA: begin
                    // ���ݽ��չ����б���Ƭѡ��Ч
                    spi_cs_n <= 1'b0;
                end
                
                PROCESS_DATA: begin
                    // ���ݴ���ʱ����Ƭѡ��Ч
                    spi_cs_n <= 1'b0;
                end
                
                DISPLAY_DATA: begin
                    // ������ʾʱ����Ƭѡ��Ч
                    spi_cs_n <= 1'b0;
                end
                
                WAIT_NEXT_FRAME: begin
                    // �ȴ���һ֡ʱ�ͷ�Ƭѡ
                    spi_cs_n <= 1'b1;
                end
                
                default: begin
                    spi_cs_n <= 1'b1;
                end
            endcase
        end
    end
    
    // �ڶ����̣�����߼���������һ״̬
    always @(*) begin
        case (current_state)
            IDLE_STATE: begin
                if (spi_cs_n == 1'b0) begin // ��⵽Ƭѡ��Ч
                    bit_counter <= 8'd0;
                    next_state = RECEIVE_DATA;
                end else begin
                    next_state = IDLE_STATE;
                end
            end
            
            RECEIVE_DATA: begin
                // ��SCK�����ز�������
                if (spi_sck == 1'b1) begin
                    // ��λ��������(MSB����)
                    pixel_data = {pixel_data[22:0], spi_mosi};
                    bit_counter = bit_counter + 1'b1;
                end
                
                // ������202λ���ݺ���봦��״̬
                if (bit_counter == 8'd201) begin
                    next_state = PROCESS_DATA;
                end else begin
                    next_state = RECEIVE_DATA;
                end
            end
            
            PROCESS_DATA: begin
                // ����202λ������ɺ������ʾ״̬
                next_state = DISPLAY_DATA;
            end
            
            DISPLAY_DATA: begin
                // ɨ����ʾ��8�к����ȴ�״̬
                if (row_counter == 8'd8) begin
                    next_state = WAIT_NEXT_FRAME;
                end else begin
                    next_state = DISPLAY_DATA;
                end
            end
            
            WAIT_NEXT_FRAME: begin
                // �ȴ�STM32������һ֡����
                if (spi_cs_n == 1'b1) begin
                    next_state = IDLE_STATE;
                end else begin
                    next_state = WAIT_NEXT_FRAME;
                end
            end
            
            default: next_state = IDLE_STATE;
        endcase
    end
    
    // ���ݴ�������ʾ�߼�
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_buffer <= 0;
            brightness_r <= 0;
            brightness_g <= 0;
            brightness_b <= 0;
            row_counter <= 0;
            column_counter <= 0;
            data_ready <= 1'b0;
            row_anode <= 0;
            column_cell <= 0;
        end else begin
            case (current_state)
                PROCESS_DATA: begin
                    // ����202λ����
                    // ǰ192λΪ8x8���ص�RGB����(ÿ������24λ)
                    for (row_counter = 0; row_counter < 8; row_counter = row_counter + 1) begin
                        for (column_counter = 0; column_counter < 8; column_counter = column_counter + 1) begin
                            // ÿ������ռ��24λ
                            frame_buffer[row_counter][column_counter][0] <= pixel_data[23:16]; // R
                            frame_buffer[row_counter][column_counter][1] <= pixel_data[15:8];  // G
                            frame_buffer[row_counter][column_counter][2] <= pixel_data[7:0];   // B
                            
                            // ������һ����������
                            pixel_data <= pixel_data - 24'd1;
                        end
                    end
                    
                    // ������9λΪ���ȿ���(3R+3G+3B)
                    brightness_r <= pixel_data[23:21];
                    brightness_g <= pixel_data[20:18];
                    brightness_b <= pixel_data[17:15];
                    
                    data_ready <= 1'b1;
                end
                
                DISPLAY_DATA: begin
                    // ɨ����ʾ8x8����
                    if (data_ready) begin
                        if (row_counter < 8) begin
                            // ���ǰ�У��ر�������
                            row_anode <= 1 << row_counter;
                            
                            // ���õ�ǰ�и��е�RGBֵ
                            for (column_counter = 0; column_counter < 8; column_counter = column_counter + 1) begin
                                // Ӧ�����ȿ���
                                column_cell[column_counter][0] <= (frame_buffer[row_counter][column_counter][0] * brightness_r) >> 3;
                                column_cell[column_counter][1] <= (frame_buffer[row_counter][column_counter][1] * brightness_g) >> 3;
                                column_cell[column_counter][2] <= (frame_buffer[row_counter][column_counter][2] * brightness_b) >> 3;
                            end
                            
                            row_counter <= row_counter + 1;
                        end else begin
                            row_counter <= 8'd0;
                            data_ready <= 1'b0;
                        end
                    end
                end
                
                default: begin
                    // ����״̬���ֵ�ǰֵ
                end
            endcase
        end
    end

endmodule