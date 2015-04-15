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
