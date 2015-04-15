module addmel(regffteout,regmelout,out,en,sel,new1,clk,reset);

input [40:0]regffteout;//41 bits from Spectrum Register
input [44:0]regmelout;//45 bits from Power Coefficient Register
input sel;//sel=1:out_new=regmel+out_old;sel=0:out_new=regffte+out_old
input en,new1,clk,reset;

output [45:0]out;

reg [45:0]out;
wire [45:0]tout;
wire [45:0]in1,in2;
wire [46:0]tout1;

cla46 cla46(tout1,in1,in2);

assign in1=(sel)?{1'b0,regmelout}:{5'b0,regffteout};//mo rong cho du 46 bits
assign tout=tout1[45:0];
assign in2=out;

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
        out<={5'b0,regffteout};//don't care sel
      end
      else
      begin
        //new1=0&sel=0:out_new=out_old + {5'b0,regffteout}
        //new1=0&sel=1:out_new=out_old + {1'b0,regmelout}
        out<=tout;
      end
    end
  end
end
endmodule
