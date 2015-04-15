module csa32(cout,sumout,in1,in2,in3);
input[31:0]in1,in2,in3;
output[31:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
