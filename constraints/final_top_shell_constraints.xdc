## This file is a general .xdc for the Basys3 rev B board for ENGS31/CoSc56
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##====================================================================
## External_Clock_Port
##====================================================================
set_property PACKAGE_PIN W5 [get_ports clk_ext]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk_ext]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_ext]

##====================================================================
## Switch_ports
##====================================================================
## SWITCH 0
set_property PACKAGE_PIN V17 [get_ports {mode_ext}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {mode_ext}]
	
##====================================================================	
## 7 segment display
##====================================================================
set_property PACKAGE_PIN W7 [get_ports {seg_ext_port[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg_ext_port[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg_ext_port[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg_ext_port[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg_ext_port[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg_ext_port[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg_ext_port[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seg_ext_port[6]}]

set_property PACKAGE_PIN V7 [get_ports dp_ext_port]							
	set_property IOSTANDARD LVCMOS33 [get_ports dp_ext_port]

set_property PACKAGE_PIN U2 [get_ports {an_ext_port[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an_ext_port[0]}]
set_property PACKAGE_PIN U4 [get_ports {an_ext_port[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an_ext_port[1]}]
set_property PACKAGE_PIN V4 [get_ports {an_ext_port[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an_ext_port[2]}]
set_property PACKAGE_PIN W4 [get_ports {an_ext_port[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {an_ext_port[3]}]


##====================================================================
## Buttons
##====================================================================
## CENTER BUTTON
#set_property PACKAGE_PIN U18 [get_ports btnC_ext_port]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnC_ext_port]
## UP BUTTON
#set_property PACKAGE_PIN T18 [get_ports btnU_ext_port]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnU_ext_port]
## LEFT BUTTON
set_property PACKAGE_PIN W19 [get_ports left_freq_button_ext]						
	set_property IOSTANDARD LVCMOS33 [get_ports left_freq_button_ext]
## RIGHT BUTTON
set_property PACKAGE_PIN T17 [get_ports right_freq_button_ext]						
	set_property IOSTANDARD LVCMOS33 [get_ports right_freq_button_ext]
## DOWN BUTTON
#set_property PACKAGE_PIN U17 [get_ports btnD_ext_port]						
	#set_property IOSTANDARD LVCMOS33 [get_ports btnD_ext_port]
 
 
 
##====================================================================
## Pmod Header JA
##====================================================================
#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {spi_cs_ext_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_cs_ext_port}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {spi_s_data_ext}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_s_data_ext}]
#Sch name = JA3
#set_property PACKAGE_PIN J2 [get_ports {JA_port[2]}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {JA_port[2]}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {spi_sclk_ext_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_sclk_ext_port}]
##Sch name = JA7
#set_property PACKAGE_PIN H1 [get_ports {new_data_ext}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {new_data_ext}]

##====================================================================
## Pmod Header JB
##====================================================================
##Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {spi_trigger_ext_port}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {spi_trigger_ext_port}]

##====================================================================
## VGA Connector
##====================================================================
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## RED
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN G19 [get_ports {vga_red_ext[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_ext[0]}]
set_property PACKAGE_PIN H19 [get_ports {vga_red_ext[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_ext[1]}]
set_property PACKAGE_PIN J19 [get_ports {vga_red_ext[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_ext[2]}]
set_property PACKAGE_PIN N19 [get_ports {vga_red_ext[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_ext[3]}]
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## BLUE
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN N18 [get_ports {vga_blue_ext[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_ext[0]}]
set_property PACKAGE_PIN L18 [get_ports {vga_blue_ext[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_ext[1]}]
set_property PACKAGE_PIN K18 [get_ports {vga_blue_ext[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_ext[2]}]
set_property PACKAGE_PIN J18 [get_ports {vga_blue_ext[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_ext[3]}]
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## GREEN
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN J17 [get_ports {vga_green_ext[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_ext[0]}]
set_property PACKAGE_PIN H17 [get_ports {vga_green_ext[1]}]			
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_ext[1]}]
set_property PACKAGE_PIN G17 [get_ports {vga_green_ext[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_ext[2]}]
set_property PACKAGE_PIN D17 [get_ports {vga_green_ext[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_ext[3]}]
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Timing
##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set_property PACKAGE_PIN P19 [get_ports H_sync_ext]						
	set_property IOSTANDARD LVCMOS33 [get_ports H_sync_ext]
set_property PACKAGE_PIN R19 [get_ports V_sync_ext]						
	set_property IOSTANDARD LVCMOS33 [get_ports V_sync_ext]
	
##====================================================================
## Implementation Assist
##====================================================================	
## These additional constraints are recommended by Digilent, do not remove!
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]