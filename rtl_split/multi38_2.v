module multi38_2(cout3,mulout3,out);//31*8 multiplier part2
input [37:0]cout3,mulout3;
output [37:0]out;//out 38bit 2's complement

wire [38:0]out1;

cla38cm cla38cm(out1,{cout3[36:0],1'b0},mulout3);
assign out=out1[37:0];//bo MSB bit

endmodule
