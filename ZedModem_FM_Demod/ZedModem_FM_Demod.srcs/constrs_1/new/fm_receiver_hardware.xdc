#create_clock -period 20.000 -name clk [get_ports clk]
set_property PACKAGE_PIN R8 [get_ports pwm_audio_0]
set_property IOSTANDARD LVCMOS33 [get_ports pwm_audio_0]