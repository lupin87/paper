module MYPFA(A,B,C,S,P,G);
input A,B,C;
output S,P,G;

assign G=A&B;
assign P=A^B;
assign S=P^C;

endmodule
