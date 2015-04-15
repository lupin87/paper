module sroot(regfftoutr,regfftouti,out,en,clk,reset);// 41bit cla

input [39:0]regfftoutr,regfftouti;
input en,clk,reset;

output [40:0]out;

reg [40:0]out;
wire [40:0]tout;
wire [39:0]inr,ini;
wire [40:0]in1,in2;
wire [41:0]tout1;

assign inr={regfftoutr[39]}?~regfftoutr+1:regfftoutr;//|I|-->absolute values of the real part
assign ini={regfftouti[39]}?~regfftouti+1:regfftouti;//|Q|-->absolute values of the imaginary part
assign in1=(inr>ini)?{1'b0,inr}:{3'b0,inr[39:2]};//max{|I|,|Q|}
assign in2=(inr>ini)?{3'b0,ini[39:2]}:{1'b0,ini};//min{|I|,|Q|}/4

cla41 cla41(tout1,in1,in2);

assign tout=tout1[40:0];
always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(en==1)
      out<=({{6{tout[40]}},tout[40:6]});//chia ket qua khoi tinh bien do cho 64 (giong kq cua Matlab)
  end
end
endmodule
