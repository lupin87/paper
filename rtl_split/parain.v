module parain(fram_address,fram_datain,
	fe_address,fe_data,
	de_address,de_data,
	feregcep_addr,deregcep_addr,regcep_addr,
	shiftc,shiftd,
	mixture_num,single,shift_num,
	word_num,state_num,ready,
	result_ack,fefinish,fs,fv_ack,reset,clk);
input [7:0]fram_datain;
input [15:0]fe_address;
input [19:0]de_address;
input [12:0]feregcep_addr,deregcep_addr;
input result_ack,fefinish,reset,clk;

output [20:0]fram_address;
output [7:0]fe_data,de_data;
output [12:0]regcep_addr;
output [3:0]shiftc;
output [1:0]shiftd;
output [3:0]state_num,shift_num;
output [2:0]mixture_num;
output single;
output [5:0]word_num;
output ready;
output fv_ack;
output fs;

reg [3:0]shiftc;
reg [1:0]shiftd;
reg [3:0]state_num,shift_num;
reg [2:0]mixture_num;
reg single;
reg [5:0]word_num;
reg fv_ack;
reg [20:0]para_address;
wire [20:0]tram_address;
reg [2:0]state;
reg ready;
reg fs;//fs=1 when fefinish=1

assign tram_address=(fs)?{1'b0,de_address}:{5'b00000,fe_address};
assign fram_address=(ready)?tram_address:para_address;
assign fe_data=(~fs)?fram_datain:8'b0;
assign de_data=(fs)?fram_datain:8'b0;
assign regcep_addr=(fs)?deregcep_addr:feregcep_addr;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		para_address<=58;
		shiftc<=0;
		shiftd<=0;
		mixture_num<=0;
		single<=0;
		shift_num<=0;
		word_num<=0;
		state_num<=0;
		fv_ack<=0;
		state<=0;
		ready<=0;
		fs<=0;
	end
	else
	begin
		case(state)
		0:
		begin
			if(ready==0)
			begin
				shiftc<=fram_datain[3:0];
				para_address<=para_address+1;
				state<=state+1;
			end
			if(result_ack==1)
				fs<=0;
			if(fefinish==1)
			begin
				fs<=1;
				state<=state+1;
			end
			fv_ack<=0;
		end
		1:
		begin
			if(ready==0)
			begin
				shiftd<=fram_datain[1:0];
				para_address<=para_address+1;
				state<=state+1;
			end
			if(fs==1)
			begin
				fv_ack<=1;
				state<=0;
			end
		end
		2:
		begin
			mixture_num<=fram_datain[2:0];
			para_address<=para_address+1;
			state<=state+1;
		end
		3:
		begin
			state_num<=fram_datain[3:0];
			para_address<=para_address+1;
			state<=state+1;
		end
		4:
		begin
			word_num<=fram_datain[5:0];
			para_address<=para_address+1;
			state<=state+1;
		end
		5:
		begin
			shift_num<=fram_datain[3:0];
			para_address<=58;
			if(mixture_num==0)
				single<=1;
				ready<=1;
				state<=0;
		end
		endcase
		end
	end
endmodule
