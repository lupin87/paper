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
