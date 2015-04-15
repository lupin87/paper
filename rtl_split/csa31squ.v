module csa31squ(cout,sumout,in1,in2,in3);
input[30:0]in1,in2,in3;
output[30:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
