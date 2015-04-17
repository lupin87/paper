module fecore(ram_datain,ram_address,
      regcep_in,regcep_addr,regcep_wren,
      framenum,shiftc,shiftd,
      start,ready,fefinish,fft_finish,fs,clk,reset, rd_addr, rd_en, ram_data_in);
      
input [7:0]ram_datain;//from Speech RAM
reg [15:0]ram_data;//
input [15:0]ram_data_in;//
input start;
input ready;//ready=1:bat dau doc data tu speech RAM, ready=0: doc thong so mo hinh
input [3:0]shiftc;//shift the cepstrum
input [1:0]shiftd;//shift the data
input fs;
input clk,reset;

output  [7:0]framenum;
output fefinish;
output [7:0] rd_addr;
output       rd_en;
output fft_finish;

output [15:0]ram_address;//to Speech RAM (ram_address={ram_addri,ram_addrt})

wire [4:0]cham_data;

wire [39:0]regfft_outr,regfft_outi;//input
wire [7:0]cfft_datar,cfft_datai;

wire [40:0]regffte_out;//he so nang luong, |I+jQ|
wire [44:0]regmel_out;//he so cong suat logS'nk

wire [7:0]cham_addr;

wire regfft_wren;
wire [7:0]regfft_addr;//

wire [39:0]regfft_inr,regfft_ini;//output cua FFT
//wire [5:0]cfft_addr;//
wire [6:0]cfft_addr;// Thuong change from 5 to 6

wire [40:0]regffte_in;
//wire [5:0]regffte_addr; Thuong for 256 point
wire [6:0]regffte_addr; 
wire regffte_wren;

wire [44:0]regmel_in;
wire [4:0]regmel_addr;
wire regmel_wren;

wire [15:0]regdct_out;//he so cepstral
wire [15:0]regdct_in;
wire [4:0]regdct_addr;//
wire regdct_wren;


wire [7:0]cdct_data;
wire [7:0]cdct_addr;//

wire [15:0]regc_out;
wire [15:0]regc_in;
wire [6:0]regc_addr;
wire regc_wren;
// log energy register

wire [15:0]reglog_out;
wire [15:0]reglog_in;
wire [2:0]reglog_addr;
wire reglog_wren;

output [15:0]regcep_in;//Feature vector
output [12:0]regcep_addr;//to MFCC RAM
output regcep_wren;//to MFCC RAM
wire [1:0]regc_sel;

wire [14:0]ram_addri;
wire ram_addrt;
wire [7:0]regfft_addrt; //Thuong 29Oct13

wire square_en;
wire [30:0]square_out;

wire [38:0]eadder_out;
wire eadder_en;
wire eadder_new;
wire eadder_sel;

wire [38:0]ereg_out;
wire ereg_we;

wire [45:0]log_in;
wire [15:0]log_out;
wire log_en,log_sel,log_overf;

wire [16:0]preemp_out;
wire preemp_en;
wire preemp_en_out;
wire preemp_new;
wire preemp_state_en;

wire [20:0]win_out;
wire win_en;

wire [39:0]regfft_inrt;//
wire regfft_insel,regfft_clear;//

wire [38:0]com_out1,com_out2,com_out3,com_out4;
wire [38:0]cm_outr,cm_outi;
wire cm_en,comadd_en,cm_shift;//

wire [39:0]addsubfft_outr,addsubfft_outi;//
wire [39:0]addsubfft_regfftr,addsubfft_regffti;//
wire addsubfft_en,addsubfft_sel,addsubfft_shift;//
 
wire sroot_en;

wire [45:0]addmel_out;
wire addmel_en,addmel_sel,addmel_new;

wire [22:0]muldct_out;
wire muldct_en;

wire [27:0]addsubdct_out;
wire [15:0]taddsubdct_out;
wire addsubdct_en,addsubdct_sub,addsubdct_new;


wire [19:0]delta_out;//he so delta
wire [15:0]tdelta_out;
wire delta_new,delta_sub,delta_shift,delta_en;

assign ram_address={ram_addri,ram_addrt}; 
assign rd_addr = regfft_addrt;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    ram_data<=0;
  end
  else
  begin
    case(ram_addrt)
    0:
    begin
      ram_data[7:0]<=ram_datain;
    end
    1:
    begin
      ram_data[15:8]<=ram_datain;
    end
    endcase
  end
end

