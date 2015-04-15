module decon(start,fv_ack,clk,reset,result_ack,result,overflow,
			rom_data,rom_addr,rom_addrt,
			regcep_addr,
			cla16_en,
			mul_insel,mul_en,
			cadder_overflow,cadder_en,cadder_insel,rega,
			regx_wren,regx_clear,
			sub_en,
			shift_enr,shift_enl,
			lut_en,
			regs_wren,regs_insel,regs_intmp,regs_outsel,regs_compare,regs_comsel,regs_clear,
			regf_en,regf_wordindex,regf_clear,regf_result,
			frame_num,state_num,mixture_num,word_num);

input start,fv_ack;
input clk,reset;
output result_ack,overflow;
reg result_ack,overflow;
output [5:0]result;
reg [5:0]result;

input [15:0]rom_data;

output [18:0]rom_addr;
output rom_addrt;
reg rom_addrt;

output [12:0]regcep_addr;

output cla16_en;
reg cla16_en;

output mul_insel,mul_en;
reg mul_insel,mul_en;

input cadder_overflow;
output cadder_en;
output [1:0]cadder_insel;
output [15:0]rega;
reg cadder_en;
reg [1:0]cadder_insel;
reg [15:0]rega;//hold lnaij-lnaii

output regx_wren,regx_clear;
reg regx_wren,regx_clear;

output sub_en;
reg sub_en;

output shift_enr,shift_enl;
reg shift_enr,shift_enl;

output lut_en;
reg lut_en;

output regs_wren,regs_intmp,regs_compare,regs_clear;
output [3:0]regs_insel,regs_outsel,regs_comsel;
reg regs_wren,regs_intmp,regs_compare;
reg [3:0]regs_insel,regs_outsel,regs_comsel;

output regf_en,regf_clear;
output [5:0]regf_wordindex;
reg regf_en,regf_clear;
input [5:0]regf_result;

input [7:0]frame_num;//frame_num=true_frame_number-1,max=256
input [3:0]state_num;//max=16
input [2:0]mixture_num;//max=8
input [5:0]word_num;//max=64;

reg [4:0]addr_com;//last 5 bit for rom, 26 vectors
reg [4:0]addr_cam;//last 5 bit for ram, 26 vectors

reg [7:0]frame_addr;//first 8 address for ram, count frame

reg [2:0]db;//first address bit of rom,double mixtures,0 for x1,1 for x2
reg mean;//second address bit of rom,1 for mean,0 for variance
reg [5:0]word_addr;//count the current word index
reg [3:0]state_addr;//count state of the model
reg tsa;

reg delay;

/*---state machine---*/

reg [1:0]state;
reg [2:0]statei;

