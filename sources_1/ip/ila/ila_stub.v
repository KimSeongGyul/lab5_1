// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Fri Aug 18 23:09:20 2023
// Host        : DESKTOP-L934QK4 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/vivado/vsim/lab5_1/lab5_1.srcs/sources_1/ip/ila/ila_stub.v
// Design      : ila
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2017.4" *)
module ila(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[0:0],probe1[0:0],probe2[0:0],probe3[3:0],probe4[3:0],probe5[0:0],probe6[1:0],probe7[0:0]" */;
  input clk;
  input [0:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input [3:0]probe3;
  input [3:0]probe4;
  input [0:0]probe5;
  input [1:0]probe6;
  input [0:0]probe7;
endmodule
