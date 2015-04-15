module csa21win(cout,sumout,in1,in2,in3);
input[20:0]in1,in2,in3;
output[20:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
