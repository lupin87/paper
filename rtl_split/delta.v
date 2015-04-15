module delta(out,in,new1,sub,shift,en,clk,reset);

input [15:0]in;//ceptrum from regc
input new1,sub,shift,en,clk,reset;

output [19:0]out;

reg [19:0]out;
wire [19:0]sum,tin;

assign tin={{4{in[15]}},in};

//new1=0,sub=0,shif=0:out_new = out_old + in
//new1=0,sub=1,shif=0:out_new = out_old - in
//new1=1,sub=x,shif=x:out_new = in; x:don't care


//new1=0,sub=0,shif=1:out_new = 2*(out_old + in)
//new1=0,sub=1,shif=1:out_new = 2*(out_old - in)
//new1=1,sub=x,shif=x:out_new = in; x:don't care

cla20d cla20d(sum,sub,out,tin);//sub=1:tout=out-tin;sub=0:tout=out+tin

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
        out<={{4{in[15]}},in};
      end
      else if(shift==1)
      begin
        out<={sum[18:0],1'b0};
      end
      else
      begin
        out<=sum;
      end
    end
  end
end
endmodule
