module window(in2,in1,out,en,clk,reset);//en,clk,reset);//17*5 multiplier,output 21bit

input [4:0]in1;//5 bit 2's complement (hamming window) (1 sign bit plus 4 data bits)
input [16:0]in2;//17 bit 2's complement (preemphasized samples) (1 sign bit plus 15 data bits)
input en;
input clk,reset;

output [20:0]out;//21bit 2's complement (windowed samples)(1 sign bit plus 20 data bits)
reg  [20:0]out;

wire [17:0]boothout1,boothout2,boothout3;//length(booth)=length(in2)+1
wire [20:0]cout1,cout2;
wire [20:0]mulout1,mulout2;

reg [19:0]a20,b20;
wire [19:0]sum20;
reg state;
reg t;

 //See 5.4.2 Multiplier
 
booth17 booth1(boothout1,{in1[1:0],1'b0},in2);//chen them bit 0 vao
booth17 booth2(boothout2,in1[3:1],in2);
booth17 booth3(boothout3,{in1[4],in1[4:3]},in2);//so bit vao le (5 bit) --> mo rong sign bit (in1[4])

//csa=carry save adder

csa21win csa21win1(cout1,mulout1,{2'b0,~boothout1[17],boothout1},
          {~boothout2[17],boothout2,2'b0},{boothout3[16:0],4'b0});
csa21win csa21win2(cout2,mulout2,{cout1[19:0],1'b0},mulout1,{3'b011,18'b0});//m=5-->chuoi 101010...1011 chi co (m/2)-1=1 bit 0-->011,so bit 0 them vao cuoi=length(boothout)


cla20win cla20win(sum20,a20,b20);

always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    a20<=0;
    b20<=0;
    out<=0;
    t<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a20<=cout2[19:0];
        b20<=mulout2[20:1];
        t<=mulout2[0];
        state<=1;
      end
    end
    1:
    begin
      out<={sum20,t};//sum20[19] is the signbit
      state<=0;
    end
    endcase
  end
end
endmodule
