module regcep(regcep_out,regcep_in,regcep_addr,regcep_wren,clk,reset);
      
output [15:0]regcep_out;//feature vector MFCC of n_th frame

input [12:0]regcep_addr;//truy cap 2^13=8192 thanh ghi,can truy cap 256*26=6656 thanh ghi (max co 256 frame, moi frame co 26 vector dac trung)
input [15:0]regcep_in;
input regcep_wren;//regcep_wren=0:read,regcep_wren=1:write
input clk,reset;

parameter WIDTH=8191;//8192 thanh ghi
integer i,j;

reg [15:0] registers[WIDTH:0];//8192 thanh ghi,moi thanh ghi 16bits

// The asynchronous read logic
//assign regcep_out = registers[regcep_addr];
reg [15:0] regcep_out;

initial begin 
  $readmemh("sample.txt", registers);   
  $display ("%h value",registers[1]);
end

always@(posedge clk)
begin 
    if(~regcep_wren)// The synchronous write logic
         regcep_out = registers[regcep_addr];
end
endmodule
