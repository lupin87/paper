module regw(cw_datar,cw_datai,cw_addr,clk,reset);
      
output [7:0]cw_datar,cw_datai;//FFT coefficient in W_N=c+j*d(8bits 2's complement)
reg [7:0]cw_datar,cw_datai;

input [6:0]cw_addr;//truy cap 2^6=64 thanh ghi, can 64 he so W 
//input wr_en;
input clk,reset;

always@(clk or reset)
begin
  if(reset==0)
  begin
    cw_datar<=0;//part real of W_N
    cw_datai<=0;//part imaginary of W_N
  end
  else
  begin
/*-----assign different register to output----*/
    case(cw_addr)
	0:   begin cw_datar <= 8'h40 ;	cw_datai <= 8'h0 ; end
	1:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hfe ; end
	2:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hfc ; end
	3:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hfb ; end
	4:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hf9 ; end
	5:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hf8 ; end
	6:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hf6 ; end
	7:   begin cw_datar <= 8'h3f ;	cw_datai <= 8'hf5 ; end
	8:   begin cw_datar <= 8'h3e ;	cw_datai <= 8'hf3 ; end
	9:   begin cw_datar <= 8'h3e ;	cw_datai <= 8'hf1 ; end
	10:  begin cw_datar <= 8'h3e ;	cw_datai <= 8'hf0 ; end
	11:  begin cw_datar <= 8'h3d ;	cw_datai <= 8'hee ; end
	12:  begin cw_datar <= 8'h3d ;	cw_datai <= 8'hed ; end
	13:  begin cw_datar <= 8'h3c ;	cw_datai <= 8'heb ; end
	14:  begin cw_datar <= 8'h3c ;	cw_datai <= 8'hea ; end
	15:  begin cw_datar <= 8'h3b ;	cw_datai <= 8'he8 ; end
	16:  begin cw_datar <= 8'h3b ;	cw_datai <= 8'he7 ; end
	17:  begin cw_datar <= 8'h3a ;	cw_datai <= 8'he6 ; end
	18:  begin cw_datar <= 8'h39 ;	cw_datai <= 8'he4 ; end
	19:  begin cw_datar <= 8'h39 ;	cw_datai <= 8'he3 ; end
	20:  begin cw_datar <= 8'h38 ;	cw_datai <= 8'he1 ; end
	21:  begin cw_datar <= 8'h37 ;	cw_datai <= 8'he0 ; end
	22:  begin cw_datar <= 8'h36 ;	cw_datai <= 8'hdf ; end
	23:  begin cw_datar <= 8'h36 ;	cw_datai <= 8'hdd ; end
	24:  begin cw_datar <= 8'h35 ;	cw_datai <= 8'hdc ; end
	25:  begin cw_datar <= 8'h34 ;	cw_datai <= 8'hdb ; end
	26:  begin cw_datar <= 8'h33 ;	cw_datai <= 8'hd9 ; end
	27:  begin cw_datar <= 8'h32 ;	cw_datai <= 8'hd8 ; end
	28:  begin cw_datar <= 8'h31 ;	cw_datai <= 8'hd7 ; end
	29:  begin cw_datar <= 8'h30 ;	cw_datai <= 8'hd6 ; end
	30:  begin cw_datar <= 8'h2f ;	cw_datai <= 8'hd5 ; end
	31:  begin cw_datar <= 8'h2e ;	cw_datai <= 8'hd3 ; end
	32:  begin cw_datar <= 8'h2d ;	cw_datai <= 8'hd2 ; end
	33:  begin cw_datar <= 8'h2c ;	cw_datai <= 8'hd1 ; end
	34:  begin cw_datar <= 8'h2a ;	cw_datai <= 8'hd0 ; end
	35:  begin cw_datar <= 8'h29 ;	cw_datai <= 8'hcf ; end
	36:  begin cw_datar <= 8'h28 ;	cw_datai <= 8'hce ; end
	37:  begin cw_datar <= 8'h27 ;	cw_datai <= 8'hcd ; end
	38:  begin cw_datar <= 8'h26 ;	cw_datai <= 8'hcc ; end
	39:  begin cw_datar <= 8'h24 ;	cw_datai <= 8'hcb ; end
	40:  begin cw_datar <= 8'h23 ;	cw_datai <= 8'hca ; end
	41:  begin cw_datar <= 8'h22 ;	cw_datai <= 8'hc9 ; end
	42:  begin cw_datar <= 8'h20 ;	cw_datai <= 8'hc9 ; end
	43:  begin cw_datar <= 8'h1f ;	cw_datai <= 8'hc8 ; end
	44:  begin cw_datar <= 8'h1e ;	cw_datai <= 8'hc7 ; end
	45:  begin cw_datar <= 8'h1c ;	cw_datai <= 8'hc6 ; end
	46:  begin cw_datar <= 8'h1b ;	cw_datai <= 8'hc6 ; end
	47:  begin cw_datar <= 8'h19 ;	cw_datai <= 8'hc5 ; end
	48:  begin cw_datar <= 8'h18 ;	cw_datai <= 8'hc4 ; end
	49:  begin cw_datar <= 8'h17 ;	cw_datai <= 8'hc4 ; end
	50:  begin cw_datar <= 8'h15 ;	cw_datai <= 8'hc3 ; end
	51:  begin cw_datar <= 8'h14 ;	cw_datai <= 8'hc3 ; end
	52:  begin cw_datar <= 8'h12 ;	cw_datai <= 8'hc2 ; end
	53:  begin cw_datar <= 8'h11 ;	cw_datai <= 8'hc2 ; end
	54:  begin cw_datar <= 8'hf ;	cw_datai <= 8'hc1 ; end
	55:  begin cw_datar <= 8'he ;	cw_datai <= 8'hc1 ; end
	56:  begin cw_datar <= 8'hc ;	cw_datai <= 8'hc1 ; end
	57:  begin cw_datar <= 8'ha ;	cw_datai <= 8'hc0 ; end
	58:  begin cw_datar <= 8'h9 ;	cw_datai <= 8'hc0 ; end
	59:  begin cw_datar <= 8'h7 ;	cw_datai <= 8'hc0 ; end
	60:  begin cw_datar <= 8'h6 ;	cw_datai <= 8'hc0 ; end
	61:  begin cw_datar <= 8'h4 ;	cw_datai <= 8'hc0 ; end
	62:  begin cw_datar <= 8'h3 ;	cw_datai <= 8'hc0 ; end
	63:  begin cw_datar <= 8'h1 ;	cw_datai <= 8'hc0 ; end
	64:  begin cw_datar <= 8'h0 ;	cw_datai <= 8'hc0 ; end
	65:  begin cw_datar <= 8'hfe ;	cw_datai <= 8'hc0 ; end
	66:  begin cw_datar <= 8'hfc ;	cw_datai <= 8'hc0 ; end
	67:  begin cw_datar <= 8'hfb ;	cw_datai <= 8'hc0 ; end
	68:  begin cw_datar <= 8'hf9 ;	cw_datai <= 8'hc0 ; end
	69:  begin cw_datar <= 8'hf8 ;	cw_datai <= 8'hc0 ; end
	70:  begin cw_datar <= 8'hf6 ;	cw_datai <= 8'hc0 ; end
	71:  begin cw_datar <= 8'hf5 ;	cw_datai <= 8'hc0 ; end
	72:  begin cw_datar <= 8'hf3 ;	cw_datai <= 8'hc1 ; end
	73:  begin cw_datar <= 8'hf1 ;	cw_datai <= 8'hc1 ; end
	74:  begin cw_datar <= 8'hf0 ;	cw_datai <= 8'hc1 ; end
	75:  begin cw_datar <= 8'hee ;	cw_datai <= 8'hc2 ; end
	76:  begin cw_datar <= 8'hed ;	cw_datai <= 8'hc2 ; end
	77:  begin cw_datar <= 8'heb ;	cw_datai <= 8'hc3 ; end
	78:  begin cw_datar <= 8'hea ;	cw_datai <= 8'hc3 ; end
	79:  begin cw_datar <= 8'he8 ;	cw_datai <= 8'hc4 ; end
	80:  begin cw_datar <= 8'he7 ;	cw_datai <= 8'hc4 ; end
	81:  begin cw_datar <= 8'he6 ;	cw_datai <= 8'hc5 ; end
	82:  begin cw_datar <= 8'he4 ;	cw_datai <= 8'hc6 ; end
	83:  begin cw_datar <= 8'he3 ;	cw_datai <= 8'hc6 ; end
	84:  begin cw_datar <= 8'he1 ;	cw_datai <= 8'hc7 ; end
	85:  begin cw_datar <= 8'he0 ;	cw_datai <= 8'hc8 ; end
	86:  begin cw_datar <= 8'hdf ;	cw_datai <= 8'hc9 ; end
	87:  begin cw_datar <= 8'hdd ;	cw_datai <= 8'hc9 ; end
	88:  begin cw_datar <= 8'hdc ;	cw_datai <= 8'hca ; end
	89:  begin cw_datar <= 8'hdb ;	cw_datai <= 8'hcb ; end
	90:  begin cw_datar <= 8'hd9 ;	cw_datai <= 8'hcc ; end
	91:  begin cw_datar <= 8'hd8 ;	cw_datai <= 8'hcd ; end
	92:  begin cw_datar <= 8'hd7 ;	cw_datai <= 8'hce ; end
	93:  begin cw_datar <= 8'hd6 ;	cw_datai <= 8'hcf ; end
	94:  begin cw_datar <= 8'hd5 ;	cw_datai <= 8'hd0 ; end
	95:  begin cw_datar <= 8'hd3 ;	cw_datai <= 8'hd1 ; end
	96:  begin cw_datar <= 8'hd2 ;	cw_datai <= 8'hd2 ; end
	97:  begin cw_datar <= 8'hd1 ;	cw_datai <= 8'hd3 ; end
	98:  begin cw_datar <= 8'hd0 ;	cw_datai <= 8'hd5 ; end
	99:  begin cw_datar <= 8'hcf ;	cw_datai <= 8'hd6 ; end
	100: begin cw_datar <= 8'hce ;	cw_datai <= 8'hd7 ; end
	101: begin cw_datar <= 8'hcd ;	cw_datai <= 8'hd8 ; end
	102: begin cw_datar <= 8'hcc ;	cw_datai <= 8'hd9 ; end
	103: begin cw_datar <= 8'hcb ;	cw_datai <= 8'hdb ; end
	104: begin cw_datar <= 8'hca ;	cw_datai <= 8'hdc ; end
	105: begin cw_datar <= 8'hc9 ;	cw_datai <= 8'hdd ; end
	106: begin cw_datar <= 8'hc9 ;	cw_datai <= 8'hdf ; end
	107: begin cw_datar <= 8'hc8 ;	cw_datai <= 8'he0 ; end
	108: begin cw_datar <= 8'hc7 ;	cw_datai <= 8'he1 ; end
	109: begin cw_datar <= 8'hc6 ;	cw_datai <= 8'he3 ; end
	110: begin cw_datar <= 8'hc6 ;	cw_datai <= 8'he4 ; end
	111: begin cw_datar <= 8'hc5 ;	cw_datai <= 8'he6 ; end
	112: begin cw_datar <= 8'hc4 ;	cw_datai <= 8'he7 ; end
	113: begin cw_datar <= 8'hc4 ;	cw_datai <= 8'he8 ; end
	114: begin cw_datar <= 8'hc3 ;	cw_datai <= 8'hea ; end
	115: begin cw_datar <= 8'hc3 ;	cw_datai <= 8'heb ; end
	116: begin cw_datar <= 8'hc2 ;	cw_datai <= 8'hed ; end
	117: begin cw_datar <= 8'hc2 ;	cw_datai <= 8'hee ; end
	118: begin cw_datar <= 8'hc1 ;	cw_datai <= 8'hf0 ; end
	119: begin cw_datar <= 8'hc1 ;	cw_datai <= 8'hf1 ; end
	120: begin cw_datar <= 8'hc1 ;	cw_datai <= 8'hf3 ; end
	121: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hf5 ; end
	122: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hf6 ; end
	123: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hf8 ; end
	124: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hf9 ; end
	125: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hfb ; end
	126: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hfc ; end
	127: begin cw_datar <= 8'hc0 ;	cw_datai <= 8'hfe ; end
    endcase
  end
end
endmodule
