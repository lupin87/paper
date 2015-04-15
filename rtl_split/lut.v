module lut(out,in,bypass,shift_overf,en,clk,reset);

input [20:0]in;
input bypass;
input shift_overf;
input en;
input clk,reset;

output [20:0]out;

reg [20:0]out;

wire [20:0]reg0=21'h147;
wire [20:0]reg1=21'h28f;
wire [20:0]reg2=21'h3d7;
wire [20:0]reg3=21'h51e;
wire [20:0]reg4=21'h666;
wire [20:0]reg5=21'h7ae;
wire [20:0]reg6=21'h8f5;
wire [20:0]reg7=21'ha3d;
wire [20:0]reg8=21'hb85;
wire [20:0]reg9=21'hccc;
wire [20:0]reg10=21'he14;
wire [20:0]reg11=21'hf5c;
wire [20:0]reg12=21'h10a3;
wire [20:0]reg13=21'h11eb;
wire [20:0]reg14=21'h1333;
wire [20:0]reg15=21'h147a;
wire [20:0]reg16=21'h15c2;
wire [20:0]reg17=21'h170a;
wire [20:0]reg18=21'h1851;
wire [20:0]reg19=21'h1999;
wire [20:0]reg20=21'h1ae1;
wire [20:0]reg21=21'h1c28;
wire [20:0]reg22=21'h1d70;
wire [20:0]reg23=21'h1eb8;
wire [20:0]reg24=21'h2000;

wire [20:0]reg25=21'h2147;
wire [20:0]reg26=21'h228f;
wire [20:0]reg27=21'h23d7;
wire [20:0]reg28=21'h251e;
wire [20:0]reg29=21'h2666;
wire [20:0]reg30=21'h27ae;
wire [20:0]reg31=21'h28f5;
wire [20:0]reg32=21'h2a3d;
wire [20:0]reg33=21'h2b85;
wire [20:0]reg34=21'h2ccc;
wire [20:0]reg35=21'h2e14;
wire [20:0]reg36=21'h2f5c;
wire [20:0]reg37=21'h30a3;
wire [20:0]reg38=21'h31eb;
wire [20:0]reg39=21'h3333;
wire [20:0]reg40=21'h347a;
wire [20:0]reg41=21'h35c2;
wire [20:0]reg42=21'h370a;
wire [20:0]reg43=21'h3851;
wire [20:0]reg44=21'h3999;
wire [20:0]reg45=21'h3ae1;
wire [20:0]reg46=21'h3c28;
wire [20:0]reg47=21'h3d70;
wire [20:0]reg48=21'h3eb8;
wire [20:0]reg49=21'h3fff;

wire [20:0]reg50=21'h4147;
wire [20:0]reg51=21'h428f;
wire [20:0]reg52=21'h43d7;
wire [20:0]reg53=21'h451e;
wire [20:0]reg54=21'h4666;
wire [20:0]reg55=21'h47ae;
wire [20:0]reg56=21'h48f5;
wire [20:0]reg57=21'h4a3d;
wire [20:0]reg58=21'h4b85;
wire [20:0]reg59=21'h4ccc;
wire [20:0]reg60=21'h4e14;
wire [20:0]reg61=21'h4f5c;
wire [20:0]reg62=21'h50a3;
wire [20:0]reg63=21'h51eb;
wire [20:0]reg64=21'h5333;
wire [20:0]reg65=21'h547a;
wire [20:0]reg66=21'h55c2;
wire [20:0]reg67=21'h570a;
wire [20:0]reg68=21'h5851;
wire [20:0]reg69=21'h5999;
wire [20:0]reg70=21'h5ae1;
wire [20:0]reg71=21'h5c28;
wire [20:0]reg72=21'h5d70;
wire [20:0]reg73=21'h5be8;
wire [20:0]reg74=21'h5fff;

