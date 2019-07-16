// *********************************************************************************
// Project Name : I2C Master
// Email        : 
// Website      : 
// Create Time  : 2019/7/16 
// File Name    : I2C_Master.v
// Module Name  : 
// Abstract     : I2C MSTER CONTROLLER
// editor		: sublime text 3
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 201//    Crazy Cao           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
module I2C_Master
(
	input	wire		clk,
	input	wire		reset,
	input	wire		scl_tick,
	inout	wire		sda,
	inout	wire 		scl,
// S[0]:MSL S[1]:BUSY, S[2]:TRA, S[3]:SB, S[4]:ADDR, S[5]:BTF, S[6]:STOPF, S[7]:RXNE, S[8]:TXE,S[9]:AF
	output	wire[9:0]   state,
// data register	
	input	wire[7:0]   data, 
// CTL[0]: ENABLE, CTL[1]:STOP, CTL[2]: START	
	input	wire[7:0]   ctl   
);
localparam 	IDLE 	= 8'B00000000,
			START 	= 8'B00000001,
			ADDR 	= 8'B00000010,
			ADDRACK = 8'B00000100,
			WRDATA 	= 8'B00001000,
			R_ACK   = 8'B00010000,
			RDDATA 	= 8'B00100000,
			T_ACK   = 8'B01000000,
			STOP    = 8'B10000000;
//***I2C ctl, data, state registers*************
reg [7:0] ctl_reg;
reg [7:0] data_reg;
reg [9:0] state_reg;

assign state = state_reg;
//**********************************************
//***sda, scl signal description****************
//**********************************************
wire  sda_in, scl_in;
reg   sda_out_reg, scl_out_reg;
//sda signal assignment
assign sda_in = sda;
assign sda = state_reg[2] ? sda_out_reg : 1'bz;
//scl signal assignment
assign scl_in = scl;
assign scl = state_reg[0] ? scl_out_reg : 1'bz;
//sda, scl edge detect reg*********************
reg [1:0] scl_m, sda_m;
wire 	scl_pos, sda_pos, scl_neg, sda_neg;
assign scl_pos = !scl_m[1] & scl_m[0];
assign scl_neg =  scl_m[1] & !scl_m[0];
assign sda_pos = !sda_m[1] & sda[0];
assign sda_neg =  sda_m[1] & !sda[0];

//****state definition*************************
reg [7:0] current_state, next_state;

//***internal regs and wires*******************
wire 	state_change, scl_change;
reg [4:0] scl_tick_cntr;
wire[4:0] scl_tick_cntr_next;
reg 	  scl_en, scl_tick_en;

assign scl_tick_cntr_next 	= (scl_tick_cntr == 9) ? 4'd0: (scl_tick_cntr + 1'b1);
assign data_change 			= (scl_tick_cntr == 2) ? 1'b1: 1'b0;
assign scl_change 			= ((scl_tick_cntr == 4) || (scl_tick_cntr == 0)) ? 1'b1 : 1'b0; 

//control reg and data reg value assignment****
always@(posedge clk, negedge reset) begin
	if(!reset) begin
		data_reg 	<= 8'd0;
		ctl_reg 	<= 8'd0;
	end
	else begin
		ctl_reg		<= ctl;
		data_reg 	<= data;
	end
end
//edge detect process************************
always@(posedge clk, negedge reset) begin
	if(!reset) begin
		scl_m 	<= 2'd0;
		sda_m 	<= 2'd0;
	end
	else begin
		scl_m 	<= {scl_m[0], scl_in};
		sda_m 	<= {sda_m[0], sda_in};
	end
end
//SCL tick counter process******************
always@(posedge clk, negedge reset) begin
	if(!reset)
		scl_tick_cntr <= 'd0;
	else if(scl_tick_en)
		scl_tick_cntr <= scl_tick_cntr_next;
	else
		scl_tick_cntr <= scl_tick_cntr;
end
//Swiming the scl signal********************
always@(posedge clk,negedge reset) begin
	if(!reset)
		scl_en <= 1'b0;
	else if(scl_en)
		if(scl_change)
			scl_out_reg <= ~scl_out_reg;
		else
			scl_out_reg <= scl_out_reg;
	else
		scl_out_reg <= 1'b1;
end
//State machine process
always@(posedge clk, negedge reset) begin
	if(!reset)
		current_state <= IDLE;
	else
		current_state <= next_state;
end

always@(*) begin
	next_state = current_state;
	case(current_state)
	IDLE: begin
		if(state_reg[3] == 1'b1 && state_reg[1] == 1'b0)
			next_state = START;
		else
			next_state = IDLE;
	end
	START:begin
		if(state_reg[3] == 1)
			next_state = START;
		else 
			next_state = ADDR;
	end
	ADDR:begin
		if(data_cntr == 3'd7 && data_change == 1'b1)
			next_state = ACK;
		else
			next_state = ADDR;
	end
	ADDRACK:begin
		if(data_change == 1'b1)
			if(sda_in = 1) //NACK received
				next_state = IDLE;
			else if(state_reg[4] == 1 && data_reg[0] == 1'b0) //SR-ADDR =1:previous byte is slave addr. Write Opreation
				next_state = WRDATA;
			else if(state_reg[4] == 1 && data_reg[0] == 1'b1)
				next_state = RDDATA;    // read Opreation
			else if(ctl_reg[1] == 1)
				next_state = STOP;
			else 
				next_state = ACK;
		else
			next_state = ACK;
	end
	WRDATA:
	R_ACK:
	RDDATA:
	T_ACK:
	STOP:
	default:
end

endmodule