module home assign 1 (
input [3:0] A,
input [3:0] B,
input Cin ,
output [3:0] Sum,
output Cout
);
wire [3:0] G,P; wire [4:0] C;
assign G= A&B; assign P= AˆB;
assign C[0]=Cin;
assign C[1]=G[0]|(P[0]&C[0]);
assign C[2]=G[1]|(P[1]&C[1]);
assign C[3]=G[2]|(P[2]&C[2]);
assign C[4]=G[3]|(P[3]&C[3]);
assign Sum= PˆC[3:0];
assign Cout=C[4];
endmodule
Testbench Code
module home assign 1 tb ( ) ;
reg [3:0] A,B;
reg Cin ;
wire [3:0] Sum; wire Cout ;
home assign 1 uut(
.A(A) ,
.B(B) ,
.Cin ( Cin ) ,
.Sum(Sum) ,
.Cout(Cout)
);
initial begin
A=4’b0000 ;B=4’b0000 ; Cin=0;#10;
A=4’b0001 ;B=4’b0001 ; Cin=0;#10;
A=4’b1111 ;B=4’b1111 ; Cin=0;#10;
A=4’b1010 ;B=4’b0101 ; Cin=1;#10;
A=4’b1100 ;B=4’b1010 ; Cin=1;#10;
A=4’b1110 ;B=4’b0111 ; Cin=0;#10;
A=4’b1110 ;B=4’b0111 ; Cin=0;#10;
A=4’b1110 ;B=4’b0111 ; Cin=1;#10;
A=4’b1111 ;B=4’b1111 ; Cin=1;#10;
A=4’b1001 ;B=4’b1110 ; Cin=1;#10;
A=4’b0011 ;B=4’b1001 ; Cin=0;#10;
A=4’b1101 ;B=4’b0010 ; Cin=0;#10;
A=4’b0011 ;B=4’b1100 ; Cin=1;#10;
A=4’b0110 ;B=4’b1001 ; Cin=1;#10;
end
endmodule