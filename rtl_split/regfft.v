module regfft(fft_outr,fft_outi,fft_inr,fft_ini,fft_addr,fft_wren,clk,reset);
      
input [39:0]fft_inr,fft_ini;
//input [6:0]fft_addr;//truy cap 2^7=128 thanh ghi, can luu 128 diem FFT
input [7:0]fft_addr;//truy cap 2^8=256 thanh ghi, can luu 128 diem FFT
input fft_wren;//regfft_wren=0:read,regfft_wren=1:write
input clk,reset;

output [39:0]fft_outr,fft_outi;//point FFT

//parameter WIDTH=255;//128 thanh ghi
parameter WIDTH=255;//256 thanh ghi
integer i;

reg [39:0] registers_r[WIDTH:0];//128 thanh ghi cho phan thuc,moi thanh ghi 40bits
reg [39:0] registers_i[WIDTH:0];//128 thanh ghi cho phan ao,moi thanh ghi 40bits

// The asynchronous read logic
assign fft_outr = registers_r[fft_addr];
assign fft_outi = registers_i[fft_addr];

always@(posedge clk or negedge reset)
begin 
  if(reset==0)
    for(i=0;i<WIDTH;i=i+1) 
      begin
        registers_r[i]<=0;
        registers_i[i]<=0;
      end
  else
    if(fft_wren)// The synchronous write logic
      begin
        registers_r[fft_addr]<=fft_inr;
        registers_i[fft_addr]<=fft_ini;
      end
end
endmodule
