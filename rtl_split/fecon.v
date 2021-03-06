module fecon( regfft_wren,regfft_addr, regfft_addrt, regfft_insel,regfft_clear,
      cfft_addr, rd_en,
      cm_en,comadd_en,cm_shift,
      addsubfft_en,addsubfft_sel,addsubfft_shift,
      start,fft_finish,clk,reset);

output rd_en;


output regfft_wren;
output [7:0]regfft_addr;
output [8:0]regfft_addrt;
output regfft_insel,regfft_clear;
reg regfft_wren;
reg preemp_en;
reg [7:0]regfft_addr;
reg [8:0]regfft_addrt; //Thuong 29Oct13
reg regfft_insel,regfft_clear;

output [6:0]cfft_addr;
reg [6:0]cfft_addr;

output cm_en,comadd_en,cm_shift;
reg cm_en,comadd_en,cm_shift;

output addsubfft_en,addsubfft_sel,addsubfft_shift;
reg addsubfft_en,addsubfft_sel,addsubfft_shift;

input start,clk,reset;

output fft_finish;
reg fft_finish;

reg [3:0]state;
reg [3:0]statef;//for fft
reg [4:0]statem;//for mel
reg d1,d2,dt;
reg [2:0]counterf;

reg [7:0]frame_num;//maximum 256 frames
reg [7:0]frame_addr;//address for eriting frames,true framenum + 1
reg [4:0]cep_addr;
reg [31:0]count_addr; //Thuong 29Oct13
reg [15:0]count_fn; //Thuong 29Oct13

assign rd_en=regfft_wren && (state == 2); // Thuong change for frame calculation