assign rom_addr={db,mean,word_addr,state_addr,addr_com};
assign regcep_addr={frame_addr,addr_cam};
assign regf_wordindex=word_addr;
assign regs_clear=regf_en;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		addr_cam<=0;
		frame_addr<=0;
		
		addr_com<=0;
		rom_addrt<=0;
		db<=0;
		mean<=1;
		word_addr<=0;
		state_addr<=0;
		tsa<=0;
		cla16_en<=0;
		
		mul_insel<=0;
		mul_en<=0;
		
		cadder_en<=0;
		cadder_insel<=0;
		rega<=0;
		
		regx_wren<=0;
		regx_clear<=0;
		
		sub_en<=0;
		
		shift_enr<=0;
		shift_enl<=0;
		
		lut_en<=0;
		
		regs_wren<=0;
		regs_insel<=0;
		regs_intmp<=0;
		regs_outsel<=0;
		regs_compare<=0;
		regs_comsel<=0;
		
		regf_en<=0;
		regf_clear<=0;
		
		result_ack<=0;
		result<=0;
		overflow<=0;
		
		state<=0;
		statei<=0;
		delay<=0;
	end
	else
	begin
	 case(state)
			0:
			/*---read in model parameters when fv_ack is 1---*/
			begin
				if(start==0)
				begin
					overflow<=0;
					result_ack<=0;
					result<=0;
				end
				
				case(statei)
				0:
				begin
					if(fv_ack==1)
					begin
						rom_addrt<=1;
						regf_clear<=1;
						statei<=statei+1;
					end
				end
				1:
				begin
					rom_addrt<=0;
					mean<=0;
					regf_clear<=0;
					cla16_en<=1;
					statei<=0;
					state<=state+1;
				end
				endcase
			end
			1:
			begin
				/*---address calculation---*/
				if(cadder_overflow==1)
					overflow<=1;
				if(addr_com==26)
				begin
					if(statei==1)
					begin
						if(delay==0)
							delay<=1;
						else
						begin
							addr_cam<=0;
							delay<=0;
							
							if(db==mixture_num && (state_addr==frame_addr||state_addr==state_num))
							begin
								tsa<=1;
								if(frame_addr<frame_num)
									frame_addr<=frame_addr+1;
								else
									frame_addr<=0;
							end
						end
					end
					if(addr_cam==0)
					begin
						if(db!=mixture_num)
							db<=db+1;//switch between two mixtures
						else
						begin
							db<=0;
							if(tsa==1)
							begin
								tsa<=0;
								state_addr<=0;//calculate through 8 state
								if(frame_addr==0)
									word_addr<=word_addr+1;//increase word index
							end
							else
								state_addr<=state_addr+1;
					end
				end
			end
				
			if(addr_com==1 && word_addr==word_num && regf_en==1)
			begin
				state<=state+1;
			end
			/*---read in x,xmean,var,lnC and lna---*/
			case(statei)
					0:
					begin
						cla16_en<=0;
						if(addr_com!=26)
							mul_en<=1;
						if(delay==0 && addr_com!=26)
						begin
							cadder_en<=0;
						end
						if(addr_cam==1)
						begin
							cadder_insel<=1;
						end
						if(addr_com==26 && delay==0)
						begin
							cadder_insel<=2;
						end
							
						if(addr_com==26 && delay==0)
							rega<=rom_data;
						sub_en<=0;
							
						if(sub_en==1)
						begin
							shift_enl<=1;
						end
							
						if(regs_wren==1)
						begin
							if(state_addr==0)
							begin
								if(regs_insel==state_num)
								begin
									regs_wren<=0;
								end
								else
								begin
									regs_insel<=regs_insel+1;
								end
							end
							else
							begin
								regs_intmp<=1;
							end
								
							if(regs_outsel!=0)
							begin
								regs_compare<=1;
							end
								
							regs_comsel<=regs_insel;
								
						end
							
						statei<=statei+1;
					end
					1:
					begin
						rom_addrt<=1;
							
						if(addr_cam!=25)
						begin
							addr_cam<=addr_cam+1;
						end
							
						mul_en<=0;
							
						cadder_en<=0;
							
						shift_enl<=0;
							
						if(shift_enl==1)
						begin
							lut_en<=1;
						end
							
						regs_wren<=0;
						regs_intmp<=0;
						regs_compare<=0;
							
						statei<=statei+1;
					end
					2:
					begin
						mean<=1;
						rom_addrt<=0;
							
						if(addr_com!=25 && delay!=1)
							addr_com<=addr_cam;
						else
							addr_com<=26;
							
						if(addr_cam!=0 && delay==0)
						begin
							mul_insel<=1;
							mul_en<=1;
						end
							
						lut_en<=0;
							
						if(lut_en==1)
						begin
							shift_enr<=1;
						end
							
						statei<=statei+1;
					end
					3:
					begin
						rom_addrt<=1;
							
						mul_en<=0;
						mul_insel<=0;
							
						if(delay==1)
						begin
							regx_wren<=1;
						end
							
						shift_enr<=0;
							
						if(shift_enr==1)
						begin
							cadder_en<=1;
							cadder_insel<=3;
							rega<=rom_data;
							regx_clear<=1;
						end
							
						if(addr_cam==1)
						begin
							regs_outsel<=state_addr;
						end
							
						if(frame_addr==0 && addr_cam==1 && db==0 && word_addr!=0)
						begin
							regf_en<=1;
						end
							
						statei<=statei+1;
					end
					4:
					begin
						mean<=0;
						rom_addrt<=0;
							
						if(addr_com!=26 && word_addr!=word_num)
						begin
							cla16_en<=1;
						end
							
						if(addr_cam!=0 && delay!=1 && word_addr!=word_num)
						begin
							cadder_en<=1;
						end
							
						if(addr_cam==1)
						begin
							cadder_insel<=0;
						end
							
						if(cadder_insel==3)
						begin
							cadder_en<=1;
							cadder_insel<=2;
								
							regx_clear<=0;
								
							regs_wren<=1;
							regs_insel<=regs_outsel;
						end
							
						regx_wren<=0;
							
						if(delay==1 && db==mixture_num)
						begin
							sub_en<=1;
						end
							
						regf_en<=0;
							
						statei<=0;
					end
				endcase
			end
			2:
			/*---finish recognition---*/
			begin
				result_ack<=1;
				result<=regf_result;
				frame_addr<=0;
				addr_cam<=0;
				db<=0;
				mean<=1;
				word_addr<=0;
				state_addr<=0;
				addr_com<=0;
				cla16_en<=0;
				mul_insel<=0;
					
				cadder_insel<=0;
				cadder_en<=0;
				
				regs_wren<=0;
				regs_insel<=0;
				regs_outsel<=0;
				regs_intmp<=0;
				regs_compare<=0;
				regs_comsel<=0;
					
				regx_wren<=0;
					
				sub_en<=0;
					
				shift_enr<=0;
				shift_enl<=0;
					
				lut_en<=0;
					
				regf_en<=0;
				regf_clear<=0;
					
				state<=0;
				statei<=0;
			end
		endcase
	end
end
endmodule
