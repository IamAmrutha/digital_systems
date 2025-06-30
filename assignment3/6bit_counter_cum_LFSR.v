module th_3 (
input clk ,
input reset ,
input enable ,
input mode ,
input dir ,
input load ,
input [5:0] load_value ,
output reg [5:0] out ,
output reg overflow ,
output reg err_flag ,
output reg feedback
);
always @(posedge clk or posedge reset) begin 
if (reset) begin
	out <= 6’b000001; 
	overflow <= 0; 
	err_flag <= 0;
end 
else if (enable) begin 
	if (load) begin
		out <= load_value;
 		overflow <= 0;
 		err_flag <= (mode && (load_value == 6’b000000)) ? 1 : 0;
	end else begin
 		if (mode == 0) begin 
			// Counter Mode
			if (dir) begin
				if (out == 6’b111111) begin
					out <= 6’b000000;
					overflow <= 1; 
				end else begin
					out <= out + 1;
					overflow <= 0; 
				end
			end else begin
 				if (out == 6’b000000) begin
					out <= 6’b111111; 
		 	 		overflow <= 1;	
				 end else begin
 					out <= out - 1; 
					overflow <= 0;
				end
			end
		end else begin
			// LFSR Mode
			feedback = out [5] ^ out [4]; 
			out <= {out[4:0], feedback}; 
			overflow <= 0;
			end
		end
	end
end 
endmodule
Testbench Code


module th_3_tb;
reg clk, reset, enable, mode, dir, load; reg [5:0] load_value;
wire [5:0] out;
wire overflow , err_flag , feedback;
th_3 uut ( .clk(clk),
 	.reset(reset), 
	.enable(enable), 
	.mode(mode),
 	.dir(dir),
 	.load(load), 
	.load_value(load_value), 
	.out(out), 
	.overflow(overflow), 
	.err_flag(err_flag)
);
always #5 clk = ~clk;
initial begin 
	clk = 0;
	reset = 1; enable = 0; mode = 0; dir = 1; load = 0; load_value = 6’ b000000;
	#10 reset = 0; enable = 1; dir = 1;
	#60; 
	load = 1; load_value = 6’b111110; 
	#10 load = 0;
	#20; 

	dir = 0; 
	#60;
load = 1; load_value = 6’b101010; #10 load = 0;
	#50;
mode = 1; #100;
load = 1; load_value = 6’b000000; 
	#50 load = 0;
load = 1; load_value = 6’b0000110; #10 load = 0;
	enable = 0;
	#40;
#100 $stop;
 end
endmodule