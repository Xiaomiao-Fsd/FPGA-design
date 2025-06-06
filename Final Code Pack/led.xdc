# ===== 时钟与复位信号约束 =====
create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

set_property PACKAGE_PIN M15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# ===== SPI接口约束 =====
set_property PACKAGE_PIN B19 [get_ports spi_cs]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs]

set_property PACKAGE_PIN A20 [get_ports spi_sck]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sck]

set_property PACKAGE_PIN B20 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]

# ===== 行选通信号约束（8位，对应w_row_anode[7:0]）=====
set_property PACKAGE_PIN N17 [get_ports {row_sel[0]}]
set_property PACKAGE_PIN P18 [get_ports {row_sel[1]}]
set_property PACKAGE_PIN V16 [get_ports {row_sel[2]}]
set_property PACKAGE_PIN W16 [get_ports {row_sel[3]}]
set_property PACKAGE_PIN U17 [get_ports {row_sel[4]}]
set_property PACKAGE_PIN T16 [get_ports {row_sel[5]}]
set_property PACKAGE_PIN U20 [get_ports {row_sel[6]}]
set_property PACKAGE_PIN T20 [get_ports {row_sel[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {row_sel[*]}]

# ===== 列数据信号约束（24位，RGB三色，每色8位）=====
# 红色通道 R[7:0]
set_property PACKAGE_PIN U15 [get_ports {col_data[0]}]
set_property PACKAGE_PIN U14 [get_ports {col_data[1]}]
set_property PACKAGE_PIN P19 [get_ports {col_data[2]}]
set_property PACKAGE_PIN N18 [get_ports {col_data[3]}]
set_property PACKAGE_PIN R17 [get_ports {col_data[4]}]
set_property PACKAGE_PIN R16 [get_ports {col_data[5]}]
set_property PACKAGE_PIN P15 [get_ports {col_data[6]}]
set_property PACKAGE_PIN P16 [get_ports {col_data[7]}]

# 绿色通道 G[7:0]
set_property PACKAGE_PIN N20 [get_ports {col_data[8]}]
set_property PACKAGE_PIN P20 [get_ports {col_data[9]}]
set_property PACKAGE_PIN V20 [get_ports {col_data[10]}]
set_property PACKAGE_PIN W20 [get_ports {col_data[11]}]
set_property PACKAGE_PIN W18 [get_ports {col_data[12]}]
set_property PACKAGE_PIN W19 [get_ports {col_data[13]}]
set_property PACKAGE_PIN T17 [get_ports {col_data[14]}]
set_property PACKAGE_PIN R18 [get_ports {col_data[15]}]

# 蓝色通道 B[7:0]
set_property PACKAGE_PIN R14 [get_ports {col_data[16]}]
set_property PACKAGE_PIN P14 [get_ports {col_data[17]}]
set_property PACKAGE_PIN U12 [get_ports {col_data[18]}]
set_property PACKAGE_PIN T12 [get_ports {col_data[19]}]
set_property PACKAGE_PIN T15 [get_ports {col_data[20]}]
set_property PACKAGE_PIN T14 [get_ports {col_data[21]}]
set_property PACKAGE_PIN T11 [get_ports {col_data[22]}]
set_property PACKAGE_PIN T10 [get_ports {col_data[23]}]

# 将所有列数据端口的IO标准统一为LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports {col_data[*]}]

# ===== I/O时序约束 =====
set_input_delay -clock clk -max 2.0 [get_ports {rst_n spi_cs spi_sck spi_mosi}]
set_output_delay -clock clk -max 3.0 [get_ports {row_sel[*] col_data[*]}]