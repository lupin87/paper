module decore(clk,reset,start,fv_ack,rom_datain,rom_address,
			regcep_out,regcep_addr,
			frame_num,mixture_num,single,shift_num,word_num,state_num,
			result_ack,result,overflow);
			
input clk,reset;
input start,fv_ack;
input [7:0]rom_datain;
input [15:0]regcep_out;
input [7:0]frame_num;
input [3:0]state_num,shift_num;
input [2:0]mixture_num;
input single;
input [5:0]word_num;

output [19:0]rom_address;
output [12:0]regcep_addr;
output result_ack;
output [5:0]result;
output overflow;
		
// ###################
reg [15:0]rom_data;

wire [18:0]rom_addri;
wire rom_addrt;

wire [15:0]cla16_out;
wire cla16_en;
wire cla16_overflow;

wire [31:0]mulout;
wire mul_insel,mul_en;

wire [25:0]cadder_out;////////////////////////////sua tu 21bit-->26bit
wire cadder_overflow;
wire cadder_en;
wire [1:0]cadder_insel;
wire [15:0]rega;

wire regx_wren;
wire regx_clear;
wire [20:0]regx_xl,regx_xs;

wire sub_en;
wire [20:0]sub_out;

wire shift_enr;
wire shift_enl;
wire [20:0]shift_out;
wire shift_overflow;

wire [20:0]lut_out;
wire lut_en;

wire regs_wren;
wire [3:0]regs_insel;
wire regs_intmp;
wire [3:0]regs_outsel;
wire regs_compare;
wire [3:0]regs_comsel;
wire [20:0]regs_out;
wire regs_clear;

wire [5:0]result;
wire regf_en;
wire [5:0]regf_wordindex;
wire regf_clear;
wire [5:0]regf_result;

assign rom_address={rom_addri,rom_addrt};

always@(posedge clk or negedge reset)
begin
if(reset==0)
begin
	rom_data<=0;
end
else
begin
	case(rom_addrt)
	0:
	begin
		rom_data[15:8]<=rom_datain;
	end
	1:
	begin
		rom_data[7:0]<=rom_datain;
	end
	endcase
end
end

decon decon(start,fv_ack,clk,reset,result_ack,result,overflow,
			rom_data,rom_addri,rom_addrt,
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
			
cla16 cla16(cla16_out,cla16_overflow,rom_data,regcep_out,cla16_en,clk,reset);

//multiplier multiplier(mulout,cla16_out,rom_data,mul_insel,mul_en,clk,reset);
multiplier   multiplier (.mulout(mulout[31:0]),.in1_1({{9{cla16_out[15]}},cla16_out}),.in2_2({{9{rom_data[15]}},rom_data}),.in_sel(mul_insel),.en(mul_en),.clk(clk),.reset(reset));
	
//sua mulout[30:15]	
cadder cadder(cadder_out,cadder_overflow,cadder_en,cadder_insel,mulout[20:0],regs_out,rega,regx_xl,shift_out,clk,reset);

regs regs(regs_out,cadder_out,regs_wren,regs_insel,regs_intmp,regs_outsel,regs_compare,
		regs_comsel,regs_clear,clk,reset);

regx regx(kt,regx_xl,regx_xs,
			cadder_out,single,regx_wren,regx_clear,clk,reset);

sub sub(sub_en,sub_out,regx_xl,regx_xs,clk,reset);

shift shift(shift_num,mixture_num,sub_out,lut_out,shift_out,shift_overflow,shift_enr,shift_enl,clk,reset);

lut lut(lut_out,shift_out,single,shift_overflow,lut_en,clk,reset);

regf regf(regf_result,regs_out,regf_wordindex,regf_en,regf_clear,clk,reset);

endmodule
