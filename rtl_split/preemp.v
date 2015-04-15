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
