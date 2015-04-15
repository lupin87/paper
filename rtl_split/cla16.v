module cla16(sumout,overf,in1,in2,en,clk,reset);

/*-------carry look ahead adder--------*/

input [15:0]in1;
input [15:0]in2;
input en;
input clk;
input reset;

output [15:0]sumout;
output reg overf;

reg [15:0]sumout;
wire [15:0]p;
wire [14:0]g;
wire [15:0]carout;
wire [15:0]sumtmp;

assign p=in1^in2;
assign g=in1[14:0]&in2[14:0];
assign carout[0]=0;
assign carout[15:1]=g[14:0]|p[14:0]&carout[14:0];
assign sumtmp=p[15:0]^carout[15:0];
//assign overf=~(in1[15]^in2[15])&(in1[15]^sumtmp[15]);

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		sumout<=0;
		overf<=0;//them
	end
	else
	begin
		if(en==1)
		begin
			sumout<=sumtmp;
			overf<=~(in1[15]^in2[15])&(in1[15]^sumtmp[15]);//them
		end
	end
end
endmodule
