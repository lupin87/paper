module add39(out,A,B);//S=A+B

parameter WIDTH=38;

input      [WIDTH:0]A,B;

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = C[WIDTH+1];
end
endmodule
module addmel(regffteout,regmelout,out,en,sel,new1,clk,reset);

input [40:0]regffteout;//41 bits from Spectrum Register
input [44:0]regmelout;//45 bits from Power Coefficient Register
input sel;//sel=1:out_new=regmel+out_old;sel=0:out_new=regffte+out_old
input en,new1,clk,reset;

output [45:0]out;

reg [45:0]out;
wire [45:0]tout;
wire [45:0]in1,in2;
wire [46:0]tout1;

cla46 cla46(tout1,in1,in2);

assign in1=(sel)?{1'b0,regmelout}:{5'b0,regffteout};//mo rong cho du 46 bits
assign tout=tout1[45:0];
assign in2=out;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(en==1)
    begin
      if(new1==1)
      begin
        out<={5'b0,regffteout};//don't care sel
      end
      else
      begin
        //new1=0&sel=0:out_new=out_old + {5'b0,regffteout}
        //new1=0&sel=1:out_new=out_old + {1'b0,regmelout}
        out<=tout;
      end
    end
  end
end
endmodule
module addsubdct(in,out,en,sub,new1,clk,reset);//muldct sum

input [22:0]in;//23bit from muldct
input en,sub,new1,clk,reset;

output [27:0]out;//23bit sum,23+5=28;them 5bit-->cong 23 lan (K=23)<-->*23-->ket qua them 5 bits
reg [27:0]out;
wire [27:0]tout,tin;//tout=out+/-tin

assign tin={{5{in[22]}},in};

cla28 cla28(tout,sub,out,tin);//sub=1:tout=out-tin;sub=0:tout=out+tin

//new1=0,sub=0:out_new = out_old + in
//new1=0,sub=1:out_new = out_old - in
//new1=1,sub=0:out_new = in
//new1=1,sub=1:out_new = in
always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(en==1)
    begin
      if(new1==1)
      begin
        out<=tin;
      end
      else
      begin
        out<=tout;
      end
    end
  end
end
endmodule
module addsubfft(regfftoutr,regfftouti,cmoutr,cmouti,outr,outi,en,sel,clk,reset);

input [39:0]regfftoutr,regfftouti;//part real x[0],part imaginary x[0]

//cmoutr=real{x[1]*W}
//cmouti=image{x[1]*W}
input [38:0]cmoutr,cmouti;//from comadd
input sel;//sel=1,regfft+/-regfft;sel=0,regfft+/-cmout
input en,clk,reset;

//outr:+:-->real{X[0]};-:-->real{X[1]}
//outi:+:-->image{X[0]};-:-->image{X[1]}
output [39:0]outr,outi;
reg [39:0]outr,outi;//FFT (part real, part imaginary)

wire [39:0]toutr,touti;
wire [39:0]inr1,inr2,ini1,ini2;

reg [39:0]inr1t,ini1t,inr2t,ini2t;

reg cin;
reg sa,sb;
reg state;


//cin=0:toutr=inr2+inr1;touti=ini2+ini1
//cin=1:toutr=inr2-inr1;touti=ini2-ini1
cla40 cla40_r(toutr,cin,inr2,inr1);
cla40 cla40_i(touti,cin,ini2,ini1);

assign inr1=(sa|sb)?inr1t:{cmoutr[38],cmoutr};
assign ini1=(sa|sb)?ini1t:{cmouti[38],cmouti};

assign inr2=(sb)?inr2t:regfftoutr;
assign ini2=(sb)?ini2t:regfftouti;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    outr<=0;
    outi<=0;
    inr1t<=0;
    ini1t<=0;
    inr2t<=0;
    ini2t<=0;
    cin<=0;
    sa<=0;
    sb<=0;
    state<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(sel==1)
      begin
        inr1t<=regfftoutr;
        ini1t<=regfftouti;
        sa<=1;
        state<=state;
      end
      if(en==1)
      begin
        outr<=toutr;
        outi<=touti;
        if(sa==1)
        begin
          inr1t<=inr1t;
          ini1t<=ini1t;
        end
        else
        begin
          inr1t<={cmoutr[38],cmoutr};
          ini1t<={cmouti[38],cmouti};
          inr2t<=regfftoutr;
          ini2t<=regfftouti;
          sb<=1;
        end
        cin<=1;
        state<=1;
      end
    end
    1:
    begin
      outr<=toutr;
      outi<=touti;
      cin<=0;
      sa<=0;
      sb<=0;
      state<=0;
    end
    endcase
  end
end
endmodule
module booth16(out1,in1,in2);
parameter zee=17'bz;
input [2:0]in1;
input [15:0]in2;
output [16:0]out1;
assign out1=(in1==3'b000)?17'b0:zee;
assign out1=(in1==3'b001)?{in2[15],in2}:zee;
assign out1=(in1==3'b010)?{in2[15],in2}:zee;
assign out1=(in1==3'b011)?{in2[15:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[15:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[15],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[15],in2})+1'b1:zee;
assign out1=(in1==3'b111)?17'b0:zee;
endmodule
module booth17(out1,in1,in2);
parameter zee=18'bz;
input [2:0]in1;
input [16:0]in2;
output [17:0]out1;
assign out1=(in1==3'b000)?18'b0:zee;
assign out1=(in1==3'b001)?{in2[16],in2}:zee;
assign out1=(in1==3'b010)?{in2[16],in2}:zee;
assign out1=(in1==3'b011)?{in2[16:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[16:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[16],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[16],in2})+1'b1:zee;
assign out1=(in1==3'b111)?18'b0:zee;
endmodule
module booth31(out1,in1,in2);
parameter zee=32'bz;
input [2:0]in1;
input [30:0]in2;
output [31:0]out1;
assign out1=(in1==3'b000)?32'b0:zee;
assign out1=(in1==3'b001)?{in2[30],in2}:zee;
assign out1=(in1==3'b010)?{in2[30],in2}:zee;
assign out1=(in1==3'b011)?{in2[30:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[30:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[30],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[30],in2})+1'b1:zee;
assign out1=(in1==3'b111)?32'b0:zee;
endmodule
module cadder(sumout,overflow,en,in_sel,mul_in,regs_in,rega,regx_in,shift_in,clk,reset);

input [20:0]regs_in;//register for all states
input [20:0]mul_in;//multiplier out, 16bit///////////////////sua [15:0]-->[20:0]
input [20:0]regx_in;//register for mixture complement
input [15:0]rega;//constant
input [20:0]shift_in;
input [1:0]in_sel;
input en;
input clk;
input reset;

output [25:0]sumout;//////////////////////////////sua tu 21bit-->26bit
output overflow;

reg [25:0]sumout;
reg overflow;

wire [25:0]p;
wire [24:0]g;
wire [25:0]carout;
wire [25:0]in1,in2;
wire [25:0]sumtmp;
wire overf;

assign in1=(in_sel==2'b00)?{{5{mul_in[20]}},mul_in}:26'bz;
assign in1=(in_sel==2'b01)?{{5{mul_in[20]}},mul_in}:26'bz;
assign in1=(in_sel==2'b10)?{{10{rega[15]}},rega}:26'bz;
assign in1=(in_sel==2'b11)?{{5{regx_in[20]}},regx_in}:26'bz;

assign in2=(in_sel==2'b00)?{{5{regs_in[20]}},regs_in}:26'bz;
assign in2=(in_sel==2'b01)?sumout:26'bz;
assign in2=(in_sel==2'b10)?sumout:26'bz;
assign in2=(in_sel==2'b11)?{{5{shift_in[20]}},shift_in}:26'bz;

assign p=in1^in2;
assign g=in1[24:0]&in2[24:0];

assign carout[0]=0;
assign carout[25:1]=g[24:0]|p[24:0]&carout[24:0];
assign sumtmp=p^carout;

assign overf=~(in1[25]^in2[25])&(in1[25]^sumtmp[25]);

always@(posedge clk or negedge reset)
begin
if(reset==0)
	begin
		sumout<=0;
		overflow<=0;
	end
else
	begin
		if(en==1)
		begin
			sumout<=sumtmp;
			overflow<=overf;
		end
	end
end
endmodule
module cla16log(S,A,B);
parameter WIDTH=16;
input      [WIDTH-1:0]A,B;
output reg [WIDTH:0]S;
reg [WIDTH:0] C;
reg [WIDTH-1:0] G,P;
integer ii;
 
always @* begin
  C[0]      = 1'b0;
  for(ii=0;ii<WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH] = C[WIDTH];
end
endmodule
module cla16(sumout,overf,in1,in2,en,clk,reset);

/*-------carry look ahead adder--------*/

input [15:0]in1;
input [15:0]in2;
input en;
input clk;
input reset;

output [15:0]sumout;
output reg overf;

reg [15:0]sumout;
wire [15:0]p;
wire [14:0]g;
wire [15:0]carout;
wire [15:0]sumtmp;

assign p=in1^in2;
assign g=in1[14:0]&in2[14:0];
assign carout[0]=0;
assign carout[15:1]=g[14:0]|p[14:0]&carout[14:0];
assign sumtmp=p[15:0]^carout[15:0];
//assign overf=~(in1[15]^in2[15])&(in1[15]^sumtmp[15]);

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		sumout<=0;
		overf<=0;//them
	end
	else
	begin
		if(en==1)
		begin
			sumout<=sumtmp;
			overf<=~(in1[15]^in2[15])&(in1[15]^sumtmp[15]);//them
		end
	end
end
endmodule
module cla20d(out,in,A,B);//out=A-B=A+bu2(B)=A+[bu1(B)+1]

parameter WIDTH=19;

input      [WIDTH:0]A,B;
input in;//in=0:out=A+B;in=1:out=A-B

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
wire [WIDTH:0]Bs;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign Bs=({(WIDTH+1){in}}^(B))+in;
assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & Bs[ii];
    P[ii] = A[ii] ^ Bs[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = in^C[WIDTH+1];
end
endmodule
module cla20win(out,A,B);//out=A+B

parameter WIDTH=19;

input      [WIDTH:0]A,B;

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = C[WIDTH+1];
end
endmodule
module cla23md(out,A,B);//out=A+B

parameter WIDTH=22;

input      [WIDTH:0]A,B;

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = C[WIDTH+1];
end
endmodule
module cla28(out,in,A,B);//out=A-B=A+bu2(B)=A+[bu1(B)+1]

parameter WIDTH=27;

input      [WIDTH:0]A,B;
input in;//in=0:out=A+B;in=1:out=A-B

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
wire [WIDTH:0]Bs;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign Bs=({(WIDTH+1){in}}^(B))+in;
assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & Bs[ii];
    P[ii] = A[ii] ^ Bs[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = in^C[WIDTH+1];
end
endmodule
module cla31squ(out,A,B);//out=A+B

parameter WIDTH=30;

input      [WIDTH:0]A,B;

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = C[WIDTH+1];
end
endmodule
module cla32(S,A,B);

parameter WIDTH=32;
input      [WIDTH-1:0]A,B;
output reg [WIDTH:0]S;
reg [WIDTH:0] C;
reg [WIDTH-1:0] G,P;
integer ii;
 
always @* begin
	C[0] = 1'b0;
  for(ii=0;ii<WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH] = C[WIDTH];
end
endmodule
module cla38cm(S,A,B);
parameter WIDTH=38;
input      [WIDTH-1:0]A,B;
output reg [WIDTH:0]S;
reg [WIDTH:0] C;
reg [WIDTH-1:0] G,P;
integer ii;
 
always @* begin
  for(ii=0;ii<WIDTH;ii=ii+1) 
  begin
  C[0]      = 1'b0;
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH] = C[WIDTH];
end
endmodule
module cla39e(S,A,B);
parameter WIDTH=39;
input      [WIDTH-1:0]A,B;
output reg [WIDTH:0]S;
reg [WIDTH:0] C;
reg [WIDTH-1:0] G,P;
integer ii;
 
always @* begin
  C[0]      = 1'b0;
  for(ii=0;ii<WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH] = C[WIDTH];
end
endmodule
module cla40(out,in,A,B);//out=A-B=A+bu2(B)=A+[bu1(B)+1]

parameter WIDTH=39;

input      [WIDTH:0]A,B;
input in;//in=0:out=A+B;in=1:out=A-B

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
wire [WIDTH:0]Bs;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign Bs=({(WIDTH+1){in}}^(B))+in;
assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & Bs[ii];
    P[ii] = A[ii] ^ Bs[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = in^C[WIDTH+1];
end
endmodule
module cla41(S,A,B);

parameter WIDTH=41;
input      [WIDTH-1:0]A,B;
output reg [WIDTH:0]S;
reg [WIDTH:0] C;
reg [WIDTH-1:0] G,P;
integer ii;
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH] = C[WIDTH];
end
endmodule
module cla46(S,A,B);

parameter WIDTH=46;
input      [WIDTH-1:0]A,B;
output reg [WIDTH:0]S;
reg [WIDTH:0] C;
reg [WIDTH-1:0] G,P;
integer ii;
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH] = C[WIDTH];
end
endmodule
module cla4i(S,Cin,A,B,PG,GG);

input [3:0]A,B;
input Cin;

output [3:0]S;
output PG,GG;

wire [3:0]C,P,G;

MYCLALOG clalog(P,G,Cin,,C[3:1],PG,GG);
MYPFA pfa0(A[0],B[0],C[0],S[0],P[0],G[0]);
MYPFA pfa1(A[1],B[1],C[1],S[1],P[1],G[1]);
MYPFA pfa2(A[2],B[2],C[2],S[2],P[2],G[2]);
MYPFA pfa3(A[3],B[3],C[3],S[3],P[3],G[3]);

assign C[0]=Cin;

endmodule
module comadd(out1,out2,out3,out4,outr,outi,en,shift,clk,reset);

input [38:0]out1,out2,out3,out4;//39bit 2's complement
input en,shift;
input clk,reset;

output [38:0]outr,outi;//outr,outi: 39bit 2's complement;outr=ac-bd,outi=bc+ad

reg [38:0]outr,outi;
wire [38:0]toutr,touti;

sub39 sub39(toutr,out1,out2);//out1-out2
add39 add39(touti,out3,out4);//out3+out4

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    outr<=0;
    outi<=0;
  end
  else
  begin
    if(en==1)
    begin
      if(shift==1)
      begin
        outr<={{6{toutr[38]}},toutr[38:6]};//nhan ngo vao voi 64 (xu ly so fix-point)
        outi<={{6{touti[38]}},touti[38:6]};//nhan ngo vao voi 64 (xu ly so fix-point)
      end
      else//shift=0;outr=out1-out2,outi=out3+out4
      begin
        outr<=toutr;
        outi<=touti;
      end
    end
  end
end
endmodule
module complexm(in1a,in1b,in2c,in2d,out1,out2,out3,out4,en,clk,reset);//complex multiplication

input [30:0]in1a,in1b;//in1a,in1b:input a and b in a+jb from regfft,31bit 2's complement
input [7:0] in2c,in2d;//in2c,in2d:input c and d in c+jd from cfft, 8bit 2's complement
input en;
input clk,reset;

//out1=a*c;out2=b*d;out3=b*c;out4=a*d
output [38:0]out1,out2,out3,out4;

reg [38:0]out1,out2,out3,out4;
wire [37:0]cout1,mulout1,cout2,mulout2,cout3,mulout3,cout4,mulout4;
reg [37:0]rcout1,rmulout1,rcout2,rmulout2,rcout3,rmulout3,rcout4,rmulout4;
wire [37:0]tout1,tout2,tout3,tout4;

reg state;
//ac
multi38_1 multi38_1a(in1a,in2c,cout1,mulout1);
multi38_2 multi38_2a(rcout1,rmulout1,tout1);
//bd
multi38_1 multi38_1b(in1b,in2d,cout2,mulout2);
multi38_2 multi38_2b(rcout2,rmulout2,tout2);
//bc
multi38_1 multi38_1c(in1b,in2c,cout3,mulout3);
multi38_2 multi38_2c(rcout3,rmulout3,tout3);
//ad
multi38_1 multi38_1d(in1a,in2d,cout4,mulout4);
multi38_2 multi38_2d(rcout4,rmulout4,tout4);

always@(posedge clk or negedge reset)
begin
  if(reset==0)
    begin
    state<=0;
    rcout1<=0;
    rmulout1<=0;
    rcout2<=0;
    rmulout2<=0;
    rcout3<=0;
    rmulout3<=0;
    rcout4<=0;
    rmulout4<=0;
    out1<=0;
    out2<=0;
    out3<=0;
    out4<=0;
    end
    else
    begin
      case(state)
      0:
      begin
        if(en==1)
        begin
          rcout1<=cout1;
          rmulout1<=mulout1;
          rcout2<=cout2;
          rmulout2<=mulout2;
          rcout3<=cout3;
          rmulout3<=mulout3;
          rcout4<=cout4;
          rmulout4<=mulout4;
          state<=1;
          end
        end
        1:
        begin
          out1<={tout1[37],tout1};
          out2<={tout2[37],tout2};
          out3<={tout3[37],tout3};
          out4<={tout4[37],tout4};
          state<=0;
        end
        endcase
      end
    end
endmodule
module csa21win(cout,sumout,in1,in2,in3);
input[20:0]in1,in2,in3;
output[20:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
module csa23md(cout,sumout,in1,in2,in3);
input[22:0]in1,in2,in3;
output[22:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
module csa31squ(cout,sumout,in1,in2,in3);
input[30:0]in1,in2,in3;
output[30:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
module csa32(cout,sumout,in1,in2,in3);
input[31:0]in1,in2,in3;
output[31:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
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
module delta(out,in,new1,sub,shift,en,clk,reset);

input [15:0]in;//ceptrum from regc
input new1,sub,shift,en,clk,reset;

output [19:0]out;

reg [19:0]out;
wire [19:0]sum,tin;

assign tin={{4{in[15]}},in};

//new1=0,sub=0,shif=0:out_new = out_old + in
//new1=0,sub=1,shif=0:out_new = out_old - in
//new1=1,sub=x,shif=x:out_new = in; x:don't care


//new1=0,sub=0,shif=1:out_new = 2*(out_old + in)
//new1=0,sub=1,shif=1:out_new = 2*(out_old - in)
//new1=1,sub=x,shif=x:out_new = in; x:don't care

cla20d cla20d(sum,sub,out,tin);//sub=1:tout=out-tin;sub=0:tout=out+tin

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(en==1)
    begin
      if(new1==1)
      begin
        out<={{4{in[15]}},in};
      end
      else if(shift==1)
      begin
        out<={sum[18:0],1'b0};
      end
      else
      begin
        out<=sum;
      end
    end
  end
end
endmodule
module eadder(sumout,en,new1,sel,mul_in,ereg,clk,reset);

input [30:0]mul_in;//multiplier out,31bit (from square block)
input [38:0]ereg;//ereg for the half frame energy, 39bit 2's complement
input sel;//0:sumout+mul_in,1:sumout+ereg
input new1;//start one subframe
input en;
input clk;
input reset;

output [38:0]sumout;//39bit 2's complement

reg [38:0]sumout;
wire [38:0]a;
wire [38:0]sum;
//reg [1:0]state;

assign a=(sel)?ereg:{8'b0,mul_in};//chen them 8'b0 cho du 39 bits

cla39e cla39e(sum,a,sumout);

always@(posedge clk or negedge reset)
begin
if(reset==0)
begin
  sumout<=0;
end
else
begin
  if(en==1)
  begin
    if(new1==1)//start one subframe
    begin
      sumout<={8'b0,mul_in};
    end
    else //new1=0
    begin
      sumout<=sum;//sumout_new=sumout_old+a (where a=(sel)?ereg:{8'b0,mul_in})
    end
  end
end
end
endmodule
module ereg(in,out,we,clk,reset);

input [38:0]in;//39bit
input we;
input clk;
input reset;

output [38:0]out;//39bit

reg [38:0]out;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(we==1)
      out<=in;
    end
  end
endmodule
module fecon(ram_addr,ram_addrt,
      square_en,
      eadder_en,eadder_new,eadder_sel,
      ereg_we,
      log_en,log_sel,log_overf,
      preemp_en,preemp_en_out,preemp_new,preemp_state_en,
      cham_addr,
      win_en,win_en_mask,
      regfft_wren,regfft_addr,regfft_insel,regfft_clear,
      cfft_addr,
      cm_en,comadd_en,cm_shift,
      addsubfft_en,addsubfft_sel,addsubfft_shift,
      sroot_en,
      regffte_addr,regffte_wren,
      addmel_en,addmel_sel,addmel_new,
      regmel_addr,regmel_wren,
      regdct_addr,regdct_wren,
      cdct_addr,
      muldct_en,
      addsubdct_en,addsubdct_sub,addsubdct_new,
      regc_addr,regc_wren,regc_sel,
      reglog_addr, reglog_wren,
      delta_new,delta_sub,delta_shift,delta_en,
      regcep_addr,regcep_wren,
      framenum,
      start,ready,fefinish,fs,clk,reset);

output [14:0]ram_addr;//80*256
output ram_addrt;//16bit in 2 8bit
reg [14:0]ram_addr;
reg [31:0]ram_addr_st;
reg ram_addrt;

output square_en;

output eadder_en,eadder_sel,eadder_new;
reg eadder_en,eadder_sel,eadder_new,eadder_new1;

output ereg_we;
reg ereg_we;

input log_overf;
output log_en,log_sel;
reg log_sel;

output preemp_en,preemp_new;
output preemp_en_out;
output preemp_state_en;
reg preemp_en,preemp_new;

output [7:0]cham_addr; //Thuong
reg [7:0]cham_addr;

output win_en;
output win_en_mask;
reg win_en;

output regfft_wren;
output [7:0]regfft_addr;
output regfft_insel,regfft_clear;
reg regfft_wren;
reg [7:0]regfft_addr;
reg [7:0]regfft_addrt; //Thuong 29Oct13
reg regfft_insel,regfft_clear;

output [6:0]cfft_addr;
reg [6:0]cfft_addr;

output cm_en,comadd_en,cm_shift;
reg cm_en,comadd_en,cm_shift;

output addsubfft_en,addsubfft_sel,addsubfft_shift;
reg addsubfft_en,addsubfft_sel,addsubfft_shift;

output sroot_en;
reg sroot_en;

//output [5:0]regffte_addr;
output [6:0]regffte_addr; // Thuong for 256 FFT
output regffte_wren;
reg [6:0]regffte_addr; // Thuong for 256 FFT
reg regffte_wren;

output addmel_en,addmel_sel,addmel_new;
reg addmel_en,addmel_sel,addmel_new;


output [4:0]regmel_addr;
output reg regmel_wren;//moi sua
reg [4:0]regmel_addr;

output [4:0]regdct_addr;
output regdct_wren;
reg [4:0]regdct_addr;
reg regdct_wren;

output [7:0]cdct_addr;
reg [7:0]cdct_addr;

output muldct_en;
reg muldct_en;

output addsubdct_en,addsubdct_sub,addsubdct_new;
reg addsubdct_en,addsubdct_sub,addsubdct_new;

output [6:0]regc_addr;
output [2:0]reglog_addr; //Thuong add
output      reglog_wren; //Thuong add
output regc_wren;
output [1:0]regc_sel;
reg [6:0]regc_addr;
reg [2:0]reglog_addr;
reg reglog_wren1;
reg reglog_wren2;
reg reglog_wren;
reg [2:0]regc_addrt,regc_addrc;
reg [2:0]regc_addrt_mod;
reg regc_wren;
reg [1:0]regc_sel;

output delta_new,delta_sub,delta_shift,delta_en;
reg delta_new,delta_sub,delta_shift,delta_en;

output [12:0]regcep_addr;
output regcep_wren;
reg regcep_wren;

input start,ready,fs,clk,reset;

output fefinish;
reg fefinish;

output [7:0]framenum;
reg [7:0]framenum;

reg [2:0]state;
reg [3:0]statef;//for fft
reg [4:0]statem;//for mel
reg d1,d2,dt;
reg [2:0]counterf;

reg [7:0]frame_num;//maximum 256 frames
reg [7:0]frame_addr;//address for eriting frames,true framenum + 1
reg [4:0]cep_addr;
reg [31:0]count_addr; //Thuong 29Oct13

//assign square_en=preemp_new^preemp_en; // Thuong change for frame calculation
assign square_en=preemp_en; // Thuong change for frame calculation
//Thuong change for frame 
//assign log_en=(frame_num!=1 && statem!=0 && state==5)?addmel_new:log_sel;
assign log_en=(statem!=0 && state==5)?regmel_wren:log_sel; // Change to use frame
//assign regmel_wren=addmel_sel;//moi bo
assign regcep_addr={frame_addr,cep_addr};
always @(state) begin
 if (state == 2) begin
  count_addr<=count_addr+1; //Thuong 29Oct13
 end
end
always @ (regfft_addrt or state) begin
 if (state == 2) begin
    if (count_addr != 1  && regfft_addrt == 154) begin
 //ram_addr_st<=80*(count_addr-1)+1; //Thuong 29Oct13
    ram_addr_st<=80*(count_addr-1); //Thuong 29Oct13
end
end
end

assign preem_en_mask = (regfft_addrt == 158) ? 1'b0: 1'b1;
assign preemp_en_out = preemp_en & preem_en_mask;
assign preemp_state_en = (state == 1) && (statef==3) && (count_addr!= 1 );
assign win_en_mask = ((state == 3) && (statef==1)) ? 1'b0 : 1'b1;

always @(posedge clk) begin
       reglog_wren1 <= log_sel;
       reglog_wren2 <= reglog_wren1;
       reglog_wren  <= reglog_wren2;
end


always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    count_addr<=1; // Thuong 29Oct13
    ram_addr<=0;
    ram_addr_st<=0;
    ram_addrt<=0;
    
    eadder_en<=0;
    eadder_sel<=0;
    eadder_new<=0;
    eadder_new1<=0;
    
    ereg_we<=0;
    
    log_sel<=0;
    
    preemp_en<=0;
    preemp_new<=0;
    
    cham_addr<=0;
    
    win_en<=0;
    
    regfft_wren<=0;
    regfft_addr<=0;
    regfft_addrt<=0;
    regfft_insel<=0;
    regfft_clear<=0;
    
    cfft_addr<=0;
    
    cm_en<=0;
    comadd_en<=0;
    cm_shift<=0;
    
    addsubfft_en<=0;
    addsubfft_sel<=0;
    addsubfft_shift<=0;
    
    sroot_en<=0;
    
    regffte_addr<=0;
    regffte_wren<=0;
    
    addmel_en<=0;
    addmel_sel<=0;
    addmel_new<=0;
    
    regmel_wren<=0;//moi them
    regmel_addr<=0;
    
    regdct_addr<=0;
    regdct_wren<=0;
    
    cdct_addr<=0;
    
    muldct_en<=0;
    
    addsubdct_en<=0;
    addsubdct_sub<=0;
    addsubdct_new<=0;
    
    reglog_addr<=0; //for Log register - Thuong add

    regc_addr<=0;
    regc_addrt<=0;
    regc_addrt_mod<=0;
    regc_addrc<=2;
    regc_wren<=0;
    regc_sel<=3;//sua 0-->3
    
    delta_new<=0;
    delta_sub<=0;
    delta_shift<=0;
    delta_en<=0;
    
    regcep_wren<=0;
    
    framenum<=0;
    
    frame_num<=0;
    frame_addr<=0;
    
    cep_addr<=31;
    
    statem<=0;
    
    d1<=0;
    d2<=0;
    dt<=0;
    statef<=0;
    counterf<=0;
    state<=0;
    fefinish<=0;
  end
  else
  begin
  case(state)
  0://wait for start signal
    begin
    case(statef)
    0:
      begin
      if(ready==1)
      begin
        fefinish<=0;
        
        regfft_addr<=0;
        regfft_addrt<=0;
        regfft_clear<=0;
        regfft_wren<=0;
        
        regc_addr<=0;
        regc_addrt<=0;
        regc_wren<=0;
        
        frame_num<=0;
        frame_addr<=0;
        regc_addrc<=2;
        
        dt<=0;
        statef<=statef+1;
      end
    end
    1:
    begin
      if(start==0 && fs==0)
      begin
        ram_addrt<=1;
        statef<=statef+1;
      end
    end
    2:
    begin
      ram_addrt<=0;
      preemp_new<=1;
      preemp_en<=1;
      ram_addr<=ram_addr+1;
      statef<=0;
      state<=state+1;
    end
    endcase
  end
  1://start preemp and windowing, energy calculation
  begin
    preemp_new<=0;
    preemp_en<=~preemp_en;
    //if((preemp_en==1) && (count_addr != 1))
    if((count_addr != 1)&&(statef==1))
    begin
	ram_addr <= ram_addr + 1;
    end
   else if (preemp_en==0 ) begin
	ram_addr <= ram_addr + 1;
    end
    case(statef)
    0:
    begin
      ram_addrt<=1;
      statef<=statef+1;
    end
    1:
    begin
      ram_addrt<=0;
      if (frame_num == 0) begin      // Thuong added for frame calculation
          eadder_en<=~eadder_en; // Thuong added for frame calculation
          eadder_new<=1;         // Thuong added for frame calculation
      end                        // Thuong added for frame calculation
      statef<=statef+1;
    end
    2:
    begin
      ram_addrt<=1;
      eadder_new<=0; // Thuong added for frame calculation
      if (frame_num == 0) begin      // Thuong added for frame calculation
      eadder_en<=~eadder_en; // Thuong added for frame calculation
      end                        // Thuong added for frame calculation
      statef<=statef+1;
    end
    3:
    begin
      //ram_addr <= ram_addr + 1;
      ram_addrt<=0;
      win_en<=~win_en;
      regfft_insel<=0;
      eadder_en<=~eadder_en; // Thuong added for frame calculation
      cham_addr<=cham_addr+1;
      statef<=0;
      state<=state+1;
    end
    endcase
  end
  2://preemp and windowing, energy calculation
  begin
    if(log_overf==1) //End sampling
    begin
      fefinish<=1;
      //framenum<=frame_addr;//sua lai
      framenum<=frame_addr-4;//frame_addr:so vecto trich dac trung/sua
//      framenum<=frame_addr;//frame_addr:so vecto trich dac trung/sua
      ram_addr<=0;
      ram_addrt<=0;
      log_sel<=0; //Thuong add
      eadder_en<=0; //Thuong add
      preemp_en<=0; //Thuong add
      reglog_wren<=0; //Thuong add
      win_en<=0; //Thuong add
      statef<=0;
      state<=0;
    end
    else begin
    win_en<=~win_en;
    if (regfft_addrt==158) begin
       log_sel<=1; // Thuong change to adjust timing
    end
    if (regfft_addrt==159) begin
       log_sel<=0; // Thuong change to adjust timing
    end
       preemp_en<=~preemp_en;
       eadder_en<=~eadder_en;
    
    if(preemp_en==1)
    begin
      ram_addrt<=1;
      regfft_wren<=0;
//Thuong 29Oct13      if(regfft_addrt==78)
      if(regfft_addrt==159)
      begin
        regc_addr[6:4]<=7;
        regc_addr[3:0]<=0;
        preemp_new<=1;//them
        state<=state+1;
      end
    end
    else
    begin
      if(regfft_addrt==157) begin
          ram_addr<=ram_addr_st;
      end
      else begin
          ram_addr<=ram_addr+1;
      end
      ram_addrt<=0;
      cham_addr<=cham_addr+1;
      regfft_wren<=1;
      regfft_addrt<=regfft_addrt+1;
      regfft_addr<=regfft_addrt;//moi them vao
      regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
    end
  end
 end  
  3://finish preemp and windowing, energy calculation
  begin
    //eadder_en<=~eadder_en; // Thuong comment
    cham_addr<=0;
    ram_addrt<=0;
//    eadder_new<=0;
    case(statef)
    0:
    begin
      eadder_en<=~eadder_en; // Thuong comment
      eadder_new<=1;
      preemp_en<=0;
      win_en<=~win_en;
      regfft_addrt<=regfft_addrt+1;
      regfft_addr<=regfft_addrt;//moi them vao
      regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
      regfft_wren<=~regfft_wren;
      preemp_new<=0;//them
      ram_addrt<=1;//them
      if (reglog_addr!= 4 && frame_num != 1'b0)
      reglog_addr <= reglog_addr + 1;
      else
      reglog_addr <= 0;
      statef<=statef+1;
    end
    1:
    begin
      eadder_new<=0;
      eadder_en<=~eadder_en; // Thuong comment
      ram_addrt<=1;//them
      regfft_wren<=~regfft_wren;
      win_en<=~win_en;
      statef<=statef+1;
      log_sel<=0; // Thuong change to adjust timing
    end
    2:
    begin
      ram_addrt<=1;//them
      eadder_sel<=1;
      regfft_addrt<=regfft_addrt+1;
      regfft_addr<=regfft_addrt;//moi them vao
      regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
      regfft_wren<=~regfft_wren;
      regfft_clear<=1;//ghi xong 80 mau, xoa 48 (48=128-80) thanh ghi con lai ve 0 => Thuong change to statef 2
      ereg_we<=1;
      statef<=statef+1;
    end
    3:
    begin
      ram_addrt<=1;//them
      eadder_sel<=0;
      regfft_addrt<=regfft_addrt+1;
      regfft_addr<=regfft_addrt;//moi them vao
      regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
      eadder_sel<=0;
     // regfft_clear<=1;//ghi xong 80 mau, xoa 48 (48=128-80) thanh ghi con lai ve 0 => Thuong change to statef 2
//      if(frame_num!=0)
        
      ereg_we<=0;
      statef<=0;
      state<=state+1;
    end
    endcase
  end
  4://clear regfft, co sua regc_addr
  begin
    case (statef) 
        0 : begin
              if(regfft_addrt==162) //Thuong add
               statef <=1;
            end
        1 : begin
               statef <=2;
            end
        2 : 
          begin
           if(regfft_addrt==164) //Thuong add
              begin //Thuong add
                 regc_addr[6:4]<=regc_addrt; //Thuong add
                 regc_addr[3:0]<=12; //Thuong add
                 regc_sel<=1; //Thuong add
                 regc_wren<=1; //Thuong add
                 //if (frame_num != 0) 
                     reglog_addr <= regc_addrt;
                 statef <=3;
             end //Thuong add
              
          end
        3 :
          begin
//              if(regfft_addrt==161) //Thuong add
//                begin //Thuong add
                 regc_wren<=0; //Thuong add
                 regc_sel<=2; //Thuong add
                 regc_addr[6:4]<=regc_addrt; //Thuong add
                 regc_addr[3:0]<=0; //Thuong add
                 statef <=4;
//                end //Thuong add
          end
        4 : begin
               if (frame_num != 0 && reglog_addr != 4) begin
               reglog_addr <= reglog_addr + 1;
               end
               else begin
               reglog_addr <= 0;
               end
               statef <=5;
            end
        5 : begin
               statef <=0;
            end
    endcase
    ram_addrt<=1;//them
    log_sel<=0;
// Thuong modify timing of log_overf    if(log_overf==1)
// Thuong modify timing of log_overf    begin
// Thuong modify timing of log_overf      fefinish<=1;
// Thuong modify timing of log_overf      //framenum<=frame_addr;//sua lai
// Thuong modify timing of log_overf      framenum<=frame_addr-3;//frame_addr:so vecto trich dac trung/sua
// Thuong modify timing of log_overf      ram_addr<=0;
// Thuong modify timing of log_overf      ram_addrt<=0;
// Thuong modify timing of log_overf      statef<=0;
// Thuong modify timing of log_overf      state<=0;
// Thuong modify timing of log_overf    end
//    else
//     begin
      if(regfft_addrt==0)
        begin
         regfft_insel<=1;
         regfft_clear<=0;
         addsubfft_sel<=1;//moi them vao ngay 18/7/2010
         regfft_addr<=1;
         regfft_addrt<=0;
         regfft_wren<=~regfft_wren;
         addmel_new<=0;//moi sua
         addmel_en<=0;//moi sua
         regmel_addr<=0;
         state<=state+1;
        end
      else
         begin
           regfft_addrt<=regfft_addrt+1;
           regfft_addr<=regfft_addrt;//moi them vao
           regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
         end
// Thuong change to State=3 Statef = 1     if(frame_num!=0)
// Thuong change to State=3 Statef = 1     begin 
// Thuong change to State=3 Statef = 1//       if(regfft_addrt==82) Thuong add
// Thuong change to State=3 Statef = 1       if(regfft_addrt==161)
// Thuong change to State=3 Statef = 1          begin
// Thuong change to State=3 Statef = 1             regc_addr[6:4]<=regc_addrt;
// Thuong change to State=3 Statef = 1             regc_addr[3:0]<=12;
// Thuong change to State=3 Statef = 1             regc_sel<=1;
// Thuong change to State=3 Statef = 1             regc_wren<=1;
// Thuong change to State=3 Statef = 1          end
// Thuong change to State=3 Statef = 1       if(regfft_addrt==83)
// Thuong change to State=3 Statef = 1         begin
// Thuong change to State=3 Statef = 1             regc_wren<=0;
// Thuong change to State=3 Statef = 1             regc_sel<=2;
// Thuong change to State=3 Statef = 1             regc_addr[6:4]<=regc_addrt;
// Thuong change to State=3 Statef = 1             regc_addr[3:0]<=0;
// Thuong change to State=3 Statef = 1         end
// Thuong change to State=3 Statef = 1      end
//      end
  end
  5://FFT 1st,mel
  begin
    if(statem!=0)
    begin
      if(regmel_wren==1)//moi sua
      begin
        addmel_sel<=0;
        regmel_addr<=regmel_addr+1;
        //addmel_new<=1;
      end
      if(addmel_new==1)
      begin
        addmel_new<=0;
      end
    end
    if(log_en==1)
      d2<=1;
    if(d2==1)
    begin
      d2<=0;
      regdct_wren<=1;
    end
    if(regdct_wren==1)
    begin
      regdct_wren<=0;
      regdct_addr<=regdct_addr+1;
    end
    if(frame_num!=0) //Thuong modify for frame calculation
    begin
      case(statem)
      0:
      begin
        addmel_en<=1;//moi them
        addmel_new<=1;//moi them
        regffte_addr<=0;
        statem<=statem+1;
      end
      1://moi them
      begin
        if(regffte_addr==1)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            regdct_wren<=0;//moi them
            end
          else
          begin
            d1<=0;
            regffte_addr<=0;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==0)
          addmel_sel<=0;//moi sua
      end
      2:
      begin
        if(regffte_addr==2)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=1;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==0)
          addmel_sel<=d1;//moi sua
      end
      3:
      begin
        if(regffte_addr==4)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=2;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==1)
          addmel_sel<=0;//moi sua
      end
      4:
      begin
        if(regffte_addr==5)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=4;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==2)
          addmel_sel<=0;//moi sua
      end
      5:
      begin
        if(regffte_addr==6)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=5;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==4)
          addmel_sel<=0;
      end
      6:
      begin
        if(regffte_addr==8)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=6;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==5)
          addmel_sel<=0;
      end
      7:
      begin
        if(regffte_addr==9)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=8;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==6)
          addmel_sel<=0;
      end
      8:
      begin
      if(regffte_addr==11)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=9;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==8)
        addmel_sel<=0;
      end
      9:
      begin
      if(regffte_addr==13)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=11;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==9)
        addmel_sel<=0;
      end
      10:
      begin
      if(regffte_addr==15)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=13;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==11)
        addmel_sel<=0;
      end
      11:
      begin
      if(regffte_addr==17)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=15;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==13)
        addmel_sel<=0;
      end
      12:
      begin
        if(regffte_addr==19)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=17;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==15)
          addmel_sel<=0;
      end
      13:
      begin
        if(regffte_addr==22)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=19;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==17)
          addmel_sel<=0;
      end
      14:
      begin
        if(regffte_addr==25)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=22;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==19)
          addmel_sel<=0;
      end
      15:
      begin
        if(regffte_addr==28)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=25;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
          if(regffte_addr==22)
            addmel_sel<=0;
      end
      16:
      begin
        if(regffte_addr==31)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=28;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==25)
          addmel_sel<=0;
      end
      17:		
      begin
        if(regffte_addr==34)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=31;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==28)
          addmel_sel<=0;
      end
      18:
      begin
        if(regffte_addr==38)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=34;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==31)
          addmel_sel<=0;
      end
      19:
      begin
        if(regffte_addr==42)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=38;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==34)
          addmel_sel<=0;
      end
      20:
      begin
        if(regffte_addr==47)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=42;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==38)
          addmel_sel<=0;
      end
      21:	
      begin
        if(regffte_addr==52)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=47;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==42)
          addmel_sel<=0;
      end
      22:			
      begin
        if(regffte_addr==57)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=52;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==47)
          addmel_sel<=0;
      end
      23:
      begin
        if(regffte_addr==63)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            addmel_en<=0;//moi them vao
            regffte_addr<=0;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi sua
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
      end
      24:
      begin
        statem<=statem+1;
      end
      //25:
        //addmel_en<=0;
      endcase
    end // Thuong for frame calculation
      case(statef)
      0:
      begin
        regfft_addr<=regfft_addrt;
        regfft_addrt<=regfft_addr;
        addsubfft_sel<=0;//them vao ngay 18/7/2011
        addsubfft_en<=1;//them vao ngay 18/7/2011
        statef<=statef+1;
      end
      1:
      begin
        addsubfft_en<=0;//them vao ngay 18/7/2011
        regfft_wren<=1;//them vao ngay 18/7/2011
        addsubfft_sel<=0;
        statef<=statef+1;
      end
      2:
      begin
        addsubfft_sel<=0;//sua lai
        addsubfft_en<=0;
        regfft_wren<=1;//sua lai
        regfft_addr<=regfft_addrt;//moi them vao
        regfft_addrt<=regfft_addr;//moi them vao
        statef<=statef+1;
      end
      /*3:
      begin
        addsubfft_en<=0;
        regfft_wren<=1;//moi them vao ngay 18/7/2011
        //regfft_wren<=0;
        statef<=statef+1;
      end*/
      3:
      begin
        //statef<=statef+1;
      //end
      //4:
      //begin
        //regfft_wren<=0;
        //addsubfft_sel<=0;//sua lai
     //   if(regfft_addr==127) //Thuong 31Oct13
        if(regfft_addr==255)
        begin
          addsubfft_sel<=0;//moi them vao
          cm_en<=1;//sua
          regfft_wren<=0;//them vao
          regfft_addr<=2;
          regfft_addrt<=0;
          cfft_addr<=0;
          cm_shift<=1;
          statem<=0;
          statef<=0;//moi them vao
          regdct_addr<=0;
          state<=state+1;
        end
        else
        begin
        regfft_addr<=regfft_addrt;
        regfft_addrt<=regfft_addr;
        addsubfft_sel<=1;//them vao
        regfft_wren<=0;//sua lai
        regfft_addr<=regfft_addr+2;//moi them
        regfft_addrt<=regfft_addrt+2;//moi them
          //addsubfft_sel<=0;//them vao
          //addsubfft_en<=1;//them vao
          //regfft_addr<=regfft_addr;
          //regfft_addrt<=regfft_addrt;
        //end
        statef<=0;
        end
      end
      endcase
  end

  6://fft 2nd-7th,dct,delta
  begin
//  if(frame_num!=0&&frame_num!=1)//sua
  if(frame_num!=0)// Thuong for frame calculation
  begin
    case(statem)
    0:
    begin
      muldct_en<=1;//moi sua
      addsubdct_new<=0;
      addsubdct_en<=0;
      if(regdct_addr==1 && cdct_addr[7:4]!=0)
        regc_wren<=1;
        
      statem<=statem+1;
    end
    1:
    begin
      if(regdct_addr==22)
      begin
        regdct_addr<=0;
        cdct_addr[7:4]<=cdct_addr[7:4]+1;
        if(cdct_addr[7:4]==11)
        begin
          statem<=statem+1;
          cdct_addr[7:4]<=0;
        end
        else
        begin
          cdct_addr[7:4]<=cdct_addr[7:4]+1;
          statem<=0;
        end
      end
      else
      begin
        regdct_addr<=regdct_addr+1;
        if(regdct_addr<11)
          cdct_addr[3:0]<=cdct_addr[3:0]+1;
        else
          cdct_addr[3:0]<=cdct_addr[3:0]-1;
        statem<=0;
      end
      muldct_en<=0;
      if(regdct_addr==13 && cdct_addr[4]==0)
        addsubdct_sub<=1;
      if(regdct_addr!=0 || cdct_addr[7:4]!=0)
        addsubdct_en<=1;
      if(regdct_addr==1)
      begin
        addsubdct_new<=1;
        addsubdct_sub<=0;
      end
      if(regc_wren==1)
      begin
        regc_wren<=0;
        regc_addr[3:0]<=regc_addr[3:0]+1;
      end
      //statem<=0;//moi them
    end
    2:
    begin
      muldct_en<=0;
      addsubdct_en<=0;
      statem<=statem+1;
    end
    3:
    begin
      if(addsubdct_en==0)
        addsubdct_en<=1;
      else
      begin
        addsubdct_en<=0;
        regc_wren<=1;
        statem<=statem+1;
      end
    end
    4://////////
    begin
      regc_wren<=0;
      regc_addr[3:0]<=0;
      if(regc_addr[6:4]!=4 && dt==0)
      begin
        regc_addrt<=regc_addrt+1;//them
        //regc_addrt<=regc_addr[6:4]+1;
        statem<=10;
      end
      else //tinh he so delta
      begin
        //delta_new<=1;//moi them vao
        //delta_en<=1;//moi them vao
        regc_addrt<=regc_addr[6:4];//regc_addr=64
        dt<=1;
        regc_sel<=3;//
        delta_en<=1;//moi them
        delta_new<=1;//moi them
        delta_sub<=0;//moi them
        delta_shift<=0;//moi them
        statem<=statem+1;
      end
    end
    5:
    begin
      delta_new<=0;//moi them
      delta_sub<=1;//moi them
      delta_shift<=1;//moi them
      if(regc_addr[6:4]==4)
        regc_addr[6:4]<=0;
      else
        regc_addr[6:4]<=regc_addr[6:4]+1;
        
      statem<=statem+1;
    end
    6:
    begin
      delta_sub<=0;//moi them
      delta_shift<=0;//moi them
      case(regc_addr[6:4])
      0: regc_addr[6:4]<=3;//0--->48
      1: regc_addr[6:4]<=4;//16-->64
      2: regc_addr[6:4]<=0;//32-->0
      3: regc_addr[6:4]<=1;//48-->16
      4: regc_addr[6:4]<=2;//64-->32
      endcase
      /*delta_en<=1;
      if(delta_en==0)
        delta_new<=1;
      if(delta_new==1)
      begin
        delta_new<=0;
        delta_sub<=1;
        delta_shift<=1;
      end
      
      if(delta_shift==1)
      begin
        delta_sub<=0;
        delta_shift<=0;
        statem<=statem+1;
      end*/
      statem<=statem+1;
    end
    7:
    begin
      case(regc_addr[6:4])//moi them
      0: regc_addr[6:4]<=3;//0--->48
      1: regc_addr[6:4]<=4;//16-->64
      2: regc_addr[6:4]<=0;//32-->0
      3: regc_addr[6:4]<=1;//48-->16
      4: regc_addr[6:4]<=2;//64-->32
      endcase
      if(delta_sub==0)
        delta_sub<=1;
      else
      begin
        delta_sub<=0;
        delta_en<=0;
        regc_wren<=1;
        regc_addr[6:4]<=5;//addr=80
        statem<=statem+1;
        end
    end
    8://ghi he so delta vao thanh ghi regcep
    begin	
      regc_addr[3:0]<=regc_addr[3:0]+1;//moi them
      delta_en<=1;//moi them
      if(delta_en==0)
        delta_new<=1;
      if(delta_new==1)
      begin
        delta_new<=0;
        delta_sub<=1;
        delta_shift<=1;
      end
      
      if(delta_shift==1)
      begin
        delta_sub<=0;
        delta_shift<=0;
        statem<=statem+1;
      end//moi them
      regc_wren<=0;
      if(regc_addr[3:0]==12)//xong 13 he so cepstrum
        begin
        regc_addr[3:0]<=0;
        regc_addr[6:4]<=regc_addrc;
        if(regc_addrt!=4)
          regc_addrt<=regc_addrt+1;
        else
          regc_addrt<=0;
          
        if(regc_addrc!=4)
          regc_addrc<=regc_addrc+1;
            
      else
          regc_addrc<=0;
            
        regcep_wren<=1;//moi them,ghi cac phan tu vecto dac trung vao thanh ghi regcep
        cep_addr<=cep_addr+1;//moi them
        statem<=statem+1;
      end
      else
      begin
        regc_addr[6:4]<=regc_addrt;
        regc_addr[3:0]<=regc_addr[3:0]+1;
        statem<=5;//statem<=5;//moi sua
      end
    end
    //9:
    //begin
      //regc_addr[3:0]<=regc_addr[3:0]+1;
      //statem<=statem+1;
    //end
    9:
    begin
      if(cep_addr==25)//26 phan tu vec to dac trung
      begin
        cep_addr<=31;
        frame_addr<=frame_addr+1;//dem so vecto dac trung
        regcep_wren<=0;
        statem<=statem+1;
      end
      else
      begin
        regcep_wren<=1;
        cep_addr<=cep_addr+1;
        if(cep_addr==12)//moi sua
        begin
          regc_addr[6:4]<=5;
          regc_addr[3:0]<=0;
        end
        else
        begin
          regc_addr[3:0]<=regc_addr[3:0]+1;
        end
      end
  end
  endcase // endcase statem
  end
    case(statef)//tinh FFT
    0:
    begin
      cm_en<=0;
      statef<=statef+1;
      //cm_en<=1;//moi them vao
      //comadd_en<=0;//moi them vao
      //addsubfft_en<=0;//moi them vao
    end
    1://moi them
    begin
      comadd_en<=1;//moi them vao
      statef<=statef+1;
    end
    2:
    begin
      regfft_addr<=regfft_addrt; //regfft_addr<=regfft_addr+1;
      cm_en<=0;
      comadd_en<=0;//moi sua
      addsubfft_en<=1;//moi them vao
      case(counterf)
// Thuong 31Oct13
//      0: cfft_addr[5]<=~cfft_addr[5];
//      1: cfft_addr[5:4]<=cfft_addr[5:4]+1;
//      2: cfft_addr[5:3]<=cfft_addr[5:3]+1;
//      3: cfft_addr[5:2]<=cfft_addr[5:2]+1;
//      4: cfft_addr[5:1]<=cfft_addr[5:1]+1;
//      5: cfft_addr<=cfft_addr+1;
        0: cfft_addr[6]<=~cfft_addr[6];
        1: cfft_addr[6:5]<=cfft_addr[6:5]+1;
        2: cfft_addr[6:4]<=cfft_addr[6:4]+1;
        3: cfft_addr[6:3]<=cfft_addr[6:3]+1;
        4: cfft_addr[6:2]<=cfft_addr[6:2]+1;
        5: cfft_addr[6:1]<=cfft_addr[6:1]+1;
        6: cfft_addr<=cfft_addr+1;
      endcase
      statef<=statef+1;
    end
    //2://moi them
    //begin
     // cm_en<=1;
     // comadd_en<=0;//moi them
     // addsubfft_en<=0;//moi them vao
     // statef<=statef+1;
  //	end
    3://moi them
    begin
      addsubfft_en<=0;//moi them vao
      regfft_wren<=1;//moi them vao
      statef<=statef+1;
    end
    4://////////////////////sua lai
    begin
      regfft_wren<=1;//moi them vao
      case(counterf)
      0: regfft_addr<=regfft_addr+2;
      1: regfft_addr<=regfft_addr+4;
      2: regfft_addr<=regfft_addr+8;
      3: regfft_addr<=regfft_addr+16;
      4: regfft_addr<=regfft_addr+32;
      5: regfft_addr<=regfft_addr+64;
      6: regfft_addr<=regfft_addr+128;// Thuong
      endcase
      //regfft_addr<=regfft_addr+2;//moi them vao
      statef<=statef+1;
     end
    5:
    begin
      cm_en<=1;
      regfft_wren<=0;//moi them vao
      //comadd_en<=1;
      //addsubfft_en<=0;//sua
      regfft_addr<=regfft_addr+1;//regfft_addr<=regfft_addrt;
      statef<=statef+1;
    end
    6://moi them
    begin
      cm_en<=0;
      comadd_en<=0;//moi them vao
      statef<=statef+1;
    end
    7:
    begin
      cm_en<=0;//sua lai cm_en<=1
      comadd_en<=1;//moi sua
      //addsubfft_en<=1;//moi them vao
      case(counterf)
// Thuong 31Oct13
//      0: cfft_addr[5]<=~cfft_addr[5];
//      1: cfft_addr[5:4]<=cfft_addr[5:4]+1;
//      2: cfft_addr[5:3]<=cfft_addr[5:3]+1;
//      3: cfft_addr[5:2]<=cfft_addr[5:2]+1;
//      4: cfft_addr[5:1]<=cfft_addr[5:1]+1;
//      5: cfft_addr<=cfft_addr+1;
        0: cfft_addr[6]<=~cfft_addr[6];
        1: cfft_addr[6:5]<=cfft_addr[6:5]+1;
        2: cfft_addr[6:4]<=cfft_addr[6:4]+1;
        3: cfft_addr[6:3]<=cfft_addr[6:3]+1;
        4: cfft_addr[6:2]<=cfft_addr[6:2]+1;
        5: cfft_addr[6:1]<=cfft_addr[6:1]+1;
        6: cfft_addr<=cfft_addr+1;
      endcase
      statef<=statef+1;
    end
    8:
    begin
      cm_en<=0;
      comadd_en<=0;
      addsubfft_en<=1;
      regfft_addr<=regfft_addrt+1;//regfft_addr<=regfft_addr+1;
      statef<=statef+1;
    end
    9://moi them
    begin
      regfft_wren<=1;//moi them vao
      addsubfft_en<=0;//moi them vao
      statef<=statef+1;
    end
    10://///////////////////sua lai
    begin
      //regfft_wren<=0;//moi them vao
      comadd_en<=0;
      addsubfft_en<=0;
      case(counterf)
      0: regfft_addr<=regfft_addr+2;
      1: regfft_addr<=regfft_addr+4;
      2: regfft_addr<=regfft_addr+8;
      3: regfft_addr<=regfft_addr+16;
      4: regfft_addr<=regfft_addr+32;
      5: regfft_addr<=regfft_addr+64;
      6: regfft_addr<=regfft_addr+128;//Thuong
      endcase
      //regfft_addr<=regfft_addrt+3;//regfft_addr<=regfft_addrt;
      regfft_addrt<=regfft_addr;
      regfft_wren<=1;
      statef<=statef+1;
    end
    11:
    begin
      cm_en<=1;//moi them vao
      regfft_wren<=0;
      //if(regfft_addr==127)
      if(regfft_addr==255)
      begin
        regfft_addrt<=0;
        case(counterf)
        0: 
        begin
          regfft_addr<=4;
          counterf<=counterf+1;
        end
        1:
        begin
          regfft_addr<=8;
          counterf<=counterf+1;
        end
        2:
        begin
          regfft_addr<=16;
          counterf<=counterf+1;
        end
        3:
        begin
          regfft_addr<=32;
          counterf<=counterf+1;
        end
        4: //Thuong add for 256 point
        begin
          regfft_addr<=64;
          counterf<=counterf+1;
        end
        5:
        begin
          regfft_addr<=128;
          cm_shift<=0;
          addsubfft_shift<=1;
          counterf<=counterf+1;
        end
        6:
        begin
          regfft_addr<=0;
          counterf<=0;
          addsubfft_shift<=0;
          sroot_en<=1;//moi them
          statem<=0;
          cm_en<=0;//moi them vao
          state<=state+1;
        end
        endcase //endcase statef
      end
      else
      begin
//Thuong add for test
//        if(frame_num==0) begin
//          regc_addrt<=1; //frame_num == 0
//        end
        if(cfft_addr==0)
        begin
          case(counterf)
          0:
          begin
            regfft_addr<=regfft_addr+3;
            regfft_addrt<=regfft_addrt+3;
          end
          1:
          begin
            regfft_addr<=regfft_addr+5;
            regfft_addrt<=regfft_addrt+5;
          end
          2:
          begin
            regfft_addr<=regfft_addr+9;
            regfft_addrt<=regfft_addrt+9;
          end
          3:
          begin
            regfft_addr<=regfft_addr+17;
            regfft_addrt<=regfft_addrt+17;
          end
          4:
          begin
            regfft_addr<=regfft_addr+33;
            regfft_addrt<=regfft_addrt+33;
          end
          5: //Thuong add for 256 FFT
          begin
            regfft_addr<=regfft_addr+65;
            regfft_addrt<=regfft_addrt+65;
          end
          endcase
        end
        else
        begin
          regfft_addr<=regfft_addr+1;
          regfft_addrt<=regfft_addrt+1;
        end
      end
      statef<=0;
    end
    endcase
  end
        
  
  7://fft spectrum
  begin
  regfft_addr<=regfft_addr+1;
  
  if(regfft_addr==0)
    begin
    regffte_wren<=1;
    regffte_addr<=0;
    end
    
  if(regffte_wren==1)
    regffte_addr<=regffte_addr+1;

  if(regffte_addr==62)//moi them vao
  //if(regffte_addr==126)//moi them vao
    sroot_en<=0;//moi them vao
  
  if(regffte_addr==63)//Thuong for 256 point
  //if(regffte_addr==127)//moi them vao
    begin
    regffte_addr<=0;//moi them vao
    regffte_wren<=0;//moi them vao
    end
  
  //if(regfft_addr==65)
    //sroot_en<=0;
  
  if(sroot_en==0)
    regffte_wren<=0;
    
  //if(regffte_wren==0)
    //regffte_addr<=0;
    
  // if(regfft_addr==66) Thuong modify for timing
   if(regfft_addr==130)
  begin
      regfft_insel<=0;
      if(frame_num==255)
      begin
        fefinish<=1;
        framenum<=frame_addr-2;
        ram_addr<=0;
        ram_addrt<=0;
        statef<=0;
        state<=0;
      end
      else
      begin
        frame_num<=frame_num+1;
        statef<=1;
        state<=1;
      end
    end
  end
  endcase
end
end
endmodule
module fecore(ram_datain,ram_address,
      regcep_in,regcep_addr,regcep_wren,
      framenum,shiftc,shiftd,
      start,ready,fefinish,fs,clk,reset);
      
input [7:0]ram_datain;//from Speech RAM
reg [15:0]ram_data;//
input start;
input ready;//ready=1:bat dau doc data tu speech RAM, ready=0: doc thong so mo hinh
input [3:0]shiftc;//shift the cepstrum
input [1:0]shiftd;//shift the data
input fs;
input clk,reset;

output  [7:0]framenum;
output fefinish;

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

assign taddsubdct_out=(shiftc==15)?addsubdct_out[26:11]:16'bz;
assign taddsubdct_out=(shiftc==14)?addsubdct_out[26:11]:16'bz;
assign taddsubdct_out=(shiftc==13)?addsubdct_out[26:11]:16'bz;
assign taddsubdct_out=(shiftc==12)?addsubdct_out[27:12]:16'bz;
assign taddsubdct_out=(shiftc==11)?addsubdct_out[26:11]:16'bz;
assign taddsubdct_out=(shiftc==10)?addsubdct_out[25:10]:16'bz;
assign taddsubdct_out=(shiftc==9)?addsubdct_out[24:9]:16'bz;
assign taddsubdct_out=(shiftc==8)?addsubdct_out[23:8]:16'bz;
assign taddsubdct_out=(shiftc==7)?addsubdct_out[23:7]:16'bz;
assign taddsubdct_out=(shiftc==6)?addsubdct_out[21:6]:16'bz;
assign taddsubdct_out=(shiftc==5)?addsubdct_out[20:5]:16'bz;
assign taddsubdct_out=(shiftc==4)?addsubdct_out[19:4]:16'bz;
assign taddsubdct_out=(shiftc==3)?addsubdct_out[18:3]:16'bz;
assign taddsubdct_out=(shiftc==2)?addsubdct_out[17:2]:16'bz;
assign taddsubdct_out=(shiftc==1)?addsubdct_out[16:1]:16'bz;
assign taddsubdct_out=(shiftc==0)?addsubdct_out[15:0]:16'bz;

assign tdelta_out=(shiftd==3)?delta_out[18:3]:16'bz;
assign tdelta_out=(shiftd==2)?delta_out[17:2]:16'bz;
assign tdelta_out=(shiftd==1)?delta_out[16:1]:16'bz;
assign tdelta_out=(shiftd==0)?delta_out[15:0]:16'bz;

assign log_in=(log_sel)?{{7{eadder_out[38]}},eadder_out}:addmel_out;
//regfft_insel=0:doc du lieu da duoc windowing vao thanh ghi phan thuc regfft_inr dong thoi xoa noi dung thanh ghi phan ao regfft_ini
//regfft_clear=1:xoa noi dung thanh ghi regfft_inr va regfft_ini
//regfft_clear=0 va regfft_insel=1:ghi noi dung cac tang FFT vao thanh ghi regfft
assign regfft_ini=(regfft_insel & ~regfft_clear)?addsubfft_outi:0;//phan ao output cua FFT
assign regfft_inrt=(regfft_insel)?addsubfft_outr:{{19{win_out[20]}},win_out};
assign regfft_inr=(regfft_clear)?0:regfft_inrt;//phan thuc output cua FFT

assign addsubfft_regfftr=(addsubfft_shift)?{regfft_outr[33:0],6'b0}:regfft_outr;
assign addsubfft_regffti=(addsubfft_shift)?{regfft_outi[33:0],6'b0}:regfft_outi;

assign regmel_in=addmel_out[44:0];

assign regdct_in=log_out;

assign regc_in=(regc_sel==0)?regc_out:16'bz;
assign regc_in=(regc_sel==1)?reglog_out:16'bz;//logged energy of frame
//assign regc_in=(regc_sel==1)?log_out:16'bz;//logged energy of frame Thuong change
assign regc_in=(regc_sel==2)?taddsubdct_out:16'bz;//cepstrum coefficients of frame
assign regc_in=(regc_sel==3)?tdelta_out:16'bz;//delta coefficients of frame

assign regcep_in=regc_out;//thanh ghi vecto dac trung MFCC

//register

reghw reghw(cham_data,cham_addr,clk,reset);//1.Register for Hamming Window coefficients

regw regw(cfft_datar,cfft_datai,cfft_addr,clk,reset);//2.Register for FFT coefficients,W

rege rege(regffte_out,regffte_in,regffte_addr,regffte_wren,clk,reset);//3.Spectrum Register (register for energy coefficients)

regp regp(regmel_out,regmel_in,regmel_addr,regmel_wren,clk,reset);//4.Power coefficient Register

regfft regfft(regfft_outr,regfft_outi,regfft_inr,regfft_ini,regfft_addr,regfft_wren,clk,reset);//5.Register for 128 points FFT (256 elements,128 part real,128 part imaginary)

regdct regdct(regdct_out,regdct_in,regdct_addr,regdct_wren,clk,reset);//6.Logged power coefficient register

regcdct regcdct(cdct_addr,cdct_data,clk,reset);//7.Feature Buffer Register

regc regc(regc_out,regc_in,regc_addr,regc_wren,clk,reset);//8.Feature Buffer Register

reglog reglog(clk,reset,reglog_addr,reglog_wren,log_out, reglog_out);//9. Log energy Register - Thuong add

//

square square(square_out,ram_data,square_en,clk,reset);

eadder eadder(eadder_out,eadder_en,eadder_new,eadder_sel,square_out,ereg_out,clk,reset);

ereg ereg(eadder_out,ereg_out,ereg_we,clk,reset);

log log(log_in,log_out,log_en,log_overf,clk,reset);

preemp preemp(ram_data,preemp_out,preemp_en,preemp_new,clk,reset, preemp_state_en);
//preemp preemp(ram_data,preemp_out,preemp_en_out,preemp_new,clk,reset);

window window(preemp_out,cham_data,win_out,(win_en&win_en_mask),clk,reset);

complexm complexm(regfft_outr[30:0],regfft_outi[30:0],cfft_datar,cfft_datai,
        com_out1,com_out2,com_out3,com_out4,cm_en,clk,reset);

comadd comadd(com_out1,com_out2,com_out3,com_out4,cm_outr,cm_outi,comadd_en,cm_shift,clk,reset);

addsubfft addsubfft(addsubfft_regfftr,addsubfft_regffti,cm_outr,cm_outi,addsubfft_outr,
        addsubfft_outi,addsubfft_en,addsubfft_sel,clk,reset);

sroot sroot(regfft_outr,regfft_outi,regffte_in,sroot_en,clk,reset);

//addmel addmel(regffte_out,regmel_out,addmel_out,addmel_en,addmel_sel,addmel_new,clk,reset);// Thuong change to frame calculation
addmel addmel(regffte_out,regmel_out,addmel_out,addmel_en,1'b0,addmel_new,clk,reset);

muldct muldct(regdct_out,cdct_data,muldct_out,muldct_en,clk,reset);

addsubdct addsubdct(muldct_out,addsubdct_out,addsubdct_en,addsubdct_sub,addsubdct_new,clk,reset);

delta delta(delta_out,regc_out,delta_new,delta_sub,delta_shift,delta_en,clk,reset);

fecon fecon(.ram_addr(ram_addri),.ram_addrt(ram_addrt),
      .square_en(square_en),
      .eadder_en(eadder_en),.eadder_new(eadder_new),.eadder_sel(eadder_sel),
      .ereg_we(ereg_we),
      .log_en(log_en),.log_sel(log_sel),.log_overf(log_overf),
      .preemp_en(preemp_en),.preemp_en_out(preemp_en_out),.preemp_new(preemp_new),.preemp_state_en(preemp_state_en),
      .cham_addr(cham_addr),
      .win_en(win_en),.win_en_mask (win_en_mask),
      .regfft_wren(regfft_wren),.regfft_addr(regfft_addr),
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
      .start(start),.ready(ready),.fefinish(fefinish),.fs(fs),.clk(clk),.reset(reset));
endmodule
module fulladder38(cout,sumout,in1,in2,in3);
input[37:0]in1,in2,in3;
output[37:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule
module log(in,out,en,overf,clk,reset);

input [45:0]in;//energy from eadder or melfft, 46bit
input en;
input clk;
input reset;

output [15:0]out;//out=log_2(in)*512,512=2^9
output overf;

reg [15:0]out;
reg overf;
reg [15:0]a;//2^9*k
reg [8:0]b;
wire [15:0]sum;//2^9*k+9bits (tinh tu bit 1 dau tien)
reg state;

cla16log cla16log(sum,a,{7'b0,b});

always@(posedge clk or negedge reset)//log(in)*512->out
begin
if(reset==0)
begin
  out<=0;
  overf<=0;
  a<=0;
  b<=0;
  state<=0;
end
else
begin
  case(state)
  0://decoding to find k (in one clock cycle)
  begin
    if(en==1)
    begin
      state<=1;
      if(in==0)//the end of the speech
      begin
        overf<=1;//overf=1 to tell the extractor that the end of the speech
      end
      else if(in[44]==1)//k=44, the 45th bit is the sign bit, must be 0
      begin
        a<=16'h5800;//16'h5800=22528=2^9*k=512*44 (k=44)
        b<=in[43:35];//the following 9bits when k is recorded
      end
      else if(in[43]==1)//k=43
      begin
        a<=16'h5600;
        b<=in[42:34];
      end
      else if(in[42]==1)//k=42
      begin
        a<=16'h5400;
        b<=in[41:33];
      end
      else if(in[41]==1)//k=41
      begin
        a<=16'h5200;
        b<=in[40:32];
      end
      else if(in[40]==1)//k=40
      begin
        a<=16'h5000;
        b<=in[39:31];
      end
      else if(in[39]==1)//k=39
      begin
        a<=16'h4e00;
        b<=in[38:30];
      end
      else if(in[38]==1)//k=38
      begin
        a<=16'h4c00;
        b<=in[37:29];
      end
      else if(in[37]==1)//k=37
      begin
        a<=16'h4a00;
        b<=in[36:28];
      end
      else if(in[36]==1)//k=36
      begin
        a<=16'h4800;
        b<=in[35:27];
      end
      else if(in[35]==1)//k=35
      begin
        a<=16'h4600;
        b<=in[34:26];
      end
      else if(in[34]==1)//k=34
      begin
        a<=16'h4400;
        b<=in[33:25];
      end
      else if(in[33]==1)//k=33
      begin
        a<=16'h4200;
        b<=in[32:24];
      end
      else if(in[32]==1)//k=32
      begin
        a<=16'h4000;
        b<=in[31:23];
      end
      else if(in[31]==1)//k=31
      begin
        a<=16'h3e00;
        b<=in[30:22];
      end
      else if(in[30]==1)//k=30
      begin
        a<=16'h3c00;
        b<=in[29:21];
      end
      else if(in[29]==1)//k=29
      begin
        a<=16'h3a00;
        b<=in[28:20];
      end
      else if(in[28]==1)//k=28
      begin
        a<=16'h3800;
        b<=in[27:19];
      end
      else if(in[27]==1)//k=27
      begin
        a<=16'h3600;
        b<=in[26:18];
      end
      else if(in[26]==1)//k=26
      begin
        a<=16'h3400;
        b<=in[25:17];
      end
      else if(in[25]==1)//k=25
      begin
        a<=16'h3200;
        b<=in[24:16];
      end
      else if(in[24]==1)//k=24
      begin
        a<=16'h3000;
        b<=in[23:15];
      end
      else if(in[23]==1)//k=23
      begin
        a<=16'h2e00;
        b<=in[22:14];
      end
      else if(in[22]==1)//k=22
      begin
        a<=16'h2c00;
        b<=in[21:13];
      end
      else if(in[21]==1)//k=21
      begin
        a<=16'h2a00;
        b<=in[20:12];
      end
      else if(in[20]==1)//k=20
      begin
        a<=16'h2800;
        b<=in[19:11];
      end
      else if(in[19]==1)//k=19
      begin
        a<=16'h2600;
        b<=in[18:10];
      end
      else if(in[18]==1)//k=18
      begin
        a<=16'h2400;
        b<=in[17:9];
      end
      else if(in[17]==1)//k=17
      begin
        a<=16'h2200;
        b<=in[16:8];
      end
      else if(in[16]==1)//k=16
      begin
        a<=16'h2000;
        b<=in[15:7];
      end
      else if(in[15]==1)//k=15
      begin
        a<=16'h1e00;
        b<=in[14:6];
      end
      else if(in[14]==1)//k=14
      begin
        a<=16'h1c00;
        b<=in[13:5];
      end
      else if(in[13]==1)//k=13
      begin
        a<=16'h1a00;
        b<=in[12:4];
      end
      else if(in[12]==1)//k=12
      begin
        a<=16'h1800;
        b<=in[11:3];
      end
      else if(in[11]==1)//k=11
      begin
        a<=16'h1600;
        b<=in[10:2];
      end
      else if(in[10]==1)//k=10
      begin
        a<=16'h1400;
        b<=in[9:1];
      end
      else if(in[9]==1)//k=9
      begin
        a<=16'h1200;
        b<=in[8:0];
      end
      else if(in[8]==1)//k=8
      begin
        a<=16'h1000;
        b<={in[7:0],1'b0};
      end
      else if(in[7]==1)//k=7
      begin
        a<=16'he00;
        b<={in[6:0],2'b0};
      end
      else if(in[6]==1)//k=6
      begin
        a<=16'hc00;
        b<={in[5:0],3'b0};
      end
      else if(in[5]==1)//k=5
      begin
        a<=16'ha00;
        b<={in[4:0],4'b0};
      end
      else if(in[4]==1)//k=4
      begin
        a<=16'h800;
        b<={in[3:0],5'b0};
      end
      else if(in[3]==1)//k=3
      begin
        a<=16'h600;
        b<={in[2:0],6'b0};
      end
      else if(in[2]==1)//k=2
      begin
        a<=16'h400;
        b<={in[1:0],7'b0};
      end
      else if(in[1]==1)//k=1
      begin
        a<=16'h200;
        b<={in[0],8'b0};
      end
      else//k=0
      begin
        a<=0;
        b<=0;
      end
    end
  end
  1://adder (sum=a+b) (in one clock cycle)
  begin
    out<=sum;
    overf<=0;
    state<=0;
  end
  endcase
end
end
endmodule
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
module model_ram(fram_dataout,fram_addr,fram_wren);

output [7:0]fram_dataout;

input fram_wren;
input [20:0]fram_addr;

reg [7:0] model_ram[0:2097152];//2^21 address
//integer i;
initial begin 
  $display("TETETTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
//  $readmemh("model_13_12_2012.txt", model_ram);   
  $readmemh("model_Trung_7_Dec_2013.txt", model_ram);   
  
  //for(i=0;i<2097152;i=i+1) begin
     //$display("model_ram =%h",model_ram[i]);  
  //end  
end
assign fram_dataout = fram_wren?0:model_ram[fram_addr];
endmodule
module muldct(in1,in2,out,en,clk,reset);//16*8

input [15:0]in1;//log(S'nk) from logged power coefficient register (16bit 2's complement)
input [7:0]in2;//cos((k-0.5)p*pi/k) from register (8bit 2's complement)
input en;
input clk,reset;

output [22:0]out;//23bit 2's complement (windowed samples)(1 sign bit plus 20 data bits)

reg  [22:0]out;
wire [16:0]boothout1,boothout2,boothout3,boothout4;
wire [22:0]cout1,cout2,cout3;
wire [22:0]mulout1,mulout2,mulout3;

reg [22:0]a23,b23;
wire [22:0]sum23;
reg state;

//See 5.4.2 Multiplier
 
booth16 booth1(boothout1,{in2[1:0],1'b0},in1);
booth16 booth2(boothout2,in2[3:1],in1);
booth16 booth3(boothout3,in2[5:3],in1);
booth16 booth4(boothout4,in2[7:5],in1);

csa23md csa23md1(cout1,mulout1,{5'b0,~boothout1[16],boothout1},
          {3'b0,~boothout2[16],boothout2,2'b0},
          {1'b0,~boothout3[16],boothout3,4'b0});
csa23md csa23md2(cout2,mulout2,{cout1[21:0],1'b0},mulout1,{boothout4,6'b0});
csa23md csa23md3(cout3,mulout3,{cout2[21:0],1'b0},mulout2,{6'b101011,17'b0});

cla23md cla23md(sum23,a23,b23);

always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    a23<=0;
    b23<=0;
    out<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a23<={cout3[21:0],1'b0};
        b23<=mulout3;
        state<=1;
      end
    end
    1:
    begin
      out<=sum23;//sum23[22] is the signbit
      state<=0;
    end
    endcase
  end
end
endmodule
module multi38_1(in1,in2,cout3,mulout3);//31*8 multiplier part1

input [30:0]in1;// 31bit 2's complement
input [7:0]in2;//8bit 2's complement

output [37:0]cout3,mulout3;

wire [31:0]boothout1,boothout2,boothout3,boothout4;
wire [37:0]cout1,cout2;
wire [37:0]mulout1,mulout2;

booth31 booth1(boothout1,{in2[1:0],1'b0},in1);
booth31 booth2(boothout2,in2[3:1],in1);
booth31 booth3(boothout3,in2[5:3],in1);
booth31 booth4(boothout4,in2[7:5],in1);

fulladder38 fulladder1(cout1,mulout1,{5'b0,~boothout1[31],boothout1},
          {3'b0,~boothout2[31],boothout2,2'b0},
          {1'b0,~boothout3[31],boothout3,4'b0});
fulladder38 fulladder2(cout2,mulout2,{cout1[36:0],1'b0},mulout1,{boothout4,6'b0});
fulladder38 fulladder3(cout3,mulout3,{cout2[36:0],1'b0},mulout2,{6'b101011,32'b0});

endmodule
module multi38_2(cout3,mulout3,out);//31*8 multiplier part2
input [37:0]cout3,mulout3;
output [37:0]out;//out 38bit 2's complement

wire [38:0]out1;

cla38cm cla38cm(out1,{cout3[36:0],1'b0},mulout3);
assign out=out1[37:0];//bo MSB bit

endmodule
//out=in1*in2-->49bit (1 sign bit plus 48 data bits)
module multiplier(mulout,in1_1,in2_2,en,clk,reset,in_sel, en, clk, reset);//25*25 multiplier,output 49bit

input [24:0]in1_1;//25 bit 2's complement (1 sign bit plus 24 data bits)
input [24:0]in2_2;//25 bit 2's complement (1 sign bit plus 24 data bits)

input en;
input in_sel;
input clk,reset;

output [48:0]mulout;//49bit 2's complement (1 sign bit plus 48 data bits)

reg  [48:0]mulout;
wire [25:0]boothout1,boothout2,boothout3,boothout4,boothout5,boothout6,boothout7,boothout8,boothout9,boothout10,boothout11,boothout12,boothout13;//length(booth)=length(in2)+1
wire [48:0]cout1,cout2,cout3,cout4,cout5,cout6,cout7,cout8,cout9,cout10,cout11,cout12;
wire [48:0]mulout1,mulout2,mulout3,mulout4,mulout5,mulout6,mulout7,mulout8,mulout9,mulout10,mulout11,mulout12;

reg [48:0]a,b;
wire [48:0]sum;
reg state;
wire [24:0]in1;//25 bit 2's complement (1 sign bit plus 24 data bits)
wire [24:0]in2;//25 bit 2's complement (1 sign bit plus 24 data bits)

//See 5.4.2 Multiplier
assign in1=(in_sel==0)?in1_1:in2_2;
assign in2=(in_sel==0)?in1_1:mulout[29:5];//sua lai [30:15]
 
booth26 booth1(boothout1,{in1[1:0],1'b0},in2);
booth26 booth2(boothout2,in1[3:1],in2);
booth26 booth3(boothout3,in1[5:3],in2);
booth26 booth4(boothout4,in1[7:5],in2);
booth26 booth5(boothout5,in1[9:7],in2);
booth26 booth6(boothout6,in1[11:9],in2);
booth26 booth7(boothout7,in1[13:11],in2);
booth26 booth8(boothout8,in1[15:13],in2);
booth26 booth9(boothout9,in1[17:15],in2);
booth26 booth10(boothout10,in1[19:17],in2);
booth26 booth11(boothout11,in1[21:19],in2);
booth26 booth12(boothout12,in1[23:21],in2);
booth26 booth13(boothout13,{in1[24],in1[24:23]},in2);//so bit vao le (25 bit) --> mo rong sign bit (in1[24])

//csa=carry save adder

csa49squ csa49squ1(cout1,mulout1,{22'b0,~boothout1[25],boothout1},
          {20'b0,~boothout2[25],boothout2,2'b0},{18'b0,~boothout3[25],boothout3,4'b0});
          
csa49squ csa49squ2(cout2,mulout2,{16'b0,~boothout4[25],boothout4,6'b0},
          {14'b0,~boothout5[25],boothout5,8'b0},{12'b0,~boothout6[25],boothout6,10'b0});

csa49squ csa49squ3(cout3,mulout3,{10'b0,~boothout7[25],boothout7,12'b0},
          {8'b0,~boothout8[25],boothout8,14'b0},{6'b0,~boothout9[25],boothout9,16'b0});
          
csa49squ csa49squ4(cout4,mulout4,{4'b0,~boothout10[25],boothout10,18'b0},
          {2'b0,~boothout11[25],boothout11,20'b0},{~boothout12[25],boothout12,22'b0});

csa49squ csa49squ5(cout5,mulout5,{cout1[47:0],1'b0},mulout1,{boothout13[24:0],24'b0});



csa49squ csa49squ6(cout6,mulout6,{cout2[47:0],1'b0},mulout2,{cout3[47:0],1'b0});//hai carry + 1 sum

csa49squ csa49squ7(cout7,mulout7,mulout3,{cout4[47:0],1'b0},mulout4);//hai sum + 1 carry

csa49squ csa49squ8(cout8,mulout8,{cout5[47:0],1'b0},mulout5,{cout6[47:0],1'b0});//hai carry + 1 sum

csa49squ csa49squ9(cout9,mulout9,mulout6,{cout7[47:0],1'b0},mulout7);//hai sum + 1 carry

csa49squ csa49squ10(cout10,mulout10,{cout8[47:0],1'b0},mulout8,{cout9[47:0],1'b0});//hai carry + 1 sum

csa49squ csa49squ11(cout11,mulout11,mulout9,{cout10[47:0],1'b0},mulout10);//hai sum + 1 carry


csa49squ csa49squ12(cout12,mulout12,mulout11,{cout11[47:0],1'b0},{23'b01010101010101010101011,26'b0});


cla49squ cla49squ(sum,a,b);


always @(negedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    mulout<=0;
    a<=0;
    b<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a<={cout12[47:0],1'b0};
        b<=mulout12;
        state<=1;
      end
    end
    1:
    begin
      mulout<=sum;
      state<=0;
    end
    endcase
  end
end

endmodule

//submodule booth26,see Table4 page 90//

module booth26(out1,in1,in2);
parameter zee=26'bz;
input [2:0]in1;
input [24:0]in2;
output [25:0]out1;
assign out1=(in1==3'b000)?26'b0:zee;
assign out1=(in1==3'b001)?{in2[24],in2}:zee;
assign out1=(in1==3'b010)?{in2[24],in2}:zee;
assign out1=(in1==3'b011)?{in2[24:0],1'b0}:zee;
assign out1=(in1==3'b100)?~{in2[24:0],1'b0}+1'b1:zee;
assign out1=(in1==3'b101)?(~{in2[24],in2})+1'b1:zee;
assign out1=(in1==3'b110)?(~{in2[24],in2})+1'b1:zee;
assign out1=(in1==3'b111)?26'b0:zee;
endmodule

//CSA=Carry Save Adder//

module csa49squ(cout,sumout,in1,in2,in3);
input[48:0]in1,in2,in3;
output[48:0]cout,sumout;
assign sumout=(in1^in2)^in3;
assign cout=((in1^in2)&in3)|(in1&in2);
endmodule

//submodule cla45squ//
//add n bit
//A,B:sign 
//Ket qua chi dung voi dieu kien A[MSB]=A[MSB-1],B[MSB]=B[MSB-1]
//out:sign

module cla49squ(out,A,B);//out=A+B

parameter WIDTH=48;

input      [WIDTH:0]A,B;

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & B[ii];
    P[ii] = A[ii] ^ B[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = C[WIDTH+1];
end
endmodule
//module multiplier(mulout,cla16_out,regin_out,in_sel,en,clk,reset);
//
////16*16 multiplier, truncate output to 16bits
////insel=0:squre,insel==1:*var
//
///*---------booth multiplier--------*/
//
//input [15:0]cla16_out,regin_out;
//input in_sel,en;
//input clk,reset;
//
//output [31:0]mulout;
//
//wire [16:0]boothout1,boothout2,boothout3,boothout4,boothout5,boothout6,boothout7,boothout8;
//wire [31:0]cout1,cout2,cout3,cout4,cout5,cout6,cout7;
//wire [31:0]mulout1,mulout2,mulout3,mulout4,mulout5,mulout6,mulout7;
//wire [15:0]in1,in2;
//reg [31:0]cout7_reg,mulout7_reg;
//reg [31:0]mulout;
//wire [31:0]tmulout;
//reg state;
//
//assign in1=(in_sel==0)?cla16_out:regin_out;
//assign in2=(in_sel==0)?cla16_out:mulout[20:5];//sua lai [30:15]
//
//booth16 booth1(boothout1,{in1[1:0],1'b0},in2);
//booth16 booth2(boothout2,in1[3:1],in2);
//booth16 booth3(boothout3,in1[5:3],in2);
//booth16 booth4(boothout4,in1[7:5],in2);
//booth16 booth5(boothout5,in1[9:7],in2);
//booth16 booth6(boothout6,in1[11:9],in2);
//booth16 booth7(boothout7,in1[13:11],in2);
//booth16 booth8(boothout8,in1[15:13],in2);
//
//csa32 csa1(cout1,mulout1,{14'b0,~boothout1[16],boothout1},
//				{12'b0,~boothout2[16],boothout2,2'b0},
//				{10'b0,~boothout3[16],boothout3,4'b0});
//csa32 csa2(cout2,mulout2,{8'b0,~boothout4[16],boothout4,6'b0},
//				{6'b0,~boothout5[16],boothout5,8'b0},
//				{4'b0,~boothout6[16],boothout6,10'b0});
//csa32 csa3(cout3,mulout3,{2'b0,~boothout7[16],boothout7,12'b0},
//				{~boothout8[16],boothout8,14'b0},
//				{15'b010101010101011,17'b0});
//csa32 csa4(cout4,mulout4,{cout1[30:0],1'b0},mulout1,{cout2[30:0],1'b0});
//csa32 csa5(cout5,mulout5,mulout2,{cout3[30:0],1'b0},mulout3);
//csa32 csa6(cout6,mulout6,{cout4[30:0],1'b0},mulout4,{cout5[30:0],1'b0});
//csa32 csa7(cout7,mulout7,{cout6[30:0],1'b0},mulout6,mulout5);
//
//
//cla32 cla32(tmulout,{cout7_reg[30:0],1'b0},mulout7_reg);
//
//always@(posedge clk or negedge reset)
//begin
//	if(reset==0)
//	begin
//		cout7_reg<=0;
//		mulout7_reg<=0;
//		mulout<=0;
//		state<=0;
//	end
//	else
//	begin
//		case(state)
//		0:
//		begin
//			if(en==1)
//			begin
//				mulout7_reg<=mulout7;
//				cout7_reg<=cout7;
//				state<=1;
//			end
//		end
//		1:
//		begin
//			mulout<=tmulout;
//			state<=0;
//		end
//		endcase
//	end
//end
//endmodule
module MYCLALOG(P,G,Cin,Cout,C,PG,GG);

input [3:0]P,G;
input Cin;

output [3:1]C;
output PG,GG,Cout;

wire t1,t2,t3,t4,t5,t6,t7,t8,t9,t10;

assign PG=P[0]&P[1]&P[2]&P[3];
assign t1=P[3]&G[2];
assign t2=P[3]&P[2]&G[1];
assign t3=P[3]&P[2]&P[1]&G[0];
assign GG=G[3]|t1|t2|t3;

assign t4=P[0]&Cin;
assign C[1]=G[0]|t4;

assign t5=P[1]&G[0];
assign t6=P[1]&P[0]&Cin;
assign C[2]=G[1]|t5|t6;

assign t7=P[2]&G[1];
assign t8=P[2]&P[1]&G[0];
assign t9=P[2]&P[1]&P[0]&Cin;
assign C[3]=G[2]|t7|t8|t9;

assign t10=P[3]&P[2]&P[1]&P[0]&Cin;
assign Cout=G[3]|t1|t2|t3|t10;

endmodule
module MYPFA(A,B,C,S,P,G);
input A,B,C;
output S,P,G;

assign G=A&B;
assign P=A^B;
assign S=P^C;

endmodule
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
module preemp(in,out,en,newspeech,clk,reset, preemp_state_en);//input 16bit,output 17bit

input [15:0]in;//16-bit speech samples (cu sau T_newspeech moi co 1 mau moi vao)
input en;
input newspeech;//T_newspeech=2*T_clock (f_newspeech=f_clock/2)
input clk,reset;
input preemp_state_en;

output [16:0]out;//pre-emphasized samples

reg [16:0]out;
reg [16:0]a,b;
wire [16:0]sum;
reg state;

sub16pre sub16pre(sum,a,b);//sum=a+b+1

always @(posedge clk or negedge reset) begin
  if(reset==0)
    out<=0;
//  else if ((state&!preemp_state_en) == 1'b1) begin
  else if ((state) == 1'b1) begin
    out <= sum;
  end
  else
    out <= out;
end


always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
  //  out<=0;
    a<=0;
    b<=0;
    state<=0;
  end
  else
  begin
    //case(state&!preemp_state_en)
    case(state)
    0:
     begin
      if(en==1)
      begin
        a<={in[15],in};//mo rong them 1 bits
        if(newspeech==1)//first sample
        begin
          if(in[15:5]==11'h7ff && in[4:0]!=0)
            b<=17'h1ffff;
          else
            b<=~({{6{in[15]}},in[15:5]});//dich phai in 5 bits + mo rong sign bit-->bu1(in/32)
          state<=0;
        end
        else //newspeech=0-->co mau moi vao, 2 chu ky xung clock moi co 1 mau moi vao
        begin
          b<=~sum;//b=bu1(sum);sum=31/32*in
          state<=1;
        end
      end
    end
    1:
    begin
//      out<=sum;
      if(a[15:5]==11'h7ff && a[4:0]!=0)
        b<=17'h1ffff;
      else
        b<=~({{6{a[15]}},a[15:5]});//dich phai in 5 bits + mo rong sign bit-->bu1(a)
      state<=0;
      end
      endcase
    end
  end
endmodule
module read_speech(addr_in,sdram_in,sdram_out);

input [15:0]sdram_in;
input [22:0]addr_in;

//output reg sdram_read;
output [7:0]sdram_out;

assign sdram_out=(addr_in[0])?sdram_in[15:8]:sdram_in[7:0];

endmodule
module regcdct(cdct_addr,cdct_data,clk,reset);

output [7:0]cdct_data;//DCT coefficient (8bits 2's complement)
reg [7:0]cdct_data;

input [7:0]cdct_addr;//188 thanh ghi he so DCT
input clk,reset;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    cdct_data<=0;
  end
  else
  begin

//-----assign different register to output----
    case(cdct_addr)
        //Cn1
0:	cdct_data<=	63;
1:	cdct_data<=	62;
2:	cdct_data<=	60;
3:	cdct_data<=	56;
4:	cdct_data<=	52;
5:	cdct_data<=	46;
6:	cdct_data<=	40;
7:	cdct_data<=	33;
8:	cdct_data<=	25;
9:	cdct_data<=	17;
10:	cdct_data<=	8;
11:	cdct_data<=	0;

        //Cn2
16:	cdct_data<=	63	;
17:	cdct_data<=	58	;
18:	cdct_data<=	49	;
19:	cdct_data<=	36	;
20:	cdct_data<=	21	;
21:	cdct_data<=	4	;
22:	cdct_data<=	-13	;
23:	cdct_data<=	-29	;
24:	cdct_data<=	-43	;
25:	cdct_data<=	-54	;
26:	cdct_data<=	-61	;
27:	cdct_data<=	-64	;

        //Cn3
32:	cdct_data<=	62	;
33:	cdct_data<=	52	;
34:	cdct_data<=	33	;
35:	cdct_data<=	8	;
36:	cdct_data<=	-17	;
37:	cdct_data<=	-40	;
38:	cdct_data<=	-56	;
39:	cdct_data<=	-63	;
40:	cdct_data<=	-60	;
41:	cdct_data<=	-46	;
42:	cdct_data<=	-25	;
43:	cdct_data<=	0	;
        //Cn4
48:	cdct_data<=	61	;
49:	cdct_data<=	43	;
50:	cdct_data<=	13	;
51:	cdct_data<=	-21	;
52:	cdct_data<=	-49	;
53:	cdct_data<=	-63	;
54:	cdct_data<=	-58	;
55:	cdct_data<=	-36	;
56:	cdct_data<=	-4	;
57:	cdct_data<=	29	;
58:	cdct_data<=	54	;
59:	cdct_data<=	64	;

        //Cn5
64:	cdct_data<=	60	;
65:	cdct_data<=	33	;
66:	cdct_data<=	-8	;
67:	cdct_data<=	-46	;
68:	cdct_data<=	-63	;
69:	cdct_data<=	-52	;
70:	cdct_data<=	-17	;
71:	cdct_data<=	25	;
72:	cdct_data<=	56	;
73:	cdct_data<=	62	;
74:	cdct_data<=	40	;
75:	cdct_data<=	0	;

        //Cn6
80:	cdct_data<=	58	;
81:	cdct_data<=	21	;
82:	cdct_data<=	-29	;
83:	cdct_data<=	-61	;
84:	cdct_data<=	-54	;
85:	cdct_data<=	-13	;
86:	cdct_data<=	36	;
87:	cdct_data<=	63	;
88:	cdct_data<=	49	;
89:	cdct_data<=	4	;
90:	cdct_data<=	-43	;
91:	cdct_data<=	-64	;

        //Cn7
96:	cdct_data<=	56	;
97:	cdct_data<=	8	;
98:	cdct_data<=	-46	;
99:	cdct_data<=	-62	;
100:	cdct_data<=	-25	;
101:	cdct_data<=	33	;
102:	cdct_data<=	63	;
103:	cdct_data<=	40	;
104:	cdct_data<=	-17	;
105:	cdct_data<=	-60	;
106:	cdct_data<=	-52	;
107:	cdct_data<=	0	;

       //Cn8
112:	cdct_data<=	54	;
113:	cdct_data<=	-4	;
114:	cdct_data<=	-58	;
115:	cdct_data<=	-49	;
116:	cdct_data<=	13	;
117:	cdct_data<=	61	;
118:	cdct_data<=	43	;
119:	cdct_data<=	-21	;
120:	cdct_data<=	-63	;
121:	cdct_data<=	-36	;
122:	cdct_data<=	29	;
123:	cdct_data<=	64	;

        //cn9
128:	cdct_data<=	52	;
129:	cdct_data<=	-17	;
130:	cdct_data<=	-63	;
131:	cdct_data<=	-25	;
132:	cdct_data<=	46	;
133:	cdct_data<=	56	;
134:	cdct_data<=	-8	;
135:	cdct_data<=	-62	;
136:	cdct_data<=	-33	;
137:	cdct_data<=	40	;
138:	cdct_data<=	60	;
139:	cdct_data<=	0	;

        //Cn10
144:	cdct_data<=	49	;
145:	cdct_data<=	-29	;
146:	cdct_data<=	-61	;
147:	cdct_data<=	4	;
148:	cdct_data<=	63	;
149:	cdct_data<=	21	;
150:	cdct_data<=	-54	;
151:	cdct_data<=	-43	;
152:	cdct_data<=	36	;
153:	cdct_data<=	58	;
154:	cdct_data<=	-13	;
155:	cdct_data<=	-64	;

        //Cn11
160:	cdct_data<=	46	;
161:	cdct_data<=	-40	;
162:	cdct_data<=	-52	;
163:	cdct_data<=	33	;
164:	cdct_data<=	56	;
165:	cdct_data<=	-25	;
166:	cdct_data<=	-60	;
167:	cdct_data<=	17	;
168:	cdct_data<=	62	;
169:	cdct_data<=	-8	;
170:	cdct_data<=	-63	;
171:	cdct_data<=	0	;

        //Cn12
176:	cdct_data<=	43	;
177:	cdct_data<=	-49	;
178:	cdct_data<=	-36	;
179:	cdct_data<=	54	;
180:	cdct_data<=	29	;
181:	cdct_data<=	-58	;
182:	cdct_data<=	-21	;
183:	cdct_data<=	61	;
184:	cdct_data<=	13	;
185:	cdct_data<=	-63	;
186:	cdct_data<=	-4	;
187:	cdct_data<=	64	;

default:cdct_data<=0;
    endcase
  end
end
endmodule
module regcep(regcep_out,regcep_in,regcep_addr,regcep_wren,clk,reset);
      
output [15:0]regcep_out;//feature vector MFCC of n_th frame

input [12:0]regcep_addr;//truy cap 2^13=8192 thanh ghi,can truy cap 256*26=6656 thanh ghi (max co 256 frame, moi frame co 26 vector dac trung)
input [15:0]regcep_in;
input regcep_wren;//regcep_wren=0:read,regcep_wren=1:write
input clk,reset;

parameter WIDTH=8191;//8192 thanh ghi
integer i,j;

reg [15:0] registers[WIDTH:0];//8192 thanh ghi,moi thanh ghi 16bits

// The asynchronous read logic
assign regcep_out = registers[regcep_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    begin
    for(i=0;i<4500;i=i+1) 
      begin
        registers[i]<=0;
      end
    for(j=4500;j<WIDTH;j=j+1) 
      begin
        registers[j]<=0;
      end
    end
  else
    if(regcep_wren)// The synchronous write logic
      registers[regcep_addr]<=regcep_in;
end
endmodule
module regc(regc_out,regc_in,regc_addr,regc_wren,clk,reset);
      
output [15:0]regc_out;//feature vector MFCC

input [6:0]regc_addr;//truy cap 2^7=128 thanh ghi
input [15:0]regc_in;
input regc_wren;//regc_wren=0:read,regc_wren=1:write
input clk,reset;

parameter WIDTH=127;//128 thanh ghi
integer i;

reg [15:0] registers[WIDTH:0];//128 thanh ghi,moi thanh ghi 16bits

// The asynchronous read logic
assign regc_out = registers[regc_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regc_wren)// The synchronous write logic
      registers[regc_addr]<=regc_in;
end
endmodule
module regdct(regdct_out,regdct_in,regdct_addr,regdct_wren,clk,reset);
      
output [15:0]regdct_out;//logged power coefficient (23 logged power coefficients S'_nk)

input [4:0]regdct_addr;//truy cap 2^5=32 thanh ghi, can 23 he so DCT,23 he so logS'_nk
input [15:0]regdct_in;
input regdct_wren;
input clk,reset;

parameter WIDTH=31;//32 thanh ghi
integer i;

reg [15:0] registers[WIDTH:0];//32 thanh ghi,moi thanh ghi 16bits

// The asynchronous read logic
assign regdct_out = registers[regdct_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regdct_wren)// The synchronous write logic
      registers[regdct_addr]<=regdct_in;
end
endmodule
module rege(regffte_out,regffte_in,regffte_addr,regffte_wren,clk,reset);
      
output [40:0]regffte_out;//energy coefficient

//input [5:0]regffte_addr;//truy cap 2^6=64 thanh ghi, can 64 he so nang luong,SF
input [6:0]regffte_addr;//truy cap 2^7=128 thanh ghi, can 64 he so nang luong,SF
input [40:0]regffte_in;
input regffte_wren;//regffte_wren=0:read,regffte_wren=1:write
input clk,reset;

//parameter WIDTH=63;//64 thanh ghi
parameter WIDTH=127;//128 thanh ghi
integer i;

reg [40:0] registers[WIDTH:0];//64 thanh ghi,moi thanh ghi 41bits

// The asynchronous read logic
assign regffte_out = registers[regffte_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regffte_wren)// The synchronous write logic
      registers[regffte_addr]<=regffte_in;
end
endmodule
module regfft(fft_outr,fft_outi,fft_inr,fft_ini,fft_addr,fft_wren,clk,reset);
      
input [39:0]fft_inr,fft_ini;
//input [6:0]fft_addr;//truy cap 2^7=128 thanh ghi, can luu 128 diem FFT
input [7:0]fft_addr;//truy cap 2^8=256 thanh ghi, can luu 128 diem FFT
input fft_wren;//regfft_wren=0:read,regfft_wren=1:write
input clk,reset;

output [39:0]fft_outr,fft_outi;//point FFT

//parameter WIDTH=255;//128 thanh ghi
parameter WIDTH=255;//256 thanh ghi
integer i;

reg [39:0] registers_r[WIDTH:0];//128 thanh ghi cho phan thuc,moi thanh ghi 40bits
reg [39:0] registers_i[WIDTH:0];//128 thanh ghi cho phan ao,moi thanh ghi 40bits

// The asynchronous read logic
assign fft_outr = registers_r[fft_addr];
assign fft_outi = registers_i[fft_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers_r[i]<=0;
        registers_i[i]<=0;
      end
  else
    if(fft_wren)// The synchronous write logic
      begin
        registers_r[fft_addr]<=fft_inr;
        registers_i[fft_addr]<=fft_ini;
      end
end
endmodule
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
module reghw(ham_data,ham_addr,clk,reset);
      
output [4:0]ham_data;//hamming window coefficient (5bits 2's complement)
reg [4:0]ham_data;

//input [6:0]ham_addr;//truy cap 2^7=128 thanh ghi, can 80 thanh ghi
//Thuong 29Oct13 begin
input [7:0]ham_addr;//truy cap 2^7=128 thanh ghi, can 80 thanh ghi 
//Thuong 29Oct13 end
//input wr_en;
input clk,reset;

always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    ham_data<=0;
  end
  else
  begin
/*-----assign different register to output----*/
    case(ham_addr)
	    0:  ham_data <= 1;
	    1:  ham_data <= 1;
	    2:  ham_data <= 1;
	    3:  ham_data <= 1;
	    4:  ham_data <= 1;
	    5:  ham_data <= 1;
	    6:  ham_data <= 1;
	    7:  ham_data <= 1;
	    8:  ham_data <= 1;
	    9:  ham_data <= 1;
	    10: ham_data <= 1;
	    11: ham_data <= 1;
	    12: ham_data <= 2;
	    13: ham_data <= 2;
	    14: ham_data <= 2;
	    15: ham_data <= 2;
	    16: ham_data <= 2;
	    17: ham_data <= 2;
	    18: ham_data <= 3;
	    19: ham_data <= 3;
	    20: ham_data <= 3;
	    21: ham_data <= 3;
	    22: ham_data <= 3;
	    23: ham_data <= 4;
	    24: ham_data <= 4;
	    25: ham_data <= 4;
	    26: ham_data <= 4;
	    27: ham_data <= 5;
	    28: ham_data <= 5;
	    29: ham_data <= 5;
	    30: ham_data <= 5;
	    31: ham_data <= 6;
	    32: ham_data <= 6;
	    33: ham_data <= 6;
	    34: ham_data <= 6;
	    35: ham_data <= 7;
	    36: ham_data <= 7;
	    37: ham_data <= 7;
	    38: ham_data <= 8;
	    39: ham_data <= 8;
	    40: ham_data <= 8;
	    41: ham_data <= 9;
	    42: ham_data <= 9;
	    43: ham_data <= 9;
	    44: ham_data <= 9;
	    45: ham_data <= 10;
	    46: ham_data <= 10;
	    47: ham_data <= 10;
	    48: ham_data <= 10;
	    49: ham_data <= 11;
	    50: ham_data <= 11;
	    51: ham_data <= 11;
	    52: ham_data <= 12;
	    53: ham_data <= 12;
	    54: ham_data <= 12;
	    55: ham_data <= 12;
	    56: ham_data <= 13;
	    57: ham_data <= 13;
	    58: ham_data <= 13;
	    59: ham_data <= 13;
	    60: ham_data <= 13;
	    61: ham_data <= 14;
	    62: ham_data <= 14;
	    63: ham_data <= 14;
	    64: ham_data <= 14;
	    65: ham_data <= 14;
	    66: ham_data <= 14;
	    67: ham_data <= 15;
	    68: ham_data <= 15;
	    69: ham_data <= 15;
	    70: ham_data <= 15;
	    71: ham_data <= 15;
	    72: ham_data <= 15;
	    73: ham_data <= 15;
	    74: ham_data <= 15;
	    75: ham_data <= 15;
	    76: ham_data <= 15;
	    77: ham_data <= 15;
	    78: ham_data <= 15;
	    79: ham_data <= 15;
	    80: ham_data <= 15;
	    81: ham_data <= 15;
	    82: ham_data <= 15;
	    83: ham_data <= 15;
	    84: ham_data <= 15;
	    85: ham_data <= 15;
	    86: ham_data <= 15;
	    87: ham_data <= 15;
	    88: ham_data <= 15;
	    89: ham_data <= 15;
	    90: ham_data <= 15;
	    91: ham_data <= 15;
	    92: ham_data <= 15;
	    93: ham_data <= 14;
	    94: ham_data <= 14;
	    95: ham_data <= 14;
	    96: ham_data <= 14;
	    97: ham_data <= 14;
	    98: ham_data <= 14;
	    99: ham_data <= 13;
	    100:ham_data <= 13;
	    101:ham_data <= 13;
	    102:ham_data <= 13;
	    103:ham_data <= 13;
	    104:ham_data <= 12;
	    105:ham_data <= 12;
	    106:ham_data <= 12;
	    107:ham_data <= 12;
	    108:ham_data <= 11;
	    109:ham_data <= 11;
	    110:ham_data <= 11;
	    111:ham_data <= 10;
	    112:ham_data <= 10;
	    113:ham_data <= 10;
	    114:ham_data <= 10;
	    115:ham_data <= 9;
	    116:ham_data <= 9;
	    117:ham_data <= 9;
	    118:ham_data <= 9;
	    119:ham_data <= 8;
	    120:ham_data <= 8;
	    121:ham_data <= 8;
	    122:ham_data <= 7;
	    123:ham_data <= 7;
	    124:ham_data <= 7;
	    125:ham_data <= 6;
	    126:ham_data <= 6;
	    127:ham_data <= 6;
	    128:ham_data <= 6;
	    129:ham_data <= 5;
	    130:ham_data <= 5;
	    131:ham_data <= 5;
	    132:ham_data <= 5;
	    133:ham_data <= 4;
	    134:ham_data <= 4;
	    135:ham_data <= 4;
	    136:ham_data <= 4;
	    137:ham_data <= 3;
	    138:ham_data <= 3;
	    139:ham_data <= 3;
	    140:ham_data <= 3;
	    141:ham_data <= 3;
	    142:ham_data <= 2;
	    143:ham_data <= 2;
	    144:ham_data <= 2;
	    145:ham_data <= 2;
	    146:ham_data <= 2;
	    147:ham_data <= 2;
	    148:ham_data <= 1;
	    149:ham_data <= 1;
	    150:ham_data <= 1;
	    151:ham_data <= 1;
	    152:ham_data <= 1;
	    153:ham_data <= 1;
	    154:ham_data <= 1;
	    155:ham_data <= 1;
	    156:ham_data <= 1;
	    157:ham_data <= 1;
	    158:ham_data <= 1;
	    159:ham_data <= 1;
      default:  ham_data<=0;
    endcase
  end
end
endmodule
module reglog (clk,reset,reglog_addr,reglog_wren,reglog_in, reglog_out );
output [15:0] reglog_out;
input  [2:0] reglog_addr;
input [15:0]reglog_in;
input reglog_wren;//reglog_wren=0:read,reglog_wren=1:write
input clk,reset;

parameter WIDTH=5;//4 thanh ghi
integer i;

reg [15:0] registers[WIDTH:0];//4 thanh ghi

// The asynchronous read logic
assign reglog_out = registers[reglog_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0) begin
    for(i=0;i<=WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  end
  else begin
      if(reglog_wren == 1'b1) begin // The synchronous write logic
      registers[reglog_addr]<=reglog_in;
   end 
   end  //end else
end // end always
endmodule
module regp(regmel_out,regmel_in,regmel_addr,regmel_wren,clk,reset);
      
output [44:0]regmel_out;//power coefficient

input [4:0]regmel_addr;//truy cap 2^5=32 thanh ghi, can 23 he so cong suat,S
input [44:0]regmel_in;
input regmel_wren;//regmel_wren=0:read,regmel_wren=1:write
input clk,reset;

parameter WIDTH=31;//32 thanh ghi
integer i;

reg [44:0] registers[WIDTH:0];//32 thanh ghi,moi thanh ghi 45bits

// The asynchronous read logic
assign regmel_out = registers[regmel_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers[i]<=0;
      end
  else
    if(regmel_wren)// The synchronous write logic
      registers[regmel_addr]<=regmel_in;
end
endmodule
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
module regx(kt,xlout,xsout,cadder_out,single,wr_en,clear,clk,reset);

output [20:0]xlout,xsout;
output kt;
input [20:0]cadder_out;
input single;
input wr_en,clear;
input clk,reset;

reg [20:0]xlout,xsout;
reg kt;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		xlout<=21'h100000;
		xsout<=21'h100000;
		kt<=1;
	end
	else
	begin
		if(clear==1)
		begin
			xlout<=21'h100000;//so am nho nhat
			xsout<=21'h100000;
			kt<=1;
		end
		if(wr_en==1)
		begin
		  kt<=0;
			if(single==1)
			begin
				xlout<=cadder_out;
			end
			else
			begin
			   if (xlout==21'h100000)
			    xlout<=cadder_out;
			  else
			    if (xsout==21'h100000)
			      xsout<=cadder_out;
				if(cadder_out>xlout)
				begin
					xlout<= cadder_out;
					xsout<=xlout;
				end
				else
					if(cadder_out>xsout)
						xsout<=cadder_out;
			end
			//xsout<=cadder_out;
		end
	end
end
endmodule
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
module speech_ram(speech_data,speech_addr,speech_wren);

output [15:0]speech_data;

input speech_wren;
input [21:0]speech_addr;

reg [15:0] data_ram[0:4194303];//2^22 address
integer i;
initial begin 
  $display("TETETTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT");
  $readmemh("sample.txt", data_ram);   
  
  //for(i=0;i<4194303;i=i+1) begin
     //$display("data_ram =%h",data_ram[i]);  
  //end  
end
assign speech_data = speech_wren?0:data_ram[speech_addr];
//always@(posedge clk or negedge reset)
//begin
//  if(reset==0)
//    begin
//      speech_data<=0;
//    end
//  else
//    begin
//      $display("speech_data = %h", speech_data);
//    end
//end
endmodule
module square(mulout,in,en,clk,reset);//en,clk,reset);//17*5 multiplier,output 21bit

input [15:0]in;//16 bit 2's complement (1 sign bit plus 4 data bits)

input en;
input clk,reset;

output [30:0]mulout;//31bit 2's complement (windowed samples)(1 sign bit plus 20 data bits)

reg  [30:0]mulout;
wire [16:0]boothout1,boothout2,boothout3,boothout4,boothout5,boothout6,boothout7,boothout8;//length(booth)=length(in2)+1
wire [30:0]cout1,cout2,cout3,cout4,cout5,cout6,cout7;
wire [30:0]mulout1,mulout2,mulout3,mulout4,mulout5,mulout6,mulout7;

reg [30:0]a,b;
wire [30:0]sum;
reg state;

//See 5.4.2 Multiplier
 
booth16 booth1(boothout1,{in[1:0],1'b0},in);
booth16 booth2(boothout2,in[3:1],in);
booth16 booth3(boothout3,in[5:3],in);
booth16 booth4(boothout4,in[7:5],in);
booth16 booth5(boothout5,in[9:7],in);
booth16 booth6(boothout6,in[11:9],in);
booth16 booth7(boothout7,in[13:11],in);
booth16 booth8(boothout8,in[15:13],in);

//csa=carry save adder

csa31squ csa31squ1(cout1,mulout1,{13'b0,~boothout1[16],boothout1},
          {11'b0,~boothout2[16],boothout2,2'b0},{9'b0,~boothout3[16],boothout3,4'b0});
          
csa31squ csa31squ2(cout2,mulout2,{7'b0,~boothout4[16],boothout4,6'b0},
          {5'b0,~boothout5[16],boothout5,8'b0},{3'b0,~boothout6[16],boothout6,10'b0});
                    
csa31squ csa31squ3(cout3,mulout3,{1'b0,~boothout7[16],boothout7,12'b0},{boothout8,14'b0},{14'b10101010101011,17'b0});//m=5-->chuoi 101010...1011 chi co (m/2)-1=1 bit 0-->011,so bit 0 them vao cuoi=length(boothout)

          
csa31squ csa31squ4(cout4,mulout4,{cout1[29:0],1'b0},mulout1,{cout2[29:0],1'b0});//hai carry + 1 sum

csa31squ csa31squ5(cout5,mulout5,mulout2,{cout3[29:0],1'b0},mulout3);//hai sum + 1 carry

csa31squ csa31squ6(cout6,mulout6,{cout4[29:0],1'b0},mulout4,{cout5[29:0],1'b0});//hai carry + 1 sum

csa31squ csa31squ7(cout7,mulout7,{cout6[29:0],1'b0},mulout6,mulout5);//1 carry + hai sum


cla31squ cla31squ(sum,a,b);


always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    mulout<=0;
    a<=0;
    b<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a<={cout7[29:0],1'b0};
        b<=mulout7;
        state<=1;
      end
    end
    1:
    begin
      mulout<=sum;
      state<=0;
    end
    endcase
  end
end

endmodule
module sroot(regfftoutr,regfftouti,out,en,clk,reset);// 41bit cla

input [39:0]regfftoutr,regfftouti;
input en,clk,reset;

output [40:0]out;

reg [40:0]out;
wire [40:0]tout;
wire [39:0]inr,ini;
wire [40:0]in1,in2;
wire [41:0]tout1;

assign inr={regfftoutr[39]}?~regfftoutr+1:regfftoutr;//|I|-->absolute values of the real part
assign ini={regfftouti[39]}?~regfftouti+1:regfftouti;//|Q|-->absolute values of the imaginary part
assign in1=(inr>ini)?{1'b0,inr}:{3'b0,inr[39:2]};//max{|I|,|Q|}
assign in2=(inr>ini)?{3'b0,ini[39:2]}:{1'b0,ini};//min{|I|,|Q|}/4

cla41 cla41(tout1,in1,in2);

assign tout=tout1[40:0];
always@(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    out<=0;
  end
  else
  begin
    if(en==1)
      out<=({{6{tout[40]}},tout[40:6]});//chia ket qua khoi tinh bien do cho 64 (giong kq cua Matlab)
  end
end
endmodule
module sub16pre(sum,a,b);//cin=1

input [16:0]a,b;
output [16:0]sum;//sum=a+b+1
wire [2:0]ctmp;
wire [2:0]gp,gg;
wire tc;

/*generate block carry using block generate and propagate*/

assign ctmp[0]=gg[0]|(gp[0]&tc);
assign ctmp[1]=gg[1]|(gg[0]&gp[1])|(gp[1]&gp[0]&tc);
assign ctmp[2]=gg[2]|(gg[1]&gp[2])|(gg[0]&gp[1]&gp[2])|(gp[2]&gp[1]&gp[0]&tc);
assign tc=a[0]|b[0];
assign sum[0]=~(a[0]^b[0]);

/*connect four 4-bit carry look ahead adder together to be a 16-bit carry look ahead adder
with block generate and propagate*/

cla4i cla4_0(sum[4:1],tc,a[4:1],b[4:1],gp[0],gg[0]);
cla4i cla4_1(sum[8:5],ctmp[0],a[8:5],b[8:5],gp[1],gg[1]);
cla4i cla4_2(sum[12:9],ctmp[1],a[12:9],b[12:9],gp[2],gg[2]);
cla4i cla4_3(sum[16:13],ctmp[2],a[16:13],b[16:13]);

endmodule
module sub39(out,A,B);//S=A-B=A+bu2(B)=A+[bu1(B)+1]

parameter WIDTH=38;

input      [WIDTH:0]A,B;

output [WIDTH:0]out;

reg [WIDTH+1:0]S;
wire [WIDTH:0]Bs;
reg [WIDTH+1:0] C;
reg [WIDTH:0] G,P;
integer ii;

assign Bs=~(B)+1;
assign out=S[WIDTH:0];
 
always @* begin
  C[0] = 1'b0;
  for(ii=0;ii<=WIDTH;ii=ii+1) 
  begin
    G[ii] = A[ii] & Bs[ii];
    P[ii] = A[ii] ^ Bs[ii];
    C[ii+1] = G[ii] | (P[ii]&C[ii]);
    S[ii] = P[ii] ^ C[ii];
  end
  S[WIDTH+1] = ~C[WIDTH+1];
end
endmodule
module sub(en,out,in1,in2,clk,reset);

input [20:0]in1,in2;
input clk,reset;
input en;

output [20:0]out;

reg [20:0]out;
wire [20:0]im1;
wire [20:0]p;
wire [19:0]g;
wire [20:0]c;
wire [20:0]sum;

assign im1=~in1;
assign p=im1^in2;
assign g=im1[19:0]&in2[19:0];
assign c[0]=1;
assign c[20:1]=g[19:0]|p[19:0]&c[19:0];
assign sum=p^c;

always@(posedge clk or negedge reset)
begin
	if(reset==0)
	begin
		out<=0;
	end
	else
	begin
		if(en==1)
		begin
			out<=sum;
		end
	end
end
endmodule
module test_core(result_ack,result,overflow,start,clk,reset);

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
wire [7:0]framenum;

wire [15:0]speech_data;
wire speech_wren=(!ready)|fs;
wire fram_wren=ready^fs;

assign fram_datain=(ready^fs)?fram_datain2:fram_datain1;//{{6{a[15]}},a[15:5]}
wire [15:0]data_in_de=((regcep_addr[4:0]==12)|(regcep_addr[4:0]==25))?{{10{regcep_out[15]}},regcep_out[15:10]}:regcep_out;

fecore fecore(fe_data,fe_address,
      regcep_in,feregcep_addr,regcep_wren,
      framenum,shiftc,shiftd,
      start,ready,fefinish,fs,clk,reset);
			
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

regcep regcep(regcep_out,regcep_in,regcep_addr,regcep_wren,clk,reset);//4.MFCC RAM

model_ram  model_ram(.fram_dataout(fram_datain1),.fram_addr(fram_address),.fram_wren(fram_wren));//5.flash RAM stored model parameters

speech_ram speech_ram(.speech_data(speech_data),.speech_addr({2'b0,fram_address[20:1]}),.speech_wren(speech_wren));//6.speech RAM

read_speech read_speech(.addr_in({2'b0,fram_address}),.sdram_in(speech_data),.sdram_out(fram_datain2));

endmodule
module window(in2,in1,out,en,clk,reset);//en,clk,reset);//17*5 multiplier,output 21bit

input [4:0]in1;//5 bit 2's complement (hamming window) (1 sign bit plus 4 data bits)
input [16:0]in2;//17 bit 2's complement (preemphasized samples) (1 sign bit plus 15 data bits)
input en;
input clk,reset;

output [20:0]out;//21bit 2's complement (windowed samples)(1 sign bit plus 20 data bits)
reg  [20:0]out;

wire [17:0]boothout1,boothout2,boothout3;//length(booth)=length(in2)+1
wire [20:0]cout1,cout2;
wire [20:0]mulout1,mulout2;

reg [19:0]a20,b20;
wire [19:0]sum20;
reg state;
reg t;

 //See 5.4.2 Multiplier
 
booth17 booth1(boothout1,{in1[1:0],1'b0},in2);//chen them bit 0 vao
booth17 booth2(boothout2,in1[3:1],in2);
booth17 booth3(boothout3,{in1[4],in1[4:3]},in2);//so bit vao le (5 bit) --> mo rong sign bit (in1[4])

//csa=carry save adder

csa21win csa21win1(cout1,mulout1,{2'b0,~boothout1[17],boothout1},
          {~boothout2[17],boothout2,2'b0},{boothout3[16:0],4'b0});
csa21win csa21win2(cout2,mulout2,{cout1[19:0],1'b0},mulout1,{3'b011,18'b0});//m=5-->chuoi 101010...1011 chi co (m/2)-1=1 bit 0-->011,so bit 0 them vao cuoi=length(boothout)


cla20win cla20win(sum20,a20,b20);

always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    state<=0;
    a20<=0;
    b20<=0;
    out<=0;
    t<=0;
  end
  else
  begin
    case(state)
    0:
    begin
      if(en==1)
      begin
        a20<=cout2[19:0];
        b20<=mulout2[20:1];
        t<=mulout2[0];
        state<=1;
      end
    end
    1:
    begin
      out<={sum20,t};//sum20[19] is the signbit
      state<=0;
    end
    endcase
  end
end
endmodule
