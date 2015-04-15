module square(mulout,in,en,clk,reset);//en,clk,reset);//17*5 multiplier,output 21bit

input [15:0]in;//16 bit 2's complement (1 sign bit plus 4 data bits)

input en;
input clk,reset;

output [30:0]mulout;//31bit 2's complement (windowed samples)(1 sign bit plus 20 data bits)

reg  [30:0]mulout;
wire [16:0]boothout1,boothout2,boothout3,boothout4,boothout5,boothout6,boothout7,boothout8;//length(booth)=length(in2)+1
wire [30:0]cout1,cout2,cout3,cout4,cout5,cout6,cout7;
wire [30:0]mulout1,mulout2,mulout3,mulout4,mulout5,mulout6,mulout7;

reg [30:0]a,b;
wire [30:0]sum;
reg state;

//See 5.4.2 Multiplier
 
booth16 booth1(boothout1,{in[1:0],1'b0},in);
booth16 booth2(boothout2,in[3:1],in);
booth16 booth3(boothout3,in[5:3],in);
booth16 booth4(boothout4,in[7:5],in);
booth16 booth5(boothout5,in[9:7],in);
booth16 booth6(boothout6,in[11:9],in);
booth16 booth7(boothout7,in[13:11],in);
booth16 booth8(boothout8,in[15:13],in);

//csa=carry save adder

csa31squ csa31squ1(cout1,mulout1,{13'b0,~boothout1[16],boothout1},
          {11'b0,~boothout2[16],boothout2,2'b0},{9'b0,~boothout3[16],boothout3,4'b0});
          
csa31squ csa31squ2(cout2,mulout2,{7'b0,~boothout4[16],boothout4,6'b0},
          {5'b0,~boothout5[16],boothout5,8'b0},{3'b0,~boothout6[16],boothout6,10'b0});
                    
csa31squ csa31squ3(cout3,mulout3,{1'b0,~boothout7[16],boothout7,12'b0},{boothout8,14'b0},{14'b10101010101011,17'b0});//m=5-->chuoi 101010...1011 chi co (m/2)-1=1 bit 0-->011,so bit 0 them vao cuoi=length(boothout)

          
csa31squ csa31squ4(cout4,mulout4,{cout1[29:0],1'b0},mulout1,{cout2[29:0],1'b0});//hai carry + 1 sum

csa31squ csa31squ5(cout5,mulout5,mulout2,{cout3[29:0],1'b0},mulout3);//hai sum + 1 carry

csa31squ csa31squ6(cout6,mulout6,{cout4[29:0],1'b0},mulout4,{cout5[29:0],1'b0});//hai carry + 1 sum

csa31squ csa31squ7(cout7,mulout7,{cout6[29:0],1'b0},mulout6,mulout5);//1 carry + hai sum


cla31squ cla31squ(sum,a,b);


always @(posedge clk or negedge reset)
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
        a<={cout7[29:0],1'b0};
        b<=mulout7;
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
