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
