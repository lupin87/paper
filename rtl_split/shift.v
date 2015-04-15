module shift(shift_num,mixture_num,sub_in,lut_in,dataout,overflow,enr,enl,clk,reset);

input [20:0] sub_in,lut_in;
input [3:0]shift_num;
input [2:0]mixture_num;
input enr,enl;
input clk,reset;

output [20:0]dataout;
output overflow;

reg [20:0]dataout;
reg overflow;

wire [20:0]ln0=21'h0;
wire [20:0]ln1=21'h0;
wire [20:0]ln2=21'h0;
wire [20:0]ln3=21'h033e6;//13286
wire [20:0]ln4=21'h058b9;//22713
wire [20:0]ln5=21'h07549;//30025
wire [20:0]ln6=21'h08c9f;//35999
wire [20:0]ln7=21'h0a05a;//41050
wire [20:0]ln8=21'h0b172;//45426

wire [20:0]datatmpl,datatmpr,data1,data2;
wire [20:0]p;
wire [19:0]g;
wire [20:0]car;
wire [20:0]sum;

assign datatmpl=(shift_num==0)?sub_in:21'bz;
assign datatmpl=(shift_num==1)?{sub_in[19:0],1'b0}:21'bz;//dich trai
assign datatmpl=(shift_num==2)?{sub_in[18:0],2'b00}:21'bz;
assign datatmpl=(shift_num==3)?{sub_in[17:0],3'b000}:21'bz;
assign datatmpl=(shift_num==4)?{sub_in[16:0],4'b0000}:21'bz;
assign datatmpl=(shift_num==5)?{sub_in[15:0],5'b00000}:21'bz;
assign datatmpl=(shift_num==6)?{sub_in[14:0],6'b000000}:21'bz;
assign datatmpl=(shift_num==7)?{sub_in[13:0],7'b0000000}:21'bz;
assign datatmpl=(shift_num==8)?{sub_in[12:0],8'b00000000}:21'bz;
assign datatmpl=(shift_num==9)?{sub_in[11:0],9'b000000000}:21'bz;
assign datatmpl=(shift_num==10)?{sub_in[10:0],10'b0000000000}:21'bz;
assign datatmpl=(shift_num==11)?{sub_in[9:0],11'b00000000000}:21'bz;
assign datatmpl=(shift_num==12)?{sub_in[8:0],12'b000000000000}:21'bz;
assign datatmpl=(shift_num==13)?{sub_in[7:0],13'b0000000000000}:21'bz;
assign datatmpl=(shift_num==14)?{sub_in[6:0],14'b00000000000000}:21'bz;
assign datatmpl=(shift_num==15)?{sub_in[5:0],15'b000000000000000}:21'bz;

assign datatmpr=(shift_num==0)?lut_in:21'bz;
assign datatmpr=(shift_num==1)?{1'b0,lut_in[20:1]}:21'bz;//dich phai
assign datatmpr=(shift_num==2)?{2'b00,lut_in[20:2]}:21'bz;
assign datatmpr=(shift_num==3)?{3'b000,lut_in[20:3]}:21'bz;
assign datatmpr=(shift_num==4)?{4'b0000,lut_in[20:4]}:21'bz;
assign datatmpr=(shift_num==5)?{5'b00000,lut_in[20:5]}:21'bz;
assign datatmpr=(shift_num==6)?{6'b000000,lut_in[20:6]}:21'bz;
assign datatmpr=(shift_num==7)?{7'b0000000,lut_in[20:7]}:21'bz;
assign datatmpr=(shift_num==8)?{8'b00000000,lut_in[20:8]}:21'bz;
assign datatmpr=(shift_num==9)?{9'b000000000,lut_in[20:9]}:21'bz;
assign datatmpr=(shift_num==10)?{10'b0000000000,lut_in[20:10]}:21'bz;
assign datatmpr=(shift_num==11)?{11'b00000000000,lut_in[20:11]}:21'bz;
assign datatmpr=(shift_num==12)?{12'b000000000000,lut_in[20:12]}:21'bz;
assign datatmpr=(shift_num==13)?{13'b0000000000000,lut_in[20:13]}:21'bz;
assign datatmpr=(shift_num==14)?{14'b00000000000000,lut_in[20:14]}:21'bz;
assign datatmpr=(shift_num==15)?{15'b000000000000000,lut_in[20:15]}:21'bz;

assign data1=datatmpl;

assign data2=(mixture_num==0)?ln1:21'bz;
assign data2=(mixture_num==1)?ln2:21'bz;
assign data2=(mixture_num==2)?ln3:21'bz;
assign data2=(mixture_num==3)?ln4:21'bz;
assign data2=(mixture_num==4)?ln5:21'bz;
assign data2=(mixture_num==5)?ln6:21'bz;
assign data2=(mixture_num==6)?ln7:21'bz;
assign data2=(mixture_num==7)?ln8:21'bz;

assign p=data1^data2;
assign g=data1[19:0]&data2[19:0];
assign car[0]=0;
assign car[20:1]=g[19:0]|p[19:0]&car[19:0];
assign sum=p^car;

always@(posedge clk or negedge reset)
begin
if(reset==0)
begin
	dataout<=0;
	overflow<=0;
end
else
begin
	if(enl==1)//cho phep dich trai
	begin
		dataout<=sum;
		overflow<=~datatmpl[20]&sub_in[20];
	end
	if(enr==1)//cho phep dich phai
	begin
		overflow<=0;
		dataout<=datatmpr;
	end
end
end
endmodule
