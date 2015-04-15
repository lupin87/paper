module multi38_1(in1,in2,cout3,mulout3);//31*8 multiplier part1

input [30:0]in1;// 31bit 2's complement
input [7:0]in2;//8bit 2's complement

output [37:0]cout3,mulout3;

wire [31:0]boothout1,boothout2,boothout3,boothout4;
wire [37:0]cout1,cout2;
wire [37:0]mulout1,mulout2;

booth31 booth1(boothout1,{in2[1:0],1'b0},in1);
booth31 booth2(boothout2,in2[3:1],in1);
booth31 booth3(boothout3,in2[5:3],in1);
booth31 booth4(boothout4,in2[7:5],in1);

fulladder38 fulladder1(cout1,mulout1,{5'b0,~boothout1[31],boothout1},
          {3'b0,~boothout2[31],boothout2,2'b0},
          {1'b0,~boothout3[31],boothout3,4'b0});
fulladder38 fulladder2(cout2,mulout2,{cout1[36:0],1'b0},mulout1,{boothout4,6'b0});
fulladder38 fulladder3(cout3,mulout3,{cout2[36:0],1'b0},mulout2,{6'b101011,32'b0});

endmodule
