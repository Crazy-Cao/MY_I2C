// *********************************************************************************
// Project Name : I2C Slave Receiver
// Email        : 
// Website      : 
// Create Time  : 2019/7/12 
// File Name    : I2C Slave Receiver.v
// Module Name  : I2C_SlaveReceiver
// Abstract     :
// editor		: sublime text 3
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/7/12     Crazy Cao           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module I2C_SlaveReceiver
#(
	parameter	CLOCK_SPD	100000
)
(
	input	wire		clk,
	input 	wire 		reset,
	output  wire [7:0]  dout,
	output  wire [7:0]  status

	inout	wire		sda,
	inout	wire		scl
);

endmodule