//assign taddsubdct_out=(shiftc==15)?addsubdct_out[26:11]:16'bz;
//assign taddsubdct_out=(shiftc==14)?addsubdct_out[26:11]:16'bz;
//assign taddsubdct_out=(shiftc==13)?addsubdct_out[26:11]:16'bz;
//assign taddsubdct_out=(shiftc==12)?addsubdct_out[27:12]:16'bz;
//assign taddsubdct_out=(shiftc==11)?addsubdct_out[26:11]:16'bz;
//assign taddsubdct_out=(shiftc==10)?addsubdct_out[25:10]:16'bz;
//assign taddsubdct_out=(shiftc==9)?addsubdct_out[24:9]:16'bz;
//assign taddsubdct_out=(shiftc==8)?addsubdct_out[23:8]:16'bz;
//assign taddsubdct_out=(shiftc==7)?addsubdct_out[23:7]:16'bz;
//assign taddsubdct_out=(shiftc==6)?addsubdct_out[21:6]:16'bz;
//assign taddsubdct_out=(shiftc==5)?addsubdct_out[20:5]:16'bz;
//assign taddsubdct_out=(shiftc==4)?addsubdct_out[19:4]:16'bz;
//assign taddsubdct_out=(shiftc==3)?addsubdct_out[18:3]:16'bz;
//assign taddsubdct_out=(shiftc==2)?addsubdct_out[17:2]:16'bz;
//assign taddsubdct_out=(shiftc==1)?addsubdct_out[16:1]:16'bz;
//assign taddsubdct_out=(shiftc==0)?addsubdct_out[15:0]:16'bz;

//assign tdelta_out=(shiftd==3)?delta_out[18:3]:16'bz;
//assign tdelta_out=(shiftd==2)?delta_out[17:2]:16'bz;
//assign tdelta_out=(shiftd==1)?delta_out[16:1]:16'bz;
//assign tdelta_out=(shiftd==0)?delta_out[15:0]:16'bz;

//assign log_in=(log_sel)?{{7{eadder_out[38]}},eadder_out}:addmel_out;
//regfft_insel=0:doc du lieu da duoc windowing vao thanh ghi phan thuc regfft_inr dong thoi xoa noi dung thanh ghi phan ao regfft_ini
//regfft_clear=1:xoa noi dung thanh ghi regfft_inr va regfft_ini
//regfft_clear=0 va regfft_insel=1:ghi noi dung cac tang FFT vao thanh ghi regfft
assign regfft_ini=(regfft_insel & ~regfft_clear)?addsubfft_outi:0;//phan ao output cua FFT
assign regfft_inrt=(regfft_insel)?addsubfft_outr:{{24{ram_data_in[15]}},ram_data_in};
assign regfft_inr=(regfft_clear)?0:regfft_inrt;//phan thuc output cua FFT