always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    count_addr<=1; // Thuong 29Oct13
    
    regfft_wren<=0;
    regfft_addr<=0;
    regfft_addrt<=0;
    regfft_insel<=0;
    regfft_clear<=0;
    
    addsubfft_en<=0;
    addsubfft_sel<=0;
    addsubfft_shift<=0;
    
    
    statem<=0;
    counterf<=0;
    statef<=0;
    state<=0;
    fft_finish<=0;
    count_fn<=0;
    preemp_en<=0;
  end
  else
  begin
  case(state)
  0://wait for start signal
    begin
    if (start == 1) begin
      state <= 2;
   end 
  end
  2://preemp and windowing, energy calculation
  begin
      if(regfft_addrt==256) begin
          regfft_addr<=1;
          regfft_addrt<=0;
          state<=3;
          regfft_wren<=0;
      end
      else begin
          preemp_en<=~preemp_en;
          if (preemp_en == 1) begin
             regfft_addrt<=regfft_addrt+1;
             regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
                          regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
             regfft_wren<=1;
          end
          else begin
             regfft_wren<=0;
          end
      end
 end  
  3://finish preemp and windowing, energy calculation
  begin
      if(regfft_addrt==0)
        begin
         regfft_insel<=1;
         regfft_clear<=0;
         addsubfft_sel<=1;//moi them vao ngay 18/7/2010
         regfft_addr<=1;
         regfft_addrt<=0;
         regfft_wren<=0;
         state<=4;
        end
      else
         begin
           regfft_addrt<=regfft_addrt+1;
           regfft_addr<=regfft_addrt;//moi them vao
           regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
         end
  end
  4://clear regfft, co sua regc_addr
  begin
      state <=5;
  end
  5://FFT 1st,mel
  begin
      case(statef)
      0:
      begin
        regfft_addr<=regfft_addrt;
        regfft_addrt<=regfft_addr;
        addsubfft_sel<=0;//them vao ngay 18/7/2011
        addsubfft_en<=1;//them vao ngay 18/7/2011
        statef<=statef+1;
      end
      1:
      begin
        addsubfft_en<=0;//them vao ngay 18/7/2011
        regfft_wren<=1;//them vao ngay 18/7/2011
        addsubfft_sel<=0;
        statef<=statef+1;
      end
      2:
      begin
        addsubfft_sel<=0;//sua lai
        addsubfft_en<=0;
        regfft_wren<=1;//sua lai
        regfft_addr<=regfft_addrt;//moi them vao
        regfft_addrt<=regfft_addr;//moi them vao
        statef<=statef+1;
      end
      3:
      begin
        if(regfft_addr==255)
        begin
          addsubfft_sel<=0;//moi them vao
          cm_en<=1;//sua
          regfft_wren<=0;//them vao
          regfft_addr<=2;
          regfft_addrt<=0;
          cfft_addr<=0;
          cm_shift<=1;
          statem<=0;
          statef<=0;//moi them vao
          state<=state+1;
        end
        else
        begin
        regfft_addr<=regfft_addrt;
        regfft_addrt<=regfft_addr;
        addsubfft_sel<=1;//them vao
        regfft_wren<=0;//sua lai
        regfft_addr<=regfft_addr+2;//moi them
        regfft_addrt<=regfft_addrt+2;//moi them
        statef<=0;
        end
      end
      endcase
  end

  6://fft 2nd-7th,dct,delta
  begin
    case(statef)//tinh FFT
    0:
    begin
      cm_en<=0;
      statef<=statef+1;
    end
    1://moi them
    begin
      comadd_en<=1;//moi them vao
      statef<=statef+1;
    end
    2:
    begin
      regfft_addr<=regfft_addrt; //regfft_addr<=regfft_addr+1;
      cm_en<=0;
      comadd_en<=0;//moi sua
      addsubfft_en<=1;//moi them vao
      case(counterf)
        0: cfft_addr[6]<=~cfft_addr[6];
        1: cfft_addr[6:5]<=cfft_addr[6:5]+1;
        2: cfft_addr[6:4]<=cfft_addr[6:4]+1;
        3: cfft_addr[6:3]<=cfft_addr[6:3]+1;
        4: cfft_addr[6:2]<=cfft_addr[6:2]+1;
        5: cfft_addr[6:1]<=cfft_addr[6:1]+1;
        6: cfft_addr<=cfft_addr+1;
      endcase
      statef<=statef+1;
    end
    3://moi them
    begin
      addsubfft_en<=0;//moi them vao
      regfft_wren<=1;//moi them vao
      statef<=statef+1;
    end
    4://////////////////////sua lai
    begin
      regfft_wren<=1;//moi them vao
      case(counterf)
      0: regfft_addr<=regfft_addr+2;
      1: regfft_addr<=regfft_addr+4;
      2: regfft_addr<=regfft_addr+8;
      3: regfft_addr<=regfft_addr+16;
      4: regfft_addr<=regfft_addr+32;
      5: regfft_addr<=regfft_addr+64;
      6: regfft_addr<=regfft_addr+128;// Thuong
      endcase
      //regfft_addr<=regfft_addr+2;//moi them vao
      statef<=statef+1;
     end
    5:
    begin
      cm_en<=1;
      regfft_wren<=0;//moi them vao
      //comadd_en<=1;
      //addsubfft_en<=0;//sua
      regfft_addr<=regfft_addr+1;//regfft_addr<=regfft_addrt;
      statef<=statef+1;
    end
    6://moi them
    begin
      cm_en<=0;
      comadd_en<=0;//moi them vao
      statef<=statef+1;
    end
    7:
    begin
      cm_en<=0;//sua lai cm_en<=1
      comadd_en<=1;//moi sua
      //addsubfft_en<=1;//moi them vao
      case(counterf)
        0: cfft_addr[6]<=~cfft_addr[6];
        1: cfft_addr[6:5]<=cfft_addr[6:5]+1;
        2: cfft_addr[6:4]<=cfft_addr[6:4]+1;
        3: cfft_addr[6:3]<=cfft_addr[6:3]+1;
        4: cfft_addr[6:2]<=cfft_addr[6:2]+1;
        5: cfft_addr[6:1]<=cfft_addr[6:1]+1;
        6: cfft_addr<=cfft_addr+1;
      endcase
      statef<=statef+1;
    end
    8:
    begin
      cm_en<=0;
      comadd_en<=0;
      addsubfft_en<=1;
      regfft_addr<=regfft_addrt+1;//regfft_addr<=regfft_addr+1;
      statef<=statef+1;
    end
    9://moi them
    begin
      regfft_wren<=1;//moi them vao
      addsubfft_en<=0;//moi them vao
      statef<=statef+1;
    end
    10://///////////////////sua lai
    begin
      //regfft_wren<=0;//moi them vao
      comadd_en<=0;
      addsubfft_en<=0;
      case(counterf)
      0: regfft_addr<=regfft_addr+2;
      1: regfft_addr<=regfft_addr+4;
      2: regfft_addr<=regfft_addr+8;
      3: regfft_addr<=regfft_addr+16;
      4: regfft_addr<=regfft_addr+32;
      5: regfft_addr<=regfft_addr+64;
      6: regfft_addr<=regfft_addr+128;//Thuong
      endcase
      //regfft_addr<=regfft_addrt+3;//regfft_addr<=regfft_addrt;
      regfft_addrt<=regfft_addr;
      regfft_wren<=1;
      statef<=statef+1;
    end
    11:
    begin
      cm_en<=1;//moi them vao
      regfft_wren<=0;
      //if(regfft_addr==127)
      if(regfft_addr==255)
      begin
        regfft_addrt<=0;
        case(counterf)
        0: 
        begin
          regfft_addr<=4;
          counterf<=counterf+1;
        end
        1:
        begin
          regfft_addr<=8;
          counterf<=counterf+1;
        end
        2:
        begin
          regfft_addr<=16;
          counterf<=counterf+1;
        end
        3:
        begin
          regfft_addr<=32;
          counterf<=counterf+1;
        end
        4: //Thuong add for 256 point
        begin
          regfft_addr<=64;
          counterf<=counterf+1;
        end
        5:
        begin
          regfft_addr<=128;
          cm_shift<=0;
          addsubfft_shift<=1;
          counterf<=counterf+1;
        end
        6:
        begin
          regfft_addr<=0;
          counterf<=0;
          addsubfft_shift<=0;
          statem<=0;
          cm_en<=0;//moi them vao
          state<=state+1;
        end
        endcase //endcase statef
      end
      else
      begin
