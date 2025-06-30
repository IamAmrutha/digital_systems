module home assign 1 (
input [7:0] I ,
output reg [2:0] O
);
always @(∗) begin
if (I[7])
O= 3’b111;
else if (I[6])
O= 3’b110;
else if (I[5])
O= 3’b101;
else if (I[4])
O= 3’b100;
else if (I[3])
O= 3’b011;
else if (I[2])
O= 3’b010;
else if (I[1])
O= 3’b001;
else if (I[0])
O= 3’b000;
else
O= 3’b000;
end
endmodule
Testbench Code
module home assign 1 tb ( ) ;
reg [7:0] I;
wire [2:0] O;
home assign 1 uut (
.I(I),
.O(O) );
initial begin
I = 8 ’ b00000000 ; #10;
I = 8 ’ b00000001 ; #10;
I = 8 ’ b00000010 ; #10;
I = 8 ’ b00000100 ; #10;
I = 8 ’ b00001000 ; #10;
I = 8 ’ b00010000 ; #10;
I = 8 ’ b00100000 ; #10;
I = 8 ’ b01000000 ; #10;
I = 8 ’ b10000000 ; #10;
I = 8 ’ b10000101 ; #10;
I = 8 ’ b01010101 ; #10;
I = 8 ’ b11000000 ; #10;
I = 8 ’ b01100010 ; #10;
I = 8 ’ b01001100 ; #10;
I = 8 ’ b00110010 ; #10;
I = 8 ’ b00010010 ; #10;
I = 8 ’ b00001110 ; #10;
I = 8 ’ b00000101 ; #10;
I = 8 ’ b00000011 ; #10;
I = 8 ’ b00000010 ; #10;
I = 8 ’ b00000001 ; #10;
$stop ();
end
endmodule