assign addsubfft_regfftr=(addsubfft_shift)?{regfft_outr[33:0],6'b0}:regfft_outr;
assign addsubfft_regffti=(addsubfft_shift)?{regfft_outi[33:0],6'b0}:regfft_outi;

//assign regmel_in=addmel_out[44:0];
//
//assign regdct_in=log_out;
//
//assign regc_in=(regc_sel==0)?regc_out:16'bz;
//assign regc_in=(regc_sel==1)?reglog_out:16'bz;//logged energy of frame
//assign regc_in=(regc_sel==1)?log_out:16'bz;//logged energy of frame Thuong change
//assign regc_in=(regc_sel==2)?taddsubdct_out:16'bz;//cepstrum coefficients of frame
//assign regc_in=(regc_sel==3)?tdelta_out:16'bz;//delta coefficients of frame
//
//assign regcep_in=regc_out;//thanh ghi vecto dac trung MFCC

//register

//reghw reghw(cham_data,cham_addr,clk,reset);//1.Register for Hamming Window coefficients

regw regw(cfft_datar,cfft_datai,cfft_addr,clk,reset);//2.Register for FFT coefficients,W

//rege rege(regffte_out,regffte_in,regffte_addr,regffte_wren,clk,reset);//3.Spectrum Register (register for energy coefficients)
//
//regp regp(regmel_out,regmel_in,regmel_addr,regmel_wren,clk,reset);//4.Power coefficient Register

regfft regfft(regfft_outr,regfft_outi,regfft_inr,regfft_ini,regfft_addr,regfft_wren,clk,reset);//5.Register for 128 points FFT (256 elements,128 part real,128 part imaginary)

//regdct regdct(regdct_out,regdct_in,regdct_addr,regdct_wren,clk,reset);//6.Logged power coefficient register
//
//regcdct regcdct(cdct_addr,cdct_data,clk,reset);//7.Feature Buffer Register
//
//regc regc(regc_out,regc_in,regc_addr,regc_wren,clk,reset);//8.Feature Buffer Register
//
//reglog reglog(clk,reset,reglog_addr,reglog_wren,log_out, reglog_out);//9. Log energy Register - Thuong add

//

//square square(square_out,ram_data,square_en,clk,reset);
//
//eadder eadder(eadder_out,eadder_en,eadder_new,eadder_sel,square_out,ereg_out,clk,reset);
//
//ereg ereg(eadder_out,ereg_out,ereg_we,clk,reset);
//
//log log(log_in,log_out,log_en,log_overf,clk,reset);
//
//preemp preemp(ram_data,preemp_out,preemp_en,preemp_new,clk,reset, preemp_state_en);
////preemp preemp(ram_data,preemp_out,preemp_en_out,preemp_new,clk,reset);
//
//window window(preemp_out,cham_data,win_out,(win_en&win_en_mask),clk,reset);

complexm complexm(regfft_outr[30:0],regfft_outi[30:0],cfft_datar,cfft_datai,
        com_out1,com_out2,com_out3,com_out4,cm_en,clk,reset);

comadd comadd(com_out1,com_out2,com_out3,com_out4,cm_outr,cm_outi,comadd_en,cm_shift,clk,reset);

addsubfft addsubfft(addsubfft_regfftr,addsubfft_regffti,cm_outr,cm_outi,addsubfft_outr,
        addsubfft_outi,addsubfft_en,addsubfft_sel,clk,reset);

//sroot sroot(regfft_outr,regfft_outi,regffte_in,sroot_en,clk,reset);
//
////addmel addmel(regffte_out,regmel_out,addmel_out,addmel_en,addmel_sel,addmel_new,clk,reset);// Thuong change to frame calculation
//addmel addmel(regffte_out,regmel_out,addmel_out,addmel_en,1'b0,addmel_new,clk,reset);
//
//muldct muldct(regdct_out,cdct_data,muldct_out,muldct_en,clk,reset);
//
//addsubdct addsubdct(muldct_out,addsubdct_out,addsubdct_en,addsubdct_sub,addsubdct_new,clk,reset);
//
//delta delta(delta_out,regc_out,delta_new,delta_sub,delta_shift,delta_en,clk,reset);

fecon fecon(.ram_addr(ram_addri),.ram_addrt(ram_addrt),
      .square_en(square_en),
      .eadder_en(eadder_en),.eadder_new(eadder_new),.eadder_sel(eadder_sel),
      .ereg_we(ereg_we),
      .log_en(log_en),.log_sel(log_sel),.log_overf(log_overf),
      .preemp_en(preemp_en),.preemp_en_out(preemp_en_out),.preemp_new(preemp_new),.preemp_state_en(preemp_state_en),
      .cham_addr(cham_addr),
      .win_en(win_en),.win_en_mask (win_en_mask),
      .regfft_wren(regfft_wren),.regfft_addr(regfft_addr), .regfft_addrt(regfft_addrt), .rd_en(rd_en),
      .regfft_insel(regfft_insel),.regfft_clear(regfft_clear),
      .cfft_addr(cfft_addr),
      .cm_en(cm_en),.comadd_en(comadd_en),.cm_shift(cm_shift),
      .addsubfft_en(addsubfft_en),.addsubfft_sel(addsubfft_sel),.addsubfft_shift(addsubfft_shift),
      .sroot_en(sroot_en),
      .regffte_addr(regffte_addr),.regffte_wren(regffte_wren),
      .addmel_en(addmel_en),.addmel_sel(addmel_sel),.addmel_new(addmel_new),
      .regmel_addr(regmel_addr),.regmel_wren(regmel_wren),
      .regdct_addr(regdct_addr),.regdct_wren(regdct_wren),
      .cdct_addr(cdct_addr),
      .muldct_en(muldct_en),
      .addsubdct_en(addsubdct_en),.addsubdct_sub(addsubdct_sub),
      .addsubdct_new(addsubdct_new),
      .regc_addr(regc_addr),.regc_wren(regc_wren),.regc_sel(regc_sel),
      .reglog_addr(reglog_addr), .reglog_wren(reglog_wren),
      .delta_new(delta_new),.delta_sub(delta_sub),.delta_shift(delta_shift),
      .delta_en(delta_en),
      .regcep_addr(regcep_addr),.regcep_wren(regcep_wren),
      .framenum(framenum),
      .start(start),.ready(ready),.fefinish(fefinish),.fft_finish(fft_finish),.fs(fs),.clk(clk),.reset(reset));
endmodule
