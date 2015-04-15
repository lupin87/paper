module regs(data_out,data_in,wr_en,in_sel,intmp,out_sel,
			compare,com_sel,clear,clk,reset);
			
output [20:0]data_out;

input [20:0]data_in;
input wr_en;
input [3:0]in_sel;
input intmp;
input [3:0]out_sel;
input compare;
input [3:0]com_sel;
input clear;
input clk,reset;

reg [20:0]data_reg1,data_reg2,data_reg3,data_reg4,data_reg5,data_reg6,data_reg7,data_reg8,data_reg9,
		data_reg10,data_reg11,data_reg12,data_reg13,data_reg14,data_reg15,data_reg16;
reg [20:0]data_reg_tmp;

/*-----data_reg{1-16} store the costwithout changing state,data_reg_tmp store the with changing state----*/

reg [20:0]data_out;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		data_reg1<=0;
		data_reg2<=0;
		data_reg3<=0;
		data_reg4<=0;
		data_reg5<=0;
		data_reg6<=0;
		data_reg7<=0;
		data_reg8<=0;
		data_reg9<=0;
		data_reg10<=0;
		data_reg11<=0;
		data_reg12<=0;
		data_reg13<=0;
		data_reg14<=0;
		data_reg15<=0;
		data_reg16<=0;
		
		data_reg_tmp<=0;
		data_out<=0;
	end
	else
	begin
		if(clear==1)
		begin
			data_reg1<=0;
			data_reg2<=0;
			data_reg3<=0;
			data_reg4<=0;
			data_reg5<=0;
			data_reg6<=0;
			data_reg7<=0;
			data_reg8<=0;
			data_reg9<=0;
			data_reg10<=0;
			data_reg11<=0;
			data_reg12<=0;
			data_reg13<=0;
			data_reg14<=0;
			data_reg15<=0;
			data_reg16<=0;
		
			data_reg_tmp<=0;
			data_out<=0;
		end
		else
		begin

/*-----assign different register to output----*/

			case(out_sel)
				0: data_out<=data_reg1;
				1: data_out<=data_reg2;
				2: data_out<=data_reg3;
				3: data_out<=data_reg4;
				4: data_out<=data_reg5;
				5: data_out<=data_reg6;
				6: data_out<=data_reg7;
				7: data_out<=data_reg8;
				8: data_out<=data_reg9;
				9: data_out<=data_reg10;
				10: data_out<=data_reg11;
				11: data_out<=data_reg12;
				12: data_out<=data_reg13;
				13: data_out<=data_reg14;
				14: data_out<=data_reg15;
				15: data_out<=data_reg16;
			endcase
			
/*-------storing the input when wr_en=1------*/

			if(wr_en==1)
			begin
				if(intmp==1)
				begin
					data_reg_tmp<=data_in;
				end
				else
				begin
					case(in_sel)
						0: data_reg1<=data_in;
						1: data_reg2<=data_in;
						2: data_reg3<=data_in;
						3: data_reg4<=data_in;
						4: data_reg5<=data_in;
						5: data_reg6<=data_in;
						6: data_reg7<=data_in;
						7: data_reg8<=data_in;
						8: data_reg9<=data_in;
						9: data_reg10<=data_in;
						10: data_reg11<=data_in;
						11: data_reg12<=data_in;
						12: data_reg13<=data_in;
						13: data_reg14<=data_in;
						14: data_reg15<=data_in;
						15: data_reg16<=data_in;
					endcase
				end
			end
			
/*----swap the registers when the data_reg_tmp>data_reg{1-8}---*/

			if(compare==1)
			begin
				case(com_sel)
					0:
					begin
						if(data_reg_tmp>data_reg1)
						begin
							data_reg1<=data_reg_tmp;
						end
					end
					1:
					begin
						if(data_reg_tmp>data_reg2)
						begin
							data_reg2<=data_reg_tmp;
						end
					end
					2:
					begin
						if(data_reg_tmp>data_reg3)
						begin
							data_reg3<=data_reg_tmp;
						end
					end
					3:
					begin
						if(data_reg_tmp>data_reg4)
						begin
							data_reg4<=data_reg_tmp;
						end
					end
					4:
					begin
						if(data_reg_tmp>data_reg5)
						begin
							data_reg5<=data_reg_tmp;
						end
					end
					5:
					begin
						if(data_reg_tmp>data_reg6)
						begin
							data_reg6<=data_reg_tmp;
						end
					end
					6:
					begin
						if(data_reg_tmp>data_reg7)
						begin
							data_reg7<=data_reg_tmp;
						end
					end
					7:
					begin
						if(data_reg_tmp>data_reg8)
						begin
							data_reg8<=data_reg_tmp;
						end
					end
					8:
					begin
						if(data_reg_tmp>data_reg9)
						begin
							data_reg9<=data_reg_tmp;
						end
					end
					9:
					begin
						if(data_reg_tmp>data_reg10)
						begin
							data_reg10<=data_reg_tmp;
						end
					end
					10:
					begin
						if(data_reg_tmp>data_reg11)
						begin
							data_reg11<=data_reg_tmp;
						end
					end
					11:
					begin
						if(data_reg_tmp>data_reg12)
						begin
							data_reg12<=data_reg_tmp;
						end
					end
					12:
					begin
						if(data_reg_tmp>data_reg13)
						begin
							data_reg13<=data_reg_tmp;
						end
					end
					13:
					begin
						if(data_reg_tmp>data_reg14)
						begin
							data_reg14<=data_reg_tmp;
						end
					end
					14:
					begin
						if(data_reg_tmp>data_reg15)
						begin
							data_reg15<=data_reg_tmp;
						end
					end
					15:
					begin
						if(data_reg_tmp>data_reg16)
						begin
							data_reg16<=data_reg_tmp;
						end
					end
				endcase
			end
		end
	end
end
endmodule
