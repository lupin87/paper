module log(in,out,en,overf,clk,reset);

input [45:0]in;//energy from eadder or melfft, 46bit
input en;
input clk;
input reset;

output [15:0]out;//out=log_2(in)*512,512=2^9
output overf;

reg [15:0]out;
reg overf;
reg [15:0]a;//2^9*k
reg [8:0]b;
wire [15:0]sum;//2^9*k+9bits (tinh tu bit 1 dau tien)
reg state;

cla16log cla16log(sum,a,{7'b0,b});

always@(posedge clk or negedge reset)//log(in)*512->out
begin
if(reset==0)
begin
  out<=0;
  overf<=0;
  a<=0;
  b<=0;
  state<=0;
end
else
begin
  case(state)
  0://decoding to find k (in one clock cycle)
  begin
    if(en==1)
    begin
      state<=1;
      if(in==0)//the end of the speech
      begin
        overf<=1;//overf=1 to tell the extractor that the end of the speech
      end
      else if(in[44]==1)//k=44, the 45th bit is the sign bit, must be 0
      begin
        a<=16'h5800;//16'h5800=22528=2^9*k=512*44 (k=44)
        b<=in[43:35];//the following 9bits when k is recorded
      end
      else if(in[43]==1)//k=43
      begin
        a<=16'h5600;
        b<=in[42:34];
      end
      else if(in[42]==1)//k=42
      begin
        a<=16'h5400;
        b<=in[41:33];
      end
      else if(in[41]==1)//k=41
      begin
        a<=16'h5200;
        b<=in[40:32];
      end
      else if(in[40]==1)//k=40
      begin
        a<=16'h5000;
        b<=in[39:31];
      end
      else if(in[39]==1)//k=39
      begin
        a<=16'h4e00;
        b<=in[38:30];
      end
      else if(in[38]==1)//k=38
      begin
        a<=16'h4c00;
        b<=in[37:29];
      end
      else if(in[37]==1)//k=37
      begin
        a<=16'h4a00;
        b<=in[36:28];
      end
      else if(in[36]==1)//k=36
      begin
        a<=16'h4800;
        b<=in[35:27];
      end
      else if(in[35]==1)//k=35
      begin
        a<=16'h4600;
        b<=in[34:26];
      end
      else if(in[34]==1)//k=34
      begin
        a<=16'h4400;
        b<=in[33:25];
      end
      else if(in[33]==1)//k=33
      begin
        a<=16'h4200;
        b<=in[32:24];
      end
      else if(in[32]==1)//k=32
      begin
        a<=16'h4000;
        b<=in[31:23];
      end
      else if(in[31]==1)//k=31
      begin
        a<=16'h3e00;
        b<=in[30:22];
      end
      else if(in[30]==1)//k=30
      begin
        a<=16'h3c00;
        b<=in[29:21];
      end
      else if(in[29]==1)//k=29
      begin
        a<=16'h3a00;
        b<=in[28:20];
      end
      else if(in[28]==1)//k=28
      begin
        a<=16'h3800;
        b<=in[27:19];
      end
      else if(in[27]==1)//k=27
      begin
        a<=16'h3600;
        b<=in[26:18];
      end
      else if(in[26]==1)//k=26
      begin
        a<=16'h3400;
        b<=in[25:17];
      end
      else if(in[25]==1)//k=25
      begin
        a<=16'h3200;
        b<=in[24:16];
      end
      else if(in[24]==1)//k=24
      begin
        a<=16'h3000;
        b<=in[23:15];
      end
      else if(in[23]==1)//k=23
      begin
        a<=16'h2e00;
        b<=in[22:14];
      end
      else if(in[22]==1)//k=22
      begin
        a<=16'h2c00;
        b<=in[21:13];
      end
      else if(in[21]==1)//k=21
      begin
        a<=16'h2a00;
        b<=in[20:12];
      end
      else if(in[20]==1)//k=20
      begin
        a<=16'h2800;
        b<=in[19:11];
      end
      else if(in[19]==1)//k=19
      begin
        a<=16'h2600;
        b<=in[18:10];
      end
      else if(in[18]==1)//k=18
      begin
        a<=16'h2400;
        b<=in[17:9];
      end
      else if(in[17]==1)//k=17
      begin
        a<=16'h2200;
        b<=in[16:8];
      end
      else if(in[16]==1)//k=16
      begin
        a<=16'h2000;
        b<=in[15:7];
      end
      else if(in[15]==1)//k=15
      begin
        a<=16'h1e00;
        b<=in[14:6];
      end
      else if(in[14]==1)//k=14
      begin
        a<=16'h1c00;
        b<=in[13:5];
      end
      else if(in[13]==1)//k=13
      begin
        a<=16'h1a00;
        b<=in[12:4];
      end
      else if(in[12]==1)//k=12
      begin
        a<=16'h1800;
        b<=in[11:3];
      end
      else if(in[11]==1)//k=11
      begin
        a<=16'h1600;
        b<=in[10:2];
      end
      else if(in[10]==1)//k=10
      begin
        a<=16'h1400;
        b<=in[9:1];
      end
      else if(in[9]==1)//k=9
      begin
        a<=16'h1200;
        b<=in[8:0];
      end
      else if(in[8]==1)//k=8
      begin
        a<=16'h1000;
        b<={in[7:0],1'b0};
      end
      else if(in[7]==1)//k=7
      begin
        a<=16'he00;
        b<={in[6:0],2'b0};
      end
      else if(in[6]==1)//k=6
      begin
        a<=16'hc00;
        b<={in[5:0],3'b0};
      end
      else if(in[5]==1)//k=5
      begin
        a<=16'ha00;
        b<={in[4:0],4'b0};
      end
      else if(in[4]==1)//k=4
      begin
        a<=16'h800;
        b<={in[3:0],5'b0};
      end
      else if(in[3]==1)//k=3
      begin
        a<=16'h600;
        b<={in[2:0],6'b0};
      end
      else if(in[2]==1)//k=2
      begin
        a<=16'h400;
        b<={in[1:0],7'b0};
      end
      else if(in[1]==1)//k=1
      begin
        a<=16'h200;
        b<={in[0],8'b0};
      end
      else//k=0
      begin
        a<=0;
        b<=0;
      end
    end
  end
  1://adder (sum=a+b) (in one clock cycle)
  begin
    out<=sum;
    overf<=0;
    state<=0;
  end
  endcase
end
end
endmodule