//Thuong add for test
//        if(frame_num==0) begin
//          regc_addrt<=1; //frame_num == 0
//        end
        if(cfft_addr==0)
        begin
          case(counterf)
          0:
          begin
            regfft_addr<=regfft_addr+3;
            regfft_addrt<=regfft_addrt+3;
          end
          1:
          begin
            regfft_addr<=regfft_addr+5;
            regfft_addrt<=regfft_addrt+5;
          end
          2:
          begin
            regfft_addr<=regfft_addr+9;
            regfft_addrt<=regfft_addrt+9;
          end
          3:
          begin
            regfft_addr<=regfft_addr+17;
            regfft_addrt<=regfft_addrt+17;
          end
          4:
          begin
            regfft_addr<=regfft_addr+33;
            regfft_addrt<=regfft_addrt+33;
          end
          5: //Thuong add for 256 FFT
          begin
            regfft_addr<=regfft_addr+65;
            regfft_addrt<=regfft_addrt+65;
          end
          endcase
        end
        else
        begin
          regfft_addr<=regfft_addr+1;
          regfft_addrt<=regfft_addrt+1;
        end
      end
      statef<=0;
    end
    endcase
  end
        
  
  7://fft spectrum
  begin
  regfft_addr<=regfft_addr+1;
  
   if(regfft_addr==255)
  begin
        regfft_insel<=0;
        statef<=0;
        state<=8;
    end
  end
 8 :
  begin
        fft_finish<=1;
        count_fn <= count_fn+1;
        if (count_fn == 3) begin
            state<=9;
            count_fn <= 0;
        end
  end
 9 :
  begin
        fft_finish<=0;
        state<=0;
  end
  endcase
end
end
endmodule
