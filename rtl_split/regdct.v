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
