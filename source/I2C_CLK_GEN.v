// *********************************************************************************
// Project Name :  I2C CLK GENERATOR
// Email        : 
// Website      : 
// Create Time  : 2019/07/16 
// File Name    : I2C_CLK_GEN.v
// Module Name  : I2C_CLK_GEN
// Abstract     : THE CLK GENERATOR FOR I2C SCL. THE FREQUENCY/SPEED IS DECIEDED BY I2C_SPEED_CLK_XXX IN THE DEFINITION FILE
// editor		: sublime text 3
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 201//    Crazy Cao           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
module I2C_CLK_GEN
#(
	parameter	SYS_CLK 		= 100000000,
				I2C_SPEED_CLK 	= 100000
)
(
	input	wire		clk,
	input	wire		reset,
	input	wire		enable,
	output	wire		clk_tick
);

localparam 	CLK_DIV = (SYS_CLK/I2C_SPEED_CLK)/10;

reg	[9:0]	tick_cntr;
wire[9:0] 	tick_cntr_next;

assign clk_tick = (tick_cntr == CLK_DIV) ? 1'b1 : 1'b0;
assign tick_cntr_next = (tick_cntr == CLK_DIV) ? 9'd0 : (tick_cntr + 1'b1);

always @(posedge clk, negedge reset) begin
	if(!reset) begin
		tick_cntr 	<= 9'd0;
	end
	else if(enable)
		tick_cntr 	<= tick_cntr_next;
	else
		tick_cntr 	<= tick_cntr;
end

endmodule