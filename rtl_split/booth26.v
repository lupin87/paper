module booth26(out1,in1,in2);
parameter zee=26'bz;
input [2:0]in1;
input [24:0]in2;
output [25:0]out1;
assign out1=(in1==3'b000)?26'b0:zee;
assign out1=(in1==3'b001)?{in2[24],in2}:zee;
assign out1=(in1==3'b010)?{in2[24],in2}:zee;
assign out1=(in1==3'b011)?{in2[24:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[24:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[24],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[24],in2})+1'b1:zee;
assign out1=(in1==3'b111)?26'b0:zee;
endmodule
