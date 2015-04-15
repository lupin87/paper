module muldct(in1,in2,out,en,clk,reset);//16*8

input [15:0]in1;//log(S'nk) from logged power coefficient register (16bit 2's complement)
input [7:0]in2;//cos((k-0.5)p*pi/k) from register (8bit 2's complement)
input en;
input clk,reset;

output [22:0]out;//23bit 2's complement (windowed samples)(1 sign bit plus 20 data bits)

reg  [22:0]out;
wire [16:0]boothout1,boothout2,boothout3,boothout4;
wire [22:0]cout1,cout2,cout3;
wire [22:0]mulout1,mulout2,mulout3;

reg [22:0]a23,b23;
wire [22:0]sum23;
reg state;

//See 5.4.2 Multiplier
 
booth16 booth1(boothout1,{in2[1:0],1'b0},in1);
booth16 booth2(boothout2,in2[3:1],in1);
booth16 booth3(boothout3,in2[5:3],in1);
booth16 booth4(boothout4,in2[7:5],in1);

csa23md csa23md1(cout1,mulout1,{5'b0,~boothout1[16],boothout1},
          {3'b0,~boothout2[16],boothout2,2'b0},
          {1'b0,~boothout3[16],boothout3,4'b0});
csa23md csa23md2(cout2,mulout2,{cout1[21:0],1'b0},mulout1,{boothout4,6'b0});
csa23md csa23md3(cout3,mulout3,{cout2[21:0],1'b0},mulout2,{6'b101011,17'b0});

cla23md cla23md(sum23,a23,b23);

always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    a23<=0;
    b23<=0;
    out<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a23<={cout3[21:0],1'b0};
        b23<=mulout3;
        state<=1;
      end
    end
    1:
    begin
      out<=sum23;//sum23[22] is the signbit
      state<=0;
    end
    endcase
  end
end
endmodule
