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
