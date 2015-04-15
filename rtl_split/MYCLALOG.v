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
