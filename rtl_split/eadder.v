module eadder(sumout,en,new1,sel,mul_in,ereg,clk,reset);

input [30:0]mul_in;//multiplier out,31bit (from square block)
input [38:0]ereg;//ereg for the half frame energy, 39bit 2's complement
input sel;//0:sumout+mul_in,1:sumout+ereg
input new1;//start one subframe
input en;
input clk;
input reset;

output [38:0]sumout;//39bit 2's complement

reg [38:0]sumout;
wire [38:0]a;
wire [38:0]sum;
//reg [1:0]state;

assign a=(sel)?ereg:{8'b0,mul_in};//chen them 8'b0 cho du 39 bits

cla39e cla39e(sum,a,sumout);

always@(posedge clk or negedge reset)
begin
if(reset==0)
begin
  sumout<=0;
end
else
begin
  if(en==1)
  begin
    if(new1==1)//start one subframe
    begin
      sumout<={8'b0,mul_in};
    end
    else //new1=0
    begin
      sumout<=sum;//sumout_new=sumout_old+a (where a=(sel)?ereg:{8'b0,mul_in})
    end
  end
end
end
endmodule
