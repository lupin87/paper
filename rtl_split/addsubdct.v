module addsubdct(in,out,en,sub,new1,clk,reset);//muldct sum

input [22:0]in;//23bit from muldct
input en,sub,new1,clk,reset;

output [27:0]out;//23bit sum,23+5=28;them 5bit-->cong 23 lan (K=23)<-->*23-->ket qua them 5 bits
reg [27:0]out;
wire [27:0]tout,tin;//tout=out+/-tin

assign tin={{5{in[22]}},in};

cla28 cla28(tout,sub,out,tin);//sub=1:tout=out-tin;sub=0:tout=out+tin

//new1=0,sub=0:out_new = out_old + in
//new1=0,sub=1:out_new = out_old - in
//new1=1,sub=0:out_new = in
//new1=1,sub=1:out_new = in
always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(en==1)
    begin
      if(new1==1)
      begin
        out<=tin;
      end
      else
      begin
        out<=tout;
      end
    end
  end
end
endmodule
