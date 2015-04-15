module complexm(in1a,in1b,in2c,in2d,out1,out2,out3,out4,en,clk,reset);//complex multiplication

input [30:0]in1a,in1b;//in1a,in1b:input a and b in a+jb from regfft,31bit 2's complement
input [7:0] in2c,in2d;//in2c,in2d:input c and d in c+jd from cfft, 8bit 2's complement
input en;
input clk,reset;

//out1=a*c;out2=b*d;out3=b*c;out4=a*d
output [38:0]out1,out2,out3,out4;

reg [38:0]out1,out2,out3,out4;
wire [37:0]cout1,mulout1,cout2,mulout2,cout3,mulout3,cout4,mulout4;
reg [37:0]rcout1,rmulout1,rcout2,rmulout2,rcout3,rmulout3,rcout4,rmulout4;
wire [37:0]tout1,tout2,tout3,tout4;

reg state;
//ac
multi38_1 multi38_1a(in1a,in2c,cout1,mulout1);
multi38_2 multi38_2a(rcout1,rmulout1,tout1);
//bd
multi38_1 multi38_1b(in1b,in2d,cout2,mulout2);
multi38_2 multi38_2b(rcout2,rmulout2,tout2);
//bc
multi38_1 multi38_1c(in1b,in2c,cout3,mulout3);
multi38_2 multi38_2c(rcout3,rmulout3,tout3);
//ad
multi38_1 multi38_1d(in1a,in2d,cout4,mulout4);
multi38_2 multi38_2d(rcout4,rmulout4,tout4);

always@(posedge clk or negedge reset)
begin
  if(reset==0)
    begin
    state<=0;
    rcout1<=0;
    rmulout1<=0;
    rcout2<=0;
    rmulout2<=0;
    rcout3<=0;
    rmulout3<=0;
    rcout4<=0;
    rmulout4<=0;
    out1<=0;
    out2<=0;
    out3<=0;
    out4<=0;
    end
    else
    begin
      case(state)
      0:
      begin
        if(en==1)
        begin
          rcout1<=cout1;
          rmulout1<=mulout1;
          rcout2<=cout2;
          rmulout2<=mulout2;
          rcout3<=cout3;
          rmulout3<=mulout3;
          rcout4<=cout4;
          rmulout4<=mulout4;
          state<=1;
          end
        end
        1:
        begin
          out1<={tout1[37],tout1};
          out2<={tout2[37],tout2};
          out3<={tout3[37],tout3};
          out4<={tout4[37],tout4};
          state<=0;
        end
        endcase
      end
    end
endmodule
