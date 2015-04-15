module regf(result,fscore,word_index,en,clear,clk,reset);

output [5:0]result;

input [20:0]fscore;
input [5:0]word_index;
input en,clear;
input clk,reset;

reg [5:0]result;
reg [20:0]data_reg;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		data_reg<=21'b100000;
		result<=0;
	end
	else
	begin
		if(clear==1)
		begin
			/*----reset all the parameters when clear=1---*/
			data_reg<=21'h100000;
			result<=0;
		end
		else
		begin
/*---replace the old word index when the new global cost is higher than the old global cost---*/
			if(en==1)
			begin
			// them (ngay 20/12/2011) dung so sanh cho so am
			 // if (data_reg==21'h100000)
			 //       data_reg<=fscore;
			//else
			// ############################		 
				if(fscore>data_reg)
				begin
					data_reg<=fscore;
					if (word_index>0)
					  result<=word_index-1;
					else
					result<=word_index;
				end
			end
		end
	end
end
endmodule
