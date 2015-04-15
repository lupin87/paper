module comadd(out1,out2,out3,out4,outr,outi,en,shift,clk,reset);

input [38:0]out1,out2,out3,out4;//39bit 2's complement
input en,shift;
input clk,reset;

output [38:0]outr,outi;//outr,outi: 39bit 2's complement;outr=ac-bd,outi=bc+ad

reg [38:0]outr,outi;
wire [38:0]toutr,touti;

sub39 sub39(toutr,out1,out2);//out1-out2
add39 add39(touti,out3,out4);//out3+out4

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    outr<=0;
    outi<=0;
  end
  else
  begin
    if(en==1)
    begin
      if(shift==1)
      begin
        outr<={{6{toutr[38]}},toutr[38:6]};//nhan ngo vao voi 64 (xu ly so fix-point)
        outi<={{6{touti[38]}},touti[38:6]};//nhan ngo vao voi 64 (xu ly so fix-point)
      end
      else//shift=0;outr=out1-out2,outi=out3+out4
      begin
        outr<=toutr;
        outi<=touti;
      end
    end
  end
end
endmodule
