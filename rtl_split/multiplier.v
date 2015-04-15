module multiplier(mulout,in1_1,in2_2,en,clk,reset,in_sel, en, clk, reset);//25*25 multiplier,output 49bit

input [24:0]in1_1;//25 bit 2's complement (1 sign bit plus 24 data bits)
input [24:0]in2_2;//25 bit 2's complement (1 sign bit plus 24 data bits)

input en;
input in_sel;
input clk,reset;

output [48:0]mulout;//49bit 2's complement (1 sign bit plus 48 data bits)

reg  [48:0]mulout;
wire [25:0]boothout1,boothout2,boothout3,boothout4,boothout5,boothout6,boothout7,boothout8,boothout9,boothout10,boothout11,boothout12,boothout13;//length(booth)=length(in2)+1
wire [48:0]cout1,cout2,cout3,cout4,cout5,cout6,cout7,cout8,cout9,cout10,cout11,cout12;
wire [48:0]mulout1,mulout2,mulout3,mulout4,mulout5,mulout6,mulout7,mulout8,mulout9,mulout10,mulout11,mulout12;

reg [48:0]a,b;
wire [48:0]sum;
reg state;
wire [24:0]in1;//25 bit 2's complement (1 sign bit plus 24 data bits)
wire [24:0]in2;//25 bit 2's complement (1 sign bit plus 24 data bits)

//See 5.4.2 Multiplier
assign in1=(in_sel==0)?in1_1:in2_2;
assign in2=(in_sel==0)?in1_1:mulout[29:5];//sua lai [30:15]
 
booth26 booth1(boothout1,{in1[1:0],1'b0},in2);
booth26 booth2(boothout2,in1[3:1],in2);
booth26 booth3(boothout3,in1[5:3],in2);
booth26 booth4(boothout4,in1[7:5],in2);
booth26 booth5(boothout5,in1[9:7],in2);
booth26 booth6(boothout6,in1[11:9],in2);
booth26 booth7(boothout7,in1[13:11],in2);
booth26 booth8(boothout8,in1[15:13],in2);
booth26 booth9(boothout9,in1[17:15],in2);
booth26 booth10(boothout10,in1[19:17],in2);
booth26 booth11(boothout11,in1[21:19],in2);
booth26 booth12(boothout12,in1[23:21],in2);
booth26 booth13(boothout13,{in1[24],in1[24:23]},in2);//so bit vao le (25 bit) --> mo rong sign bit (in1[24])

//csa=carry save adder

csa49squ csa49squ1(cout1,mulout1,{22'b0,~boothout1[25],boothout1},
          {20'b0,~boothout2[25],boothout2,2'b0},{18'b0,~boothout3[25],boothout3,4'b0});
          
csa49squ csa49squ2(cout2,mulout2,{16'b0,~boothout4[25],boothout4,6'b0},
          {14'b0,~boothout5[25],boothout5,8'b0},{12'b0,~boothout6[25],boothout6,10'b0});

csa49squ csa49squ3(cout3,mulout3,{10'b0,~boothout7[25],boothout7,12'b0},
          {8'b0,~boothout8[25],boothout8,14'b0},{6'b0,~boothout9[25],boothout9,16'b0});
          
csa49squ csa49squ4(cout4,mulout4,{4'b0,~boothout10[25],boothout10,18'b0},
          {2'b0,~boothout11[25],boothout11,20'b0},{~boothout12[25],boothout12,22'b0});

csa49squ csa49squ5(cout5,mulout5,{cout1[47:0],1'b0},mulout1,{boothout13[24:0],24'b0});



csa49squ csa49squ6(cout6,mulout6,{cout2[47:0],1'b0},mulout2,{cout3[47:0],1'b0});//hai carry + 1 sum

csa49squ csa49squ7(cout7,mulout7,mulout3,{cout4[47:0],1'b0},mulout4);//hai sum + 1 carry

csa49squ csa49squ8(cout8,mulout8,{cout5[47:0],1'b0},mulout5,{cout6[47:0],1'b0});//hai carry + 1 sum

csa49squ csa49squ9(cout9,mulout9,mulout6,{cout7[47:0],1'b0},mulout7);//hai sum + 1 carry

csa49squ csa49squ10(cout10,mulout10,{cout8[47:0],1'b0},mulout8,{cout9[47:0],1'b0});//hai carry + 1 sum

csa49squ csa49squ11(cout11,mulout11,mulout9,{cout10[47:0],1'b0},mulout10);//hai sum + 1 carry


csa49squ csa49squ12(cout12,mulout12,mulout11,{cout11[47:0],1'b0},{23'b01010101010101010101011,26'b0});


cla49squ cla49squ(sum,a,b);


always @(negedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    mulout<=0;
    a<=0;
    b<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a<={cout12[47:0],1'b0};
        b<=mulout12;
        state<=1;
      end
    end
    1:
    begin
      mulout<=sum;
      state<=0;
    end
    endcase
  end
end

endmodule
