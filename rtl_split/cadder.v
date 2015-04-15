module cadder(sumout,overflow,en,in_sel,mul_in,regs_in,rega,regx_in,shift_in,clk,reset);

input [20:0]regs_in;//register for all states
input [20:0]mul_in;//multiplier out, 16bit///////////////////sua [15:0]-->[20:0]
input [20:0]regx_in;//register for mixture complement
input [15:0]rega;//constant
input [20:0]shift_in;
input [1:0]in_sel;
input en;
input clk;
input reset;

output [25:0]sumout;//////////////////////////////sua tu 21bit-->26bit
output overflow;

reg [25:0]sumout;
reg overflow;

wire [25:0]p;
wire [24:0]g;
wire [25:0]carout;
wire [25:0]in1,in2;
wire [25:0]sumtmp;
wire overf;

assign in1=(in_sel==2'b00)?{{5{mul_in[20]}},mul_in}:26'bz;
assign in1=(in_sel==2'b01)?{{5{mul_in[20]}},mul_in}:26'bz;
assign in1=(in_sel==2'b10)?{{10{rega[15]}},rega}:26'bz;
assign in1=(in_sel==2'b11)?{{5{regx_in[20]}},regx_in}:26'bz;

assign in2=(in_sel==2'b00)?{{5{regs_in[20]}},regs_in}:26'bz;
assign in2=(in_sel==2'b01)?sumout:26'bz;
assign in2=(in_sel==2'b10)?sumout:26'bz;
assign in2=(in_sel==2'b11)?{{5{shift_in[20]}},shift_in}:26'bz;

assign p=in1^in2;
assign g=in1[24:0]&in2[24:0];

assign carout[0]=0;
assign carout[25:1]=g[24:0]|p[24:0]&carout[24:0];
assign sumtmp=p^carout;

assign overf=~(in1[25]^in2[25])&(in1[25]^sumtmp[25]);

always@(posedge clk or negedge reset)
begin
if(reset==0)
	begin
		sumout<=0;
		overflow<=0;
	end
else
	begin
		if(en==1)
		begin
			sumout<=sumtmp;
			overflow<=overf;
		end
	end
end
endmodule