wire [20:0]reg75=21'h6147;
wire [20:0]reg76=21'h628f;
wire [20:0]reg77=21'h63d7;
wire [20:0]reg78=21'h651e;
wire [20:0]reg79=21'h6666;
wire [20:0]reg80=21'h67ae;
wire [20:0]reg81=21'h68f5;
wire [20:0]reg82=21'h6a3d;
wire [20:0]reg83=21'h6b85;
wire [20:0]reg84=21'h6ccc;
wire [20:0]reg85=21'h6e14;
wire [20:0]reg86=21'h6f5c;
wire [20:0]reg87=21'h70a3;
wire [20:0]reg88=21'h71eb;
wire [20:0]reg89=21'h7333;
wire [20:0]reg90=21'h747a;
wire [20:0]reg91=21'h75c2;
wire [20:0]reg92=21'h770a;
wire [20:0]reg93=21'h7851;
wire [20:0]reg94=21'h7999;
wire [20:0]reg95=21'h7ae1;
wire [20:0]reg96=21'h7c28;
wire [20:0]reg97=21'h7d70;
wire [20:0]reg98=21'h7eb8;
wire [20:0]reg99=21'h7fff;

wire [20:0]reg100=21'h8147;
wire [20:0]reg101=21'h828f;
wire [20:0]reg102=21'h83d7;
wire [20:0]reg103=21'h851e;
wire [20:0]reg104=21'h8666;
wire [20:0]reg105=21'h87ae;
wire [20:0]reg106=21'h88f5;
wire [20:0]reg107=21'h8a3d;
wire [20:0]reg108=21'h8b85;
wire [20:0]reg109=21'h8ccc;
wire [20:0]reg110=21'h8e14;
wire [20:0]reg111=21'h8f5c;
wire [20:0]reg112=21'h90a3;
wire [20:0]reg113=21'h91eb;
wire [20:0]reg114=21'h9333;
wire [20:0]reg115=21'h947a;
wire [20:0]reg116=21'h95c2;
wire [20:0]reg117=21'h970a;
wire [20:0]reg118=21'h9851;
wire [20:0]reg119=21'h9999;
wire [20:0]reg120=21'h9ae1;
wire [20:0]reg121=21'h9c28;
wire [20:0]reg122=21'h9d70;
wire [20:0]reg123=21'h9eb8;
wire [20:0]reg124=21'h9fff;

wire [20:0]reg125=21'ha147;
wire [20:0]reg126=21'ha28f;
wire [20:0]reg127=21'ha3d7;
wire [20:0]reg128=21'ha51c;
wire [20:0]reg129=21'ha666;
wire [20:0]reg130=21'ha7ae;
wire [20:0]reg131=21'ha8f5;
wire [20:0]reg132=21'haa3d;
wire [20:0]reg133=21'hab85;
wire [20:0]reg134=21'haccc;
wire [20:0]reg135=21'hae14;
wire [20:0]reg136=21'haf5c;
wire [20:0]reg137=21'hb0a3;
wire [20:0]reg138=21'hb1eb;
wire [20:0]reg139=21'hb333;
wire [20:0]reg140=21'hb47a;
wire [20:0]reg141=21'hb5c2;
wire [20:0]reg142=21'hb70a;
wire [20:0]reg143=21'hb851;
wire [20:0]reg144=21'hb999;
wire [20:0]reg145=21'hbae1;
wire [20:0]reg146=21'hbc28;
wire [20:0]reg147=21'hbd70;
wire [20:0]reg148=21'hbeb8;
wire [20:0]reg149=21'hbfff;

wire [20:0]reg150=21'hc147;
wire [20:0]reg151=21'hc28f;
wire [20:0]reg152=21'hc3d7;
wire [20:0]reg153=21'hc51e;
wire [20:0]reg154=21'hc666;
wire [20:0]reg155=21'hc7ae;
wire [20:0]reg156=21'hc8f5;
wire [20:0]reg157=21'hca3d;
wire [20:0]reg158=21'hcb85;
wire [20:0]reg159=21'hcccc;
wire [20:0]reg160=21'hce14;

