module test_core(result_ack,result,overflow,start,clk,reset, fft_finish);

input start;
input clk,reset;
wire [7:0]fram_datain;
wire [7:0]fram_datain1;//model parameter
wire [7:0]fram_datain2;//speech RAM

wire [20:0]fram_address;

wire [15:0]regcep_out;
wire [15:0]regcep_in;
wire [12:0]regcep_addr;
wire regcep_wren;

output result_ack;//bao ket thuc nhan dang
output [5:0]result;//chi so tu
output overflow;//bao ket qua nhan dang khong dang tin cay


wire [15:0]fe_address;//to MFCC RAM
wire [19:0]de_address;
//wire [19:0]address;
wire [7:0]fe_data,de_data;
wire [12:0]feregcep_addr;
wire [12:0]deregcep_addr;

//model parameters
wire [3:0] shiftc;      //from model_para
wire [1:0] shiftd;      //from model_para
wire [2:0] mixture_num; //mixture,from model_para
wire [3:0] state_num;   //states,from model_para
wire [5:0] word_num;    //words,from model_para
wire [3:0] shift_num;   //from model_para

wire single;

wire ready;   //from parain
wire fv_ack;  //bat dau decoder
wire fs;      //from parain, fs=1 when fefinish=1
wire fefinish;//fefinish=1-->ket thuc tin hieu ngo vao
output fft_finish;
wire [7:0]framenum;
wire [7:0]rd_addr;

wire [15:0]speech_data;
wire [15:0]ram_data_in;
wire rd_en;
wire speech_wren=(!ready)|fs;
wire fram_wren=ready^fs;

assign fram_datain=(ready^fs)?fram_datain2:fram_datain1;//{{6{a[15]}},a[15:5]}
wire [15:0]data_in_de=((regcep_addr[4:0]==12)|(regcep_addr[4:0]==25))?{{10{regcep_out[15]}},regcep_out[15:10]}:regcep_out;

fecore fecore(fe_data,fe_address,
      regcep_in,feregcep_addr,regcep_wren,
      framenum,shiftc,shiftd,
      start,ready,fefinish,fft_finish,fs,clk,reset, rd_addr, rd_en, ram_data_in);
			
decore decore(clk,ready,start,fv_ack,de_data,de_address,
			data_in_de,deregcep_addr,
			framenum,mixture_num,single,shift_num,word_num,state_num,
			result_ack,result,overflow);		

parain parain(.fram_address(fram_address),.fram_datain(fram_datain),
		.fe_address(fe_address),.fe_data(fe_data),
		.de_address(de_address),.de_data(de_data),
		.feregcep_addr(feregcep_addr),.deregcep_addr(deregcep_addr),.regcep_addr(regcep_addr),
		.shiftc(shiftc),.shiftd(shiftd),
		.mixture_num(mixture_num),.single(single),.shift_num(shift_num),
		.word_num(word_num),.state_num(state_num),.ready(ready),
		.result_ack(result_ack),.fefinish(fefinish),.fs(fs),.fv_ack(fv_ack),.reset(reset),.clk(clk));

regcep regcep(ram_data_in,regcep_in,rd_addr,rd_en,clk,reset);//4.MFCC RAM

model_ram  model_ram(.fram_dataout(fram_datain1),.fram_addr(fram_address),.fram_wren(fram_wren));//5.flash RAM stored model parameters

speech_ram speech_ram(.speech_data(speech_data),.speech_addr({2'b0,fram_address[20:1]}),.speech_wren(speech_wren));//6.speech RAM

read_speech read_speech(.addr_in({2'b0,fram_address}),.sdram_in(speech_data),.sdram_out(fram_datain2));

endmodule
