// *********************************************************************************
// Project Name : I2C Controller
// Email        : 
// Website      : 
// Create Time  : 2019/07/15 
// File Name    : I2C_Controller.v
// Module Name  : I2C_Controller
// Abstract     : 
//	This is the top module of I2C Controller
//
// editor		: sublime text 3
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/07/15    Crazy Cao           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

`include	"i2c_controller.hv"

//`define		SYS_CLK_100M
//`define	SYS_CLK_50M

`ifdef		SYS_CLK_100M
	parameter	SYS_CLK 	100000000;
`endif

module I2C_Controller
(
	input	wire		clk,
	input	wire		reset,
	input	wire[7:0]	ctl,
	output	wire[7:0]   state,
	inout	wire[7:0] 	data,
	inout	wire		scl,
	inout	wire		sda
);

reg	[7:0] 	ctl_reg;
reg [7:0] 	state_reg;
reg [7:0]   receiver_data_reg, transmitter_data_reg;
wire[7:0]	receiver_data, transmitter_data;

//******Switch wire definition*********************
wire		tran_rec_switch;
wire		mast_slav_switch;
//******SCL,SDA wire/reg definition****************
wire 		sda_in, sda_out, scl_in, scl_out;

assign sda_in 	= sda;
assign sda 		= tran_rec_switch ? sda_out : 1'bz;
assign scl_in 	= scl;
assign scl 		= mast_slav_switch ? scl_out : 1'bz;
//*****Data Register Opreation*********************
assign receiver_data 	= receiver_data_reg;
assign transmitter_data = transmitter_data_reg ;
assign receiver_data 	= data;
assign data = tran_rec_switch ? transmitter_data : 8'bz;
//*****State Register Opreation********************
assign state = state_reg;
//*****SCL, SDA Opreation**************************


endmodule