always@(posedge clk or negedge reset)
begin
if(reset==0)
	out<=0;
else
begin
	if(en==1)
	begin
	if((bypass|shift_overf)==1)
	begin
		out<=0;
	end
	else
	begin
	if(in[20]==1)
	begin
	if(in<21'h1d5a23)
	begin
		out<=0;
	end
	
	if(in>=21'h1d5a23 && in<21'h1de767)
	begin
		out[20:0]<=reg0;
	end
	
	if(in>=21'h1de767 && in<21'h1e296e)
	begin
		out[20:0]<=reg1;
	end
	
	if(in>=21'h1e296e && in<21'h1e5524)
	begin
		out[20:0]<=reg2;
	end
	
	if(in>=21'h1e5524 && in<21'h1e75f4)
	begin
		out[20:0]<=reg3;
	end
	
	if(in>=21'h1e75f4 && in<21'h1e9049)
	begin
		out[20:0]<=reg4;
	end
	
	if(in>=21'h1e9049 && in<21'h1ea650)
	begin
		out[20:0]<=reg5;
	end
	
	if(in>=21'h1ea650 && in<21'h1eb947)
	begin
		out[20:0]<=reg6;
	end
	
	if(in>=21'h1eb947 && in<21'h1ec9f2)
	begin
		out[20:0]<=reg7;
	end
	
	if(in>=21'h1ec9f2 && in<21'h1ed8d5)
	begin
		out[20:0]<=reg8;
	end
	
	if(in>=21'h1ed8d5 && in<21'h1ee64c)
	begin
		out[20:0]<=reg9;
	end
	
	if(in>=21'h1ee64c && in<21'h1ef297)
	begin
		out[20:0]<=reg10;
	end
	
	if(in>=21'h1ef297 && in<21'h1efdeb)
	begin
		out[20:0]<=reg11;
	end
	
	if(in>=21'h1efdeb && in<21'h1f086c)
	begin
		out[20:0]<=reg12;
	end
	
	if(in>=21'h1f086c && in<21'h1f1239)
	begin
		out[20:0]<=reg13;
	end
	
	if(in>=21'h1f1239 && in<21'h1f1b6a)
	begin
		out[20:0]<=reg14;
	end
	
	if(in>=21'h1f1b6a && in<21'h1f2413)
	begin
		out[20:0]<=reg15;
	end
	
	if(in>=21'h1f2413 && in<21'h1f2c44)
	begin
		out[20:0]<=reg16;
	end
	
	if(in>=21'h1f2c44 && in<21'h1f340a)
	begin
		out[20:0]<=reg17;
	end
	
	if(in>=21'h1f340a && in<21'h1f3b70)
	begin
		out[20:0]<=reg18;
	end
	
	if(in>=21'h1f3b70 && in<21'h1f4280)
	begin
		out[20:0]<=reg19;
	end
	
	if(in>=21'h1f4280 && in<21'h1f4942)
	begin
		out[20:0]<=reg20;
	end
	
	if(in>=21'h1f4942 && in<21'h1f4fbd)
	begin
		out[20:0]<=reg21;
	end
	
	if(in>=21'h1f4fbd && in<21'h1f55f8)
	begin
		out[20:0]<=reg22;
	end
	
	if(in>=21'h1f55f8 && in<21'h1f5bf8)
	begin
		out[20:0]<=reg23;
	end
	
	if(in>=21'h1f5bf8 && in<21'h1f61c2)
	begin
		out[20:0]<=reg24;
	end
	
	if(in>=21'h1f61c2 && in<21'h1f6759)
	begin
		out[20:0]<=reg25;
	end
	
	if(in>=21'h1f6759 && in<21'h1f6cc2)
	begin
		out[20:0]<=reg26;
	end
	
	if(in>=21'h1f6cc2 && in<21'h1f7200)
	begin
		out[20:0]<=reg27;
	end
	
	if(in>=21'h1f7200 && in<21'h1f7716)
	begin
		out[20:0]<=reg28;
	end
	
	if(in>=21'h1f7716 && in<21'h1f7c06)
	begin
		out[20:0]<=reg29;
	end
	
	if(in>=21'h1f7c06 && in<21'h1f80d4)
	begin
		out[20:0]<=reg30;
	end
	
	if(in>=21'h1f80d4 && in<21'h1f8580)
	begin
		out[20:0]<=reg31;
	end
	
	if(in>=21'h1f8580 && in<21'h1f8a0e)
	begin
		out[20:0]<=reg32;
	end
	
	if(in>=21'h1f8a0e && in<21'h1f8e7f)
	begin
		out[20:0]<=reg33;
	end
	
	if(in>=21'h1f8e7f && in<21'h1f92d5)
	begin
		out[20:0]<=reg34;
	end
	
	if(in>=21'h1f92d5 && in<21'h1f9711)
	begin
		out[20:0]<=reg35;
	end
	
	if(in>=21'h1f9711 && in<21'h1f9b34)
	begin
		out[20:0]<=reg36;
	end
	
	if(in>=21'h1f9b34 && in<21'h1f9f41)
	begin
		out[20:0]<=reg37;
	end
	
	if(in>=21'h1f9f41 && in<21'h1fa338)
	begin
		out[20:0]<=reg38;
	end
	
	if(in>=21'h1fa338 && in<21'h1fa71a)
	begin
		out[20:0]<=reg39;
	end
	
	if(in>=21'h1fa71a && in<21'h1faae8)
	begin
		out[20:0]<=reg40;
	end
	
	if(in>=21'h1faae8 && in<21'h1faea3)
	begin
		out[20:0]<=reg41;
	end
	
	if(in>=21'h1faea3 && in<21'h1fb24d)
	begin
		out[20:0]<=reg42;
	end
	
	if(in>=21'h1fb24d && in<21'h1fb5e6)
	begin
		out[20:0]<=reg43;
	end
	
	if(in>=21'h1fb5e6 && in<21'h1fb96e)
	begin
		out[20:0]<=reg44;
	end
	
	if(in>=21'h1fb96e && in<21'h1fbce7)
	begin
		out[20:0]<=reg45;
	end
	
	if(in>=21'h1fbce7 && in<21'h1fc051)
	begin
		out[20:0]<=reg46;
	end
	
	if(in>=21'h1fc051 && in<21'h1fc3ac)
	begin
		out[20:0]<=reg47;
	end
	
	if(in>=21'h1fc3ac && in<21'h1fc6fa)
	begin
		out[20:0]<=reg48;
	end
	
	if(in>=21'h1fc6fa && in<21'h1fca3b)
	begin
		out[20:0]<=reg49;
	end
	
	if(in>=21'h1fca3b && in<21'h1fcd6f)
	begin
		out[20:0]<=reg50;
	end
	
	if(in>=21'h1fcd6f && in<21'h1fd097)
	begin
		out[20:0]<=reg51;
	end
	
	if(in>=21'h1fd097 && in<21'h1fd3b4)
	begin
		out[20:0]<=reg52;
	end
	
	if(in>=21'h1fd3b4 && in<21'h1fd6c5)
	begin
		out[20:0]<=reg53;
	end
	
	if(in>=21'h1fd6c5 && in<21'h1fd9cc)
	begin
		out[20:0]<=reg54;
	end
	
	if(in>=21'h1fd9cc && in<21'h1fdcc8)
	begin
		out[20:0]<=reg55;
	end
	
	if(in>=21'h1fdcc8 && in<21'h1fdfba)
	begin
		out[20:0]<=reg56;
	end
	
	if(in>=21'h1fdfba && in<21'h1fe2a3)
	begin
		out[20:0]<=reg57;
	end
	
	if(in>=21'h1fe2a3 && in<21'h1fe582)
	begin
		out[20:0]<=reg58;
	end
	
	if(in>=21'h1fe582 && in<21'h1fe858)
	begin
		out[20:0]<=reg59;
	end
	
	if(in>=21'h1fe858 && in<21'h1feb26)
	begin
		out[20:0]<=reg60;
	end
	
	if(in>=21'h1fe858 && in<21'h1fedeb)
	begin
		out[20:0]<=reg61;
	end
	
	if(in>=21'h1fedeb && in<21'h1ff0a8)
	begin
		out[20:0]<=reg62;
	end
	
	if(in>=21'h1ff0a8 && in<21'h1ff35d)
	begin
		out[20:0]<=reg63;
	end
	
	if(in>=21'h1ff35d && in<21'h1ff60b)
	begin
		out[20:0]<=reg64;
	end
	
	if(in>=21'h1ff60b && in<21'h1ff8b1)
	begin
		out[20:0]<=reg65;
	end
	
	if(in>=21'h1ff8b1 && in<21'h1ffb50)
	begin
		out[20:0]<=reg66;
	end
	
	if(in>=21'h1ffb50)
	begin
		out[20:0]<=reg67;
	end
	
	end
	else
	begin
	if(in<21'h79)
	begin
		out[20:0]<=reg68;
	end
	
	if(in>=21'h79 && in<21'h304)
	begin
		out[20:0]<=reg69;
	end
	if(in>=21'h304 && in<21'h588)
	begin
		out[20:0]<=reg70;
	end
	
	if(in>=21'h588 && in<21'h807)
	begin
		out[20:0]<=reg71;
	end
	
	if(in>=21'h807 && in<21'ha7f)
	begin
		out[20:0]<=reg72;
	end
	
	if(in>=21'ha7f && in<21'hcf2)
	begin
		out[20:0]<=reg73;
	end
	
	if(in>=21'hcf2 && in<21'hf5f)
	begin
		out[20:0]<=reg74;
	end
	
	if(in>=21'hf5f && in<21'h11c7)
	begin
		out[20:0]<=reg75;
	end
	
	if(in>=21'h11c7 && in<21'h1429)
	begin
		out[20:0]<=reg76;
	end
	
	if(in>=21'h1429 && in<21'h1686)
	begin
		out[20:0]<=reg77;
	end
	
	if(in>=21'h1686 && in<21'h18de)
	begin
		out[20:0]<=reg78;
	end
	
	if(in>=21'h18de && in<21'h1b31)
	begin
		out[20:0]<=reg79;
	end
	
	if(in>=21'h1b31 && in<21'h1d7f)
	begin
		out[20:0]<=reg80;
	end
	
	if(in>=21'h1d7f && in<21'h1fc9)
	begin
		out[20:0]<=reg81;
	end
	
	if(in>=21'h1fc9 && in<21'h220e)
	begin
		out[20:0]<=reg82;
	end
	
	if(in>=21'h220e && in<21'h244e)
	begin
		out[20:0]<=reg83;
	end
	
	if(in>=21'h244e && in<21'h268b)
	begin
		out[20:0]<=reg84;
	end
	
	if(in>=21'h268b && in<21'h28c3)
	begin
		out[20:0]<=reg85;
	end
	
	if(in>=21'h28c3 && in<21'h2af7)
	begin
		out[20:0]<=reg86;
	end
	
	if(in>=21'h2af7 && in<21'h2d27)
	begin
		out[20:0]<=reg87;
	end
	
	if(in>=21'h2d27 && in<21'h2f53)
	begin
		out[20:0]<=reg88;
	end
	
	if(in>=21'h2f53 && in<21'h317b)
	begin
		out[20:0]<=reg89;
	end
	
	if(in>=21'h317b && in<21'h339f)
	begin
		out[20:0]<=reg90;
	end
	
	if(in>=21'h339f && in<21'h35c0)
	begin
		out[20:0]<=reg91;
	end

	if(in>=21'h35c0 && in<21'h37dd)
	begin
		out[20:0]<=reg92;
	end
	
	if(in>=21'h37dd && in<21'h39f7)
	begin
		out[20:0]<=reg93;
	end
	
	if(in>=21'h39f7 && in<21'h3c0d)
	begin
		out[20:0]<=reg94;
	end
	
	if(in>=21'h3c0d && in<21'h3e20)
	begin
		out[20:0]<=reg95;
	end
	
	if(in>=21'h3e20 && in<21'h4030)
	begin
		out[20:0]<=reg96;
	end
	
	if(in>=21'h4030 && in<21'h423d)
	begin
		out[20:0]<=reg97;
	end
	
	if(in>=21'h423d && in<21'h4446)
	begin
		out[20:0]<=reg98;
	end
	
	if(in>=21'h4446 && in<21'h464c)
	begin
		out[20:0]<=reg99;
	end
	
	if(in>=21'h464c && in<21'h4850)
	begin
		out[20:0]<=reg100;
	end
	
	if(in>=21'h4850 && in<21'h4a50)
	begin
		out[20:0]<=reg101;
	end
	
	if(in>=21'h4a50 && in<21'h4c4e)
	begin
		out[20:0]<=reg102;
	end
	
	if(in>=21'h4c4e && in<21'h4e49)
	begin
		out[20:0]<=reg103;
	end
	
	if(in>=21'h4e49 && in<21'h5041)
	begin
		out[20:0]<=reg104;
	end
	
	if(in>=21'h5041 && in<21'h5236)
	begin
		out[20:0]<=reg105;
	end
	
	if(in>=21'h5236 && in<21'h5429)
	begin
		out[20:0]<=reg106;
	end
	
	if(in>=21'h5429 && in<21'h5619)
	begin
		out[20:0]<=reg107;
	end
	
	if(in>=21'h5619 && in<21'h5807)
	begin
		out[20:0]<=reg108;
	end
	
	if(in>=21'h5807 && in<21'h59f2)
	begin
		out[20:0]<=reg109;
	end
	
	if(in>=21'h59f2 && in<21'h5bdb)
	begin
		out[20:0]<=reg110;
	end
	
	if(in>=21'h5bdb && in<21'h5dc1)
	begin
		out[20:0]<=reg111;
	end
	
	if(in>=21'h5dc1 && in<21'h5fa5)
	begin
		out[20:0]<=reg112;
	end
	
	if(in>=21'h5fa5 && in<21'h6187)
	begin
		out[20:0]<=reg113;
	end
	
	if(in>=21'h6187 && in<21'h6366)
	begin
		out[20:0]<=reg114;
	end
	
	if(in>=21'h6366 && in<21'h6544)
	begin
		out[20:0]<=reg115;
	end
	
	if(in>=21'h6544 && in<21'h671f)
	begin
		out[20:0]<=reg116;
	end
	
	if(in>=21'h671f && in<21'h68f8)
	begin
		out[20:0]<=reg117;
	end
	
	if(in>=21'h68f8 && in<21'h6acf)
	begin
		out[20:0]<=reg118;
	end
	
	if(in>=21'h6acf && in<21'h6ca4)
	begin
		out[20:0]<=reg119;
	end
	
	if(in>=21'h6ca4 && in<21'h6e77)
	begin
		out[20:0]<=reg120;
	end
	
	if(in>=21'h6e77 && in<21'h7048)
	begin
		out[20:0]<=reg121;
	end
	
	if(in>=21'h7048 && in<21'h7217)
	begin
		out[20:0]<=reg122;
	end
	
	if(in>=21'h7217 && in<21'h73e4)
	begin
		out[20:0]<=reg123;
	end
	
	if(in>=21'h73e4 && in<21'h75af)
	begin
		out[20:0]<=reg124;
	end
	
	if(in>=21'h75af && in<21'h7778)
	begin
		out[20:0]<=reg125;
	end
	
	if(in>=21'h7778 && in<21'h7940)
	begin
		out[20:0]<=reg126;
	end
	
	if(in>=21'h7940 && in<21'h7b06)
	begin
		out[20:0]<=reg127;
	end
	
	if(in>=21'h7b06 && in<21'h7cca)
	begin
		out[20:0]<=reg128;
	end
	
	if(in>=21'h7cca && in<21'h7e8d)
	begin
		out[20:0]<=reg129;
	end
	
	if(in>=21'h7e8d && in<21'h804d)
	begin
		out[20:0]<=reg130;
	end
	
	if(in>=21'h804d && in<21'h820c)
	begin
		out[20:0]<=reg131;
	end
	
	if(in>=21'h820c && in<21'h83ca)
	begin
		out[20:0]<=reg132;
	end
	
	if(in>=21'h83ca && in<21'h8586)
	begin
		out[20:0]<=reg133;
	end
	
	if(in>=21'h8586 && in<21'h8740)
	begin
		out[20:0]<=reg134;
	end
	
	if(in>=21'h8740 && in<21'h88f9)
	begin
		out[20:0]<=reg135;
	end
	
	if(in>=21'h88f9 && in<21'h8ab0)
	begin
		out[20:0]<=reg136;
	end
	
	if(in>=21'h8ab0 && in<21'h8c66)
	begin
		out[20:0]<=reg137;
	end
	
	if(in>=21'h8c66 && in<21'h8e1b)
	begin
		out[20:0]<=reg138;
	end
	
	if(in>=21'h8e1b && in<21'h8fce)
	begin
		out[20:0]<=reg139;
	end
	
	if(in>=21'h8fce && in<21'h917f)
	begin
		out[20:0]<=reg140;
	end
	
	if(in>=21'h917f && in<21'h932f)
	begin
		out[20:0]<=reg141;
	end
	
	if(in>=21'h932f && in<21'h94fe)
	begin
		out[20:0]<=reg142;
	end
	
	if(in>=21'h94de && in<21'h968b)
	begin
		out[20:0]<=reg143;
	end
	
	if(in>=21'h94de && in<21'h9837)
	begin
		out[20:0]<=reg144;
	end
	
	if(in>=21'h9837 && in<21'h99e2)
	begin
		out[20:0]<=reg145;
	end
	
	if(in>=21'h99e2 && in<21'h9b8c)
	begin
		out[20:0]<=reg146;
	end
	
	if(in>=21'h9b8c && in<21'h9d34)
	begin
		out[20:0]<=reg147;
	end
	
	if(in>=21'h9d34 && in<21'h9edb)
	begin
		out[20:0]<=reg148;
	end
	
	if(in>=21'h9edb && in<21'ha081)
	begin
		out[20:0]<=reg149;
	end
	
	if(in>=21'ha081 && in<21'ha225)
	begin
		out[20:0]<=reg150;
	end
	
	if(in>=21'ha225 && in<21'ha3c9)
	begin
		out[20:0]<=reg151;
	end
	
	if(in>=21'ha3c9 && in<21'ha56b)
	begin
		out[20:0]<=reg152;
	end
	
	if(in>=21'ha56b && in<21'ha70c)
	begin
		out[20:0]<=reg153;
	end
	
	if(in>=21'ha70c && in<21'ha8ac)
	begin
		out[20:0]<=reg154;
	end
	
	if(in>=21'ha8ac && in<21'haa4b)
	begin
		out[20:0]<=reg155;
	end
	
	if(in>=21'haa4b && in<21'habe9)
	begin
		out[20:0]<=reg156;
	end
	
	if(in>=21'habe9 && in<21'had85)
	begin
		out[20:0]<=reg157;
	end
	
	if(in>=21'had85 && in<21'haf21)
	begin
		out[20:0]<=reg158;
	end
	
	if(in>=21'haf21 && in<21'hb0bc)
	begin
		out[20:0]<=reg159;
	end
	
	if(in>=21'hb0bc)
	begin
		out[20:0]<=reg160;
	end
	
	end
	end
	end
end
end
endmodule
