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
