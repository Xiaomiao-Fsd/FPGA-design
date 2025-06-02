# 时钟约束 - 50MHz系统时钟
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# 复位约束 (低电平有效)
set_property PACKAGE_PIN M15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# 启动信号约束 (需要根据实际硬件分配)
# set_property PACKAGE_PIN <pin> [get_ports start]
# set_property IOSTANDARD LVCMOS33 [get_ports start]

# 按键输入约束
set_property PACKAGE_PIN M14 [get_ports w_key_2]
set_property PACKAGE_PIN L17 [get_ports w_key_3]
set_property PACKAGE_PIN L16 [get_ports w_key_4]
set_property IOSTANDARD LVCMOS33 [get_ports {w_key_2 w_key_3 w_key_4}]

# 行选择信号约束 (阳极)
set_property PACKAGE_PIN N17 [get_ports {w_row_anode[0]}]
set_property PACKAGE_PIN P18 [get_ports {w_row_anode[1]}]
set_property PACKAGE_PIN V16 [get_ports {w_row_anode[2]}]
set_property PACKAGE_PIN W16 [get_ports {w_row_anode[3]}]
set_property PACKAGE_PIN U17 [get_ports {w_row_anode[4]}]
set_property PACKAGE_PIN T16 [get_ports {w_row_anode[5]}]
set_property PACKAGE_PIN U20 [get_ports {w_row_anode[6]}]
set_property PACKAGE_PIN T20 [get_ports {w_row_anode[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {w_row_anode[*]}]

# 列控制信号约束 (RGB阴极)
# 注意：Verilog中的二维数组在XDC中需要展开处理

# 列0 (RGB)
set_property PACKAGE_PIN U15 [get_ports {w_column_cell[0][0]}]
set_property PACKAGE_PIN N20 [get_ports {w_column_cell[0][1]}]
set_property PACKAGE_PIN R14 [get_ports {w_column_cell[0][2]}]

# 列1 (RGB)
set_property PACKAGE_PIN U14 [get_ports {w_column_cell[1][0]}]
set_property PACKAGE_PIN P20 [get_ports {w_column_cell[1][1]}]
set_property PACKAGE_PIN P14 [get_ports {w_column_cell[1][2]}]

# 列2 (RGB)
set_property PACKAGE_PIN P19 [get_ports {w_column_cell[2][0]}]
set_property PACKAGE_PIN V20 [get_ports {w_column_cell[2][1]}]
set_property PACKAGE_PIN U12 [get_ports {w_column_cell[2][2]}]

# 列3 (RGB)
set_property PACKAGE_PIN N18 [get_ports {w_column_cell[3][0]}]
set_property PACKAGE_PIN W20 [get_ports {w_column_cell[3][1]}]
set_property PACKAGE_PIN T12 [get_ports {w_column_cell[3][2]}]

# 列4 (RGB)
set_property PACKAGE_PIN R17 [get_ports {w_column_cell[4][0]}]
set_property PACKAGE_PIN W18 [get_ports {w_column_cell[4][1]}]
set_property PACKAGE_PIN T15 [get_ports {w_column_cell[4][2]}]

# 列5 (RGB)
set_property PACKAGE_PIN R16 [get_ports {w_column_cell[5][0]}]
set_property PACKAGE_PIN W19 [get_ports {w_column_cell[5][1]}]
set_property PACKAGE_PIN T14 [get_ports {w_column_cell[5][2]}]

# 列6 (RGB)
set_property PACKAGE_PIN P15 [get_ports {w_column_cell[6][0]}]
set_property PACKAGE_PIN T17 [get_ports {w_column_cell[6][1]}]
set_property PACKAGE_PIN T11 [get_ports {w_column_cell[6][2]}]

# 列7 (RGB)
set_property PACKAGE_PIN P16 [get_ports {w_column_cell[7][0]}]
set_property PACKAGE_PIN R18 [get_ports {w_column_cell[7][1]}]
set_property PACKAGE_PIN T10 [get_ports {w_column_cell[7][2]}]

# 所有RGB引脚的电气标准
set_property IOSTANDARD LVCMOS33 [get_ports {w_column_cell[*][*]}]

# 完成信号约束 (可选，根据需求分配)
# set_property PACKAGE_PIN <pin> [get_ports w_done]
# set_property IOSTANDARD LVCMOS33 [get_ports w_done]

# 输入输出延迟约束 (根据实际时序要求添加)
# set_input_delay -clock clk -max 2.0 [get_ports {w_key_* rst_n start}]
# set_output_delay -clock clk -max 3.0 [get_ports {w_row_anode[*] w_column_cell[*][*]}]