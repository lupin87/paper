module booth17(out1,in1,in2);
parameter zee=18'bz;
input [2:0]in1;
input [16:0]in2;
output [17:0]out1;
assign out1=(in1==3'b000)?18'b0:zee;
assign out1=(in1==3'b001)?{in2[16],in2}:zee;
assign out1=(in1==3'b010)?{in2[16],in2}:zee;
assign out1=(in1==3'b011)?{in2[16:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[16:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[16],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[16],in2})+1'b1:zee;
assign out1=(in1==3'b111)?18'b0:zee;
endmodule
