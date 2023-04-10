## This file is a general .xdc for the Nexys4 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
## Clock signal
##Bank = 35, Pin name = IO_L12P_T1_MRCC_35, Sch name = CLK100MHZ
set_property PACKAGE_PIN E3 [get_ports CLK] 
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5.0} 
[get_ports CLK]
set_property CFGBVS Vcco [current_design]
set_property config_voltage 3.3 [current_design]
set_input_delay -clock sys_clk_pin 1.0 [get_ports RST]
set_input_delay -clock sys_clk_pin 1.0 [get_ports BTN]
set_input_delay -clock sys_clk_pin 1.0 [get_ports SEL]
set_input_delay -clock sys_clk_pin 1.0 [get_ports Image]
set_input_delay -clock sys_clk_pin 1.0 [get_ports Neuron]
set_output_delay -clock sys_clk_pin -1.5 [get_ports Spikes_out]
##Buttons
##Bank = 15, Pin name = IO_L11N_T1_SRCC_15, Sch name = BTNC
set_property PACKAGE_PIN E16 [get_ports BTN] 
set_property IOSTANDARD LVCMOS33 [get_ports BTN]
##Bank = 15, Pin name = IO_L14P_T2_SRCC_15, Sch name = BTNU
set_property PACKAGE_PIN F15 [get_ports RST] 
set_property IOSTANDARD LVCMOS33 [get_ports RST]
##Bank = CONFIG, Pin name = IO_L15N_T2_DQS_DOUT_CSO_B_14, Sch name = BTNL
set_property PACKAGE_PIN T16 [get_ports SEL]
set_property IOSTANDARD LVCMOS33 [get_ports SEL]
## Switches
##Bank = 34, Pin name = IO_L21P_T3_DQS_34, Sch name = SW0
set_property PACKAGE_PIN U9 [get_ports {Image[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[0]}]
##Bank = 34, Pin name = IO_25_34, Sch name = SW1
set_property PACKAGE_PIN U8 [get_ports {Image[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[1]}]
##Bank = 34, Pin name = IO_L23P_T3_34, Sch name = SW2
set_property PACKAGE_PIN R7 [get_ports {Image[2]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[2]}]
##Bank = 34, Pin name = IO_L19P_T3_34, Sch name = SW3
set_property PACKAGE_PIN R6 [get_ports {Image[3]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[3]}]
##Bank = 34, Pin name = IO_L19N_T3_VREF_34, Sch name = SW4
set_property PACKAGE_PIN R5 [get_ports {Image[4]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[4]}]
##Bank = 34, Pin name = IO_L20P_T3_34, Sch name = SW5
set_property PACKAGE_PIN V7 [get_ports {Image[5]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[5]}]
##Bank = 34, Pin name = IO_L20N_T3_34, Sch name = SW6
set_property PACKAGE_PIN V6 [get_ports {Image[6]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[6]}]
##Bank = 34, Pin name = IO_L10P_T1_34, Sch name = SW7
set_property PACKAGE_PIN V5 [get_ports {Image[7]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[7]}]
##Bank = 34, Pin name = IO_L8P_T1-34, Sch name = SW8
set_property PACKAGE_PIN U4 [get_ports {Image[8]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[8]}]
##Bank = 34, Pin name = IO_L9N_T1_DQS_34, Sch name = SW9
set_property PACKAGE_PIN V2 [get_ports {Image[9]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Image[9]}]
##Bank = 34, Pin name = IO_L9P_T1_DQS_34, Sch name = SW10
set_property PACKAGE_PIN U2 [get_ports {Neuron[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Neuron[0]}]
##Bank = 34, Pin name = IO_L11N_T1_MRCC_34, Sch name = SW11
set_property PACKAGE_PIN T3 [get_ports {Neuron[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Neuron[1]}]
##Bank = 34, Pin name = IO_L17N_T2_34, Sch name = SW12
set_property PACKAGE_PIN T1 [get_ports {Neuron[2]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Neuron[2]}]
##Bank = 34, Pin name = IO_L11P_T1_SRCC_34, Sch name = SW13
set_property PACKAGE_PIN R3 [get_ports {Neuron[3]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Neuron[3]}]
##Bank = 34, Pin name = IO_L14N_T2_SRCC_34, Sch name = SW14
set_property PACKAGE_PIN P3 [get_ports {Neuron[4]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Neuron[4]}]
##Bank = 34, Pin name = IO_L14P_T2_SRCC_34, Sch name = SW15
set_property PACKAGE_PIN P4 [get_ports {Neuron[5]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Neuron[5]}]
 
##Pmod Header JA
##Bank = 15, Pin name = IO_L1N_T0_AD0N_15, Sch name = JA1
set_property PACKAGE_PIN B13 [get_ports {Spikes_out[0]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Spikes_out[0]}]
##Bank = 15, Pin name = IO_L5N_T0_AD9N_15, Sch name = JA2
set_property PACKAGE_PIN F14 [get_ports {Spikes_out[1]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Spikes_out[1]}]
##Bank = 15, Pin name = IO_L16N_T2_A27_15, Sch name = JA3
set_property PACKAGE_PIN D17 [get_ports {Spikes_out[2]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Spikes_out[2]}]
##Bank = 15, Pin name = IO_L16P_T2_A28_15, Sch name = JA4
set_property PACKAGE_PIN E17 [get_ports {Spikes_out[3]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Spikes_out[3]}]
 
##Pmod Header JB
##Bank = 15, Pin name = IO_L15N_T2_DQS_ADV_B_15, Sch name = JB1
set_property PACKAGE_PIN G14 [get_ports {Spikes_out[4]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Spikes_out[4]}]
##Bank = 14, Pin name = IO_L13P_T2_MRCC_14, Sch name = JB2
set_property PACKAGE_PIN P15 [get_ports {Spikes_out[5]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {Spikes_out[5]}]
