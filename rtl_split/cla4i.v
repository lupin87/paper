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
