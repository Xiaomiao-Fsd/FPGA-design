## 时钟信号 (50MHz)
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports clk]

## 复位信号 (连接PL_KEY1)
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33 PULLUP true} [get_ports rst]

## 按键输入 (使用PL板载按键)
# 按键2 - PL_KEY2
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33 PULLUP true} [get_ports key2]

# 按键3 - PL_KEY3
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33 PULLUP true} [get_ports key3]

# 按键4 - PL_KEY4
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33 PULLUP true} [get_ports key4]

## LED行控制信号 (8位)
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports {row[0]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {row[1]}]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports {row[2]}]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33} [get_ports {row[3]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {row[4]}]
set_property -dict {PACKAGE_PIN V9 IOSTANDARD LVCMOS33} [get_ports {row[5]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {row[6]}]
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports {row[7]}]

## RGB列控制信号 (每列3位，共8列)
# 列0 RGB
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {rgb[0][0]}] # R0
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {rgb[0][1]}] # G0
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {rgb[0][2]}] # B0

# 列1 RGB
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {rgb[1][0]}] # R1
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {rgb[1][1]}] # G1
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS33} [get_ports {rgb[1][2]}] # B1

# 列2 RGB
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {rgb[2][0]}] # R2
set_property -dict {PACKAGE_PIN N10 IOSTANDARD LVCMOS33} [get_ports {rgb[2][1]}] # G2
set_property -dict {PACKAGE_PIN N11 IOSTANDARD LVCMOS33} [get_ports {rgb[2][2]}] # B2

# 列3 RGB
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {rgb[3][0]}] # R3
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {rgb[3][1]}] # G3
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS33} [get_ports {rgb[3][2]}] # B3

# 列4 RGB
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {rgb[4][0]}] # R4
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {rgb[4][1]}] # G4
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {rgb[4][2]}] # B4

# 列5 RGB
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {rgb[5][0]}] # R5
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {rgb[5][1]}] # G5
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {rgb[5][2]}] # B5

# 列6 RGB
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {rgb[6][0]}] # R6
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS33} [get_ports {rgb[6][1]}] # G6
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS33} [get_ports {rgb[6][2]}] # B6

# 列7 RGB
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {rgb[7][0]}] # R7
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {rgb[7][1]}] # G7
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {rgb[7][2]}] # B7
