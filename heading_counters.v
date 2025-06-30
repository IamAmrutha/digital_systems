module home_assign2 (
 input clk,
 input rst,
 input mode,
 input [3:0] X,
 input [3:0] Y,
 output reg [3:0] count
);				
			
			
always @(posedge clk or posedge rst) 
begin 
if (rst) begin
		count <= (mode) ? Y : X; 
	end
else begin
		if (mode == 0) begin
		if (count < Y) count <= count + 1;
		end 
else begin
	 if (count > X) count <= count - 1;
		end 
end
end 
endmodule 

Testbench Code:
timescale 1ns / 1ps module 
home_assign2_tb(); 
reg clk;
reg rst;
reg mode;
reg [3:0] X;
reg [3:0] Y;
wire [3:0] count;

home_assign2 uut ( 
.clk(clk), 
.rst(rst),
	.mode(mode), 	
.X(X),
 	.Y(Y), 
.count(count)
				
always #5 clk = ~clk; // 10ns clock period
initial begin clk = 0; rst = 1;
mode = 0;
X = 4’b0011; Y = 4’b0110;
#10 rst = 0; #50 mode = 1; #50 $stop;
end 
endmodule