module booth16(out1,in1,in2);
parameter zee=17'bz;
input [2:0]in1;
input [15:0]in2;
output [16:0]out1;
assign out1=(in1==3'b000)?17'b0:zee;
assign out1=(in1==3'b001)?{in2[15],in2}:zee;
assign out1=(in1==3'b010)?{in2[15],in2}:zee;
assign out1=(in1==3'b011)?{in2[15:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[15:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[15],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[15],in2})+1'b1:zee;
assign out1=(in1==3'b111)?17'b0:zee;
endmodule
