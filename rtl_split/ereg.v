module ereg(in,out,we,clk,reset);

input [38:0]in;//39bit
input we;
input clk;
input reset;

output [38:0]out;//39bit

reg [38:0]out;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(we==1)
      out<=in;
    end
  end
endmodule
