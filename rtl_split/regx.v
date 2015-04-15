module regx(kt,xlout,xsout,cadder_out,single,wr_en,clear,clk,reset);

output [20:0]xlout,xsout;
output kt;
input [20:0]cadder_out;
input single;
input wr_en,clear;
input clk,reset;

reg [20:0]xlout,xsout;
reg kt;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		xlout<=21'h100000;
		xsout<=21'h100000;
		kt<=1;
	end
	else
	begin
		if(clear==1)
		begin
			xlout<=21'h100000;//so am nho nhat
			xsout<=21'h100000;
			kt<=1;
		end
		if(wr_en==1)
		begin
		  kt<=0;
			if(single==1)
			begin
				xlout<=cadder_out;
			end
			else
			begin
			   if (xlout==21'h100000)
			    xlout<=cadder_out;
			  else
			    if (xsout==21'h100000)
			      xsout<=cadder_out;
				if(cadder_out>xlout)
				begin
					xlout<= cadder_out;
					xsout<=xlout;
				end
				else
					if(cadder_out>xsout)
						xsout<=cadder_out;
			end
			//xsout<=cadder_out;
		end
	end
end
endmodule
