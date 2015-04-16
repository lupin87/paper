module fecon(ram_addr,ram_addrt,
      square_en,
      eadder_en,eadder_new,eadder_sel,
      ereg_we,
      log_en,log_sel,log_overf,
      preemp_en,preemp_en_out,preemp_new,preemp_state_en,
      cham_addr,
      win_en,win_en_mask,
      regfft_wren,regfft_addr, regfft_addrt, regfft_insel,regfft_clear,
      cfft_addr, rd_en,
      cm_en,comadd_en,cm_shift,
      addsubfft_en,addsubfft_sel,addsubfft_shift,
      sroot_en,
      regffte_addr,regffte_wren,
      addmel_en,addmel_sel,addmel_new,
      regmel_addr,regmel_wren,
      regdct_addr,regdct_wren,
      cdct_addr,
      muldct_en,
      addsubdct_en,addsubdct_sub,addsubdct_new,
      regc_addr,regc_wren,regc_sel,
      reglog_addr, reglog_wren,
      delta_new,delta_sub,delta_shift,delta_en,
      regcep_addr,regcep_wren,
      framenum,
      start,ready,fefinish,fs,clk,reset);

output [14:0]ram_addr;//80*256
output ram_addrt;//16bit in 2 8bit
reg [14:0]ram_addr;
reg [31:0]ram_addr_st;
reg ram_addrt;

output square_en;
output rd_en;

output eadder_en,eadder_sel,eadder_new;
reg eadder_en,eadder_sel,eadder_new,eadder_new1;

output ereg_we;
reg ereg_we;

input log_overf;
output log_en,log_sel;
reg log_sel;

output preemp_en,preemp_new;
output preemp_en_out;
output preemp_state_en;
reg preemp_en,preemp_new;

output [7:0]cham_addr; //Thuong
reg [7:0]cham_addr;

output win_en;
output win_en_mask;
reg win_en;

output regfft_wren;
output [7:0]regfft_addr;
output [8:0]regfft_addrt;
output regfft_insel,regfft_clear;
reg regfft_wren;
reg [7:0]regfft_addr;
reg [8:0]regfft_addrt; //Thuong 29Oct13
reg regfft_insel,regfft_clear;

output [6:0]cfft_addr;
reg [6:0]cfft_addr;

output cm_en,comadd_en,cm_shift;
reg cm_en,comadd_en,cm_shift;

output addsubfft_en,addsubfft_sel,addsubfft_shift;
reg addsubfft_en,addsubfft_sel,addsubfft_shift;

output sroot_en;
reg sroot_en;

//output [5:0]regffte_addr;
output [6:0]regffte_addr; // Thuong for 256 FFT
output regffte_wren;
reg [6:0]regffte_addr; // Thuong for 256 FFT
reg regffte_wren;

output addmel_en,addmel_sel,addmel_new;
reg addmel_en,addmel_sel,addmel_new;


output [4:0]regmel_addr;
output reg regmel_wren;//moi sua
reg [4:0]regmel_addr;

output [4:0]regdct_addr;
output regdct_wren;
reg [4:0]regdct_addr;
reg regdct_wren;

output [7:0]cdct_addr;
reg [7:0]cdct_addr;

output muldct_en;
reg muldct_en;

output addsubdct_en,addsubdct_sub,addsubdct_new;
reg addsubdct_en,addsubdct_sub,addsubdct_new;

output [6:0]regc_addr;
output [2:0]reglog_addr; //Thuong add
output      reglog_wren; //Thuong add
output regc_wren;
output [1:0]regc_sel;
reg [6:0]regc_addr;
reg [2:0]reglog_addr;
reg reglog_wren1;
reg reglog_wren2;
reg reglog_wren;
reg [2:0]regc_addrt,regc_addrc;
reg [2:0]regc_addrt_mod;
reg regc_wren;
reg [1:0]regc_sel;

output delta_new,delta_sub,delta_shift,delta_en;
reg delta_new,delta_sub,delta_shift,delta_en;

output [12:0]regcep_addr;
output regcep_wren;
reg regcep_wren;

input start,ready,fs,clk,reset;

output fefinish;
reg fefinish;

output [7:0]framenum;
reg [7:0]framenum;

reg [2:0]state;
reg [3:0]statef;//for fft
reg [4:0]statem;//for mel
reg d1,d2,dt;
reg [2:0]counterf;

reg [7:0]frame_num;//maximum 256 frames
reg [7:0]frame_addr;//address for eriting frames,true framenum + 1
reg [4:0]cep_addr;
reg [31:0]count_addr; //Thuong 29Oct13

assign rd_en=regfft_wren && (state == 2); // Thuong change for frame calculation
//assign square_en=preemp_new^preemp_en; // Thuong change for frame calculation
assign square_en=preemp_en; // Thuong change for frame calculation
//Thuong change for frame 
//assign log_en=(frame_num!=1 && statem!=0 && state==5)?addmel_new:log_sel;
assign log_en=(statem!=0 && state==5)?regmel_wren:log_sel; // Change to use frame
//assign regmel_wren=addmel_sel;//moi bo
assign regcep_addr={frame_addr,cep_addr};
always @(state) begin
 if (state == 2) begin
  count_addr<=count_addr+1; //Thuong 29Oct13
 end
end
always @ (regfft_addrt or state) begin
 if (state == 2) begin
    if (count_addr != 1  && regfft_addrt == 154) begin
 //ram_addr_st<=80*(count_addr-1)+1; //Thuong 29Oct13
    ram_addr_st<=80*(count_addr-1); //Thuong 29Oct13
end
end
end

assign preem_en_mask = (regfft_addrt == 158) ? 1'b0: 1'b1;
assign preemp_en_out = preemp_en & preem_en_mask;
assign preemp_state_en = (state == 1) && (statef==3) && (count_addr!= 1 );
assign win_en_mask = ((state == 3) && (statef==1)) ? 1'b0 : 1'b1;

always @(posedge clk) begin
       reglog_wren1 <= log_sel;
       reglog_wren2 <= reglog_wren1;
       reglog_wren  <= reglog_wren2;
end


always @(posedge clk or negedge reset)
begin
  if(reset==0)
  begin
    count_addr<=1; // Thuong 29Oct13
    ram_addr<=0;
    ram_addr_st<=0;
    ram_addrt<=0;
    
    eadder_en<=0;
    eadder_sel<=0;
    eadder_new<=0;
    eadder_new1<=0;
    
    ereg_we<=0;
    
    log_sel<=0;
    
    preemp_en<=0;
    preemp_new<=0;
    
    cham_addr<=0;
    
    win_en<=0;
    
    regfft_wren<=0;
    regfft_addr<=0;
    regfft_addrt<=0;
    regfft_insel<=0;
    regfft_clear<=0;
    
    cfft_addr<=0;
    
    cm_en<=0;
    comadd_en<=0;
    cm_shift<=0;
    
    addsubfft_en<=0;
    addsubfft_sel<=0;
    addsubfft_shift<=0;
    
    sroot_en<=0;
    
    regffte_addr<=0;
    regffte_wren<=0;
    
    addmel_en<=0;
    addmel_sel<=0;
    addmel_new<=0;
    
    regmel_wren<=0;//moi them
    regmel_addr<=0;
    
    regdct_addr<=0;
    regdct_wren<=0;
    
    cdct_addr<=0;
    
    muldct_en<=0;
    
    addsubdct_en<=0;
    addsubdct_sub<=0;
    addsubdct_new<=0;
    
    reglog_addr<=0; //for Log register - Thuong add

    regc_addr<=0;
    regc_addrt<=0;
    regc_addrt_mod<=0;
    regc_addrc<=2;
    regc_wren<=0;
    regc_sel<=3;//sua 0-->3
    
    delta_new<=0;
    delta_sub<=0;
    delta_shift<=0;
    delta_en<=0;
    
    regcep_wren<=0;
    
    framenum<=0;
    
    frame_num<=0;
    frame_addr<=0;
    
    cep_addr<=31;
    
    statem<=0;
    
    d1<=0;
    d2<=0;
    dt<=0;
    statef<=0;
    counterf<=0;
    state<=0;
    fefinish<=0;
  end
  else
  begin
  case(state)
  0://wait for start signal
    begin
    case(statef)
    0:
      begin
      if(ready==1)
      begin
        fefinish<=0;
        
        regfft_addr<=0;
        regfft_addrt<=0;
        regfft_clear<=0;
        regfft_wren<=0;
        
        regc_addr<=0;
        regc_addrt<=0;
        regc_wren<=0;
        
        frame_num<=0;
        frame_addr<=0;
        regc_addrc<=2;
        
        dt<=0;
        statef<=statef+1;
      end
    end
    1:
    begin
      if(start==0 && fs==0)
      begin
        ram_addrt<=1;
        statef<=statef+1;
      end
    end
    2:
    begin
      ram_addrt<=0;
      preemp_new<=1;
      preemp_en<=1;
      ram_addr<=ram_addr+1;
      statef<=0;
      state<=state+1;
    end
    endcase
  end
  1://start preemp and windowing, energy calculation
  begin
    preemp_new<=0;
    preemp_en<=~preemp_en;
    //if((preemp_en==1) && (count_addr != 1))
    if((count_addr != 1)&&(statef==1))
    begin
	ram_addr <= ram_addr + 1;
    end
   else if (preemp_en==0 ) begin
	ram_addr <= ram_addr + 1;
    end
    case(statef)
    0:
    begin
      ram_addrt<=1;
      statef<=statef+1;
    end
    1:
    begin
      ram_addrt<=0;
      if (frame_num == 0) begin      // Thuong added for frame calculation
          eadder_en<=~eadder_en; // Thuong added for frame calculation
          eadder_new<=1;         // Thuong added for frame calculation
      end                        // Thuong added for frame calculation
      statef<=statef+1;
    end
    2:
    begin
      ram_addrt<=1;
      eadder_new<=0; // Thuong added for frame calculation
      if (frame_num == 0) begin      // Thuong added for frame calculation
      eadder_en<=~eadder_en; // Thuong added for frame calculation
      end                        // Thuong added for frame calculation
      statef<=statef+1;
    end
    3:
    begin
      //ram_addr <= ram_addr + 1;
      ram_addrt<=0;
      win_en<=~win_en;
      regfft_insel<=0;
      eadder_en<=~eadder_en; // Thuong added for frame calculation
      cham_addr<=cham_addr+1;
      statef<=0;
      state<=state+1;
    end
    endcase
  end
  2://preemp and windowing, energy calculation
  begin
//     if(log_overf==1) //End sampling
//     begin
//       fefinish<=1;
//       //framenum<=frame_addr;//sua lai
//       framenum<=frame_addr-4;//frame_addr:so vecto trich dac trung/sua
// //      framenum<=frame_addr;//frame_addr:so vecto trich dac trung/sua
//       ram_addr<=0;
//       ram_addrt<=0;
//       log_sel<=0; //Thuong add
//       eadder_en<=0; //Thuong add
//       preemp_en<=0; //Thuong add
//       reglog_wren<=0; //Thuong add
//       win_en<=0; //Thuong add
//       statef<=0;
//       state<=0;
//     end
//     else begin
//     win_en<=~win_en;
//     if (regfft_addrt==158) begin
//        log_sel<=1; // Thuong change to adjust timing
//     end
//     if (regfft_addrt==159) begin
//        log_sel<=0; // Thuong change to adjust timing
//     end
//        eadder_en<=~eadder_en;
    
//     if(preemp_en==1)
//     begin
//       ram_addrt<=1;
// //       regfft_wren<=0;
// //Thuong 29Oct13      if(regfft_addrt==78)
//       if(regfft_addrt==255)
//       begin
//         regc_addr[6:4]<=7;
//         regc_addr[3:0]<=0;
//         preemp_new<=1;//them
//       end
//     end
//     else
//     begin
      if(regfft_addrt==256) begin
          ram_addr<=ram_addr_st;
          regfft_addr<=1;
          regfft_addrt<=0;
          state<=3;
          regfft_wren<=0;
      end
      else begin
          preemp_en<=~preemp_en;
          ram_addr<=ram_addr+1;
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
      ram_addrt<=0;
//       cham_addr<=cham_addr+1;
//       regfft_addr<=regfft_addrt;//moi them vao
//     end
//   end
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
//           regfft_addr<=1;
//           regfft_addrt<=0;
//           state<=5;
//           regfft_wren<=0;
//     //eadder_en<=~eadder_en; // Thuong comment
//     cham_addr<=0;
//     ram_addrt<=0;
// //    eadder_new<=0;
//     case(statef)
//     0:
//     begin
//       eadder_en<=~eadder_en; // Thuong comment
//       eadder_new<=1;
//       preemp_en<=0;
//       win_en<=~win_en;
//       regfft_addrt<=regfft_addrt+1;
//       regfft_addr<=regfft_addrt;//moi them vao
//       regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
//             regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
//       regfft_wren<=~regfft_wren;
//       preemp_new<=0;//them
//       ram_addrt<=1;//them
//       if (reglog_addr!= 4 && frame_num != 1'b0)
//       reglog_addr <= reglog_addr + 1;
//       else
//       reglog_addr <= 0;
//       statef<=statef+1;
//     end
//     1:
//     begin
//       eadder_new<=0;
//       eadder_en<=~eadder_en; // Thuong comment
//       ram_addrt<=1;//them
//       regfft_wren<=~regfft_wren;
//       win_en<=~win_en;
//       statef<=statef+1;
//       log_sel<=0; // Thuong change to adjust timing
//     end
//     2:
//     begin
//       ram_addrt<=1;//them
//       eadder_sel<=1;
//       regfft_addrt<=regfft_addrt+1;
//       regfft_addr<=regfft_addrt;//moi them vao
//       regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
//             regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
//       regfft_wren<=~regfft_wren;
//       regfft_clear<=1;//ghi xong 80 mau, xoa 48 (48=128-80) thanh ghi con lai ve 0 => Thuong change to statef 2
//       ereg_we<=1;
//       statef<=statef+1;
//     end
//     3:
//     begin
//       ram_addrt<=1;//them
//       eadder_sel<=0;
//       regfft_addrt<=regfft_addrt+1;
//       regfft_addr<=regfft_addrt;//moi them vao
//       regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
//             regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
//       eadder_sel<=0;
//      // regfft_clear<=1;//ghi xong 80 mau, xoa 48 (48=128-80) thanh ghi con lai ve 0 => Thuong change to statef 2
// //      if(frame_num!=0)
//         
//       ereg_we<=0;
//       statef<=0;
//       state<=state+1;
//     end
//     endcase
  end
  4://clear regfft, co sua regc_addr
  begin
      state <=5;
//    case (statef) 
//        0 : begin
//              if(regfft_addrt==162) //Thuong add
//               statef <=1;
//            end
//        1 : begin
//               statef <=2;
//            end
//        2 : 
//          begin
//           if(regfft_addrt==164) //Thuong add
//              begin //Thuong add
//                 regc_addr[6:4]<=regc_addrt; //Thuong add
//                 regc_addr[3:0]<=12; //Thuong add
//                 regc_sel<=1; //Thuong add
//                 regc_wren<=1; //Thuong add
//                 //if (frame_num != 0) 
//                     reglog_addr <= regc_addrt;
//                 statef <=3;
//             end //Thuong add
//              
//          end
//        3 :
//          begin
////              if(regfft_addrt==161) //Thuong add
////                begin //Thuong add
//                 regc_wren<=0; //Thuong add
//                 regc_sel<=2; //Thuong add
//                 regc_addr[6:4]<=regc_addrt; //Thuong add
//                 regc_addr[3:0]<=0; //Thuong add
//                 statef <=4;
////                end //Thuong add
//          end
//        4 : begin
//               if (frame_num != 0 && reglog_addr != 4) begin
//               reglog_addr <= reglog_addr + 1;
//               end
//               else begin
//               reglog_addr <= 0;
//               end
//               statef <=5;
//            end
//        5 : begin
//               statef <=0;
//            end
//    endcase
//    ram_addrt<=1;//them
//    log_sel<=0;
//// Thuong modify timing of log_overf    if(log_overf==1)
//// Thuong modify timing of log_overf    begin
//// Thuong modify timing of log_overf      fefinish<=1;
//// Thuong modify timing of log_overf      //framenum<=frame_addr;//sua lai
//// Thuong modify timing of log_overf      framenum<=frame_addr-3;//frame_addr:so vecto trich dac trung/sua
//// Thuong modify timing of log_overf      ram_addr<=0;
//// Thuong modify timing of log_overf      ram_addrt<=0;
//// Thuong modify timing of log_overf      statef<=0;
//// Thuong modify timing of log_overf      state<=0;
//// Thuong modify timing of log_overf    end
////    else
////     begin
//      if(regfft_addrt==0)
//        begin
//         regfft_insel<=1;
//         regfft_clear<=0;
//         addsubfft_sel<=1;//moi them vao ngay 18/7/2010
//         regfft_addr<=1;
//         regfft_addrt<=0;
//         regfft_wren<=~regfft_wren;
//         addmel_new<=0;//moi sua
//         addmel_en<=0;//moi sua
//         regmel_addr<=0;
//         state<=state+1;
//        end
//      else
//         begin
//           regfft_addrt<=regfft_addrt+1;
//           regfft_addr<=regfft_addrt;//moi them vao
//           regfft_addr<={regfft_addrt[0],regfft_addrt[1],regfft_addrt[2],regfft_addrt[3],
//            regfft_addrt[4],regfft_addrt[5],regfft_addrt[6],regfft_addrt[7]}; // thuong add [7]
//         end
//// Thuong change to State=3 Statef = 1     if(frame_num!=0)
//// Thuong change to State=3 Statef = 1     begin 
//// Thuong change to State=3 Statef = 1//       if(regfft_addrt==82) Thuong add
//// Thuong change to State=3 Statef = 1       if(regfft_addrt==161)
//// Thuong change to State=3 Statef = 1          begin
//// Thuong change to State=3 Statef = 1             regc_addr[6:4]<=regc_addrt;
//// Thuong change to State=3 Statef = 1             regc_addr[3:0]<=12;
//// Thuong change to State=3 Statef = 1             regc_sel<=1;
//// Thuong change to State=3 Statef = 1             regc_wren<=1;
//// Thuong change to State=3 Statef = 1          end
//// Thuong change to State=3 Statef = 1       if(regfft_addrt==83)
//// Thuong change to State=3 Statef = 1         begin
//// Thuong change to State=3 Statef = 1             regc_wren<=0;
//// Thuong change to State=3 Statef = 1             regc_sel<=2;
//// Thuong change to State=3 Statef = 1             regc_addr[6:4]<=regc_addrt;
//// Thuong change to State=3 Statef = 1             regc_addr[3:0]<=0;
//// Thuong change to State=3 Statef = 1         end
//// Thuong change to State=3 Statef = 1      end
////      end
  end
  5://FFT 1st,mel
  begin
    if(statem!=0)
    begin
      if(regmel_wren==1)//moi sua
      begin
        addmel_sel<=0;
        regmel_addr<=regmel_addr+1;
        //addmel_new<=1;
      end
      if(addmel_new==1)
      begin
        addmel_new<=0;
      end
    end
    if(log_en==1)
      d2<=1;
    if(d2==1)
    begin
      d2<=0;
      regdct_wren<=1;
    end
    if(regdct_wren==1)
    begin
      regdct_wren<=0;
      regdct_addr<=regdct_addr+1;
    end
    if(frame_num!=0) //Thuong modify for frame calculation
    begin
      case(statem)
      0:
      begin
        addmel_en<=1;//moi them
        addmel_new<=1;//moi them
        regffte_addr<=0;
        statem<=statem+1;
      end
      1://moi them
      begin
        if(regffte_addr==1)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            regdct_wren<=0;//moi them
            end
          else
          begin
            d1<=0;
            regffte_addr<=0;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==0)
          addmel_sel<=0;//moi sua
      end
      2:
      begin
        if(regffte_addr==2)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=1;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==0)
          addmel_sel<=d1;//moi sua
      end
      3:
      begin
        if(regffte_addr==4)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=2;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==1)
          addmel_sel<=0;//moi sua
      end
      4:
      begin
        if(regffte_addr==5)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=4;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==2)
          addmel_sel<=0;//moi sua
      end
      5:
      begin
        if(regffte_addr==6)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=5;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==4)
          addmel_sel<=0;
      end
      6:
      begin
        if(regffte_addr==8)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=6;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==5)
          addmel_sel<=0;
      end
      7:
      begin
        if(regffte_addr==9)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=8;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==6)
          addmel_sel<=0;
      end
      8:
      begin
      if(regffte_addr==11)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=9;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==8)
        addmel_sel<=0;
      end
      9:
      begin
      if(regffte_addr==13)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=11;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==9)
        addmel_sel<=0;
      end
      10:
      begin
      if(regffte_addr==15)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=13;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==11)
        addmel_sel<=0;
      end
      11:
      begin
      if(regffte_addr==17)
      begin
        regmel_wren<=1;//moi them
        if(d1==0)
          begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
        else
        begin
          d1<=0;
          regffte_addr<=15;
          regmel_wren<=0;//moi them
          addmel_new<=1;//moi them vao
          statem<=statem+1;
        end
      end
      else
        regffte_addr<=regffte_addr+1;
      if(regffte_addr==13)
        addmel_sel<=0;
      end
      12:
      begin
        if(regffte_addr==19)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=17;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==15)
          addmel_sel<=0;
      end
      13:
      begin
        if(regffte_addr==22)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=19;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==17)
          addmel_sel<=0;
      end
      14:
      begin
        if(regffte_addr==25)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=22;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==19)
          addmel_sel<=0;
      end
      15:
      begin
        if(regffte_addr==28)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=25;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
          if(regffte_addr==22)
            addmel_sel<=0;
      end
      16:
      begin
        if(regffte_addr==31)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=28;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==25)
          addmel_sel<=0;
      end
      17:		
      begin
        if(regffte_addr==34)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=31;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==28)
          addmel_sel<=0;
      end
      18:
      begin
        if(regffte_addr==38)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=34;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==31)
          addmel_sel<=0;
      end
      19:
      begin
        if(regffte_addr==42)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=38;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==34)
          addmel_sel<=0;
      end
      20:
      begin
        if(regffte_addr==47)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=42;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==38)
          addmel_sel<=0;
      end
      21:	
      begin
        if(regffte_addr==52)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=47;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==42)
          addmel_sel<=0;
      end
      22:			
      begin
        if(regffte_addr==57)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            regffte_addr<=52;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi them vao
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
        if(regffte_addr==47)
          addmel_sel<=0;
      end
      23:
      begin
        if(regffte_addr==63)
        begin
          regmel_wren<=1;//moi them
          if(d1==0)
            begin//moi them
            d1<=1;
            addmel_sel<=1;
            end
          else
          begin
            d1<=0;
            addmel_en<=0;//moi them vao
            regffte_addr<=0;
            regmel_wren<=0;//moi them
            addmel_new<=1;//moi sua
            statem<=statem+1;
          end
        end
        else
          regffte_addr<=regffte_addr+1;
      end
      24:
      begin
        statem<=statem+1;
      end
      //25:
        //addmel_en<=0;
      endcase
    end // Thuong for frame calculation
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
      /*3:
      begin
        addsubfft_en<=0;
        regfft_wren<=1;//moi them vao ngay 18/7/2011
        //regfft_wren<=0;
        statef<=statef+1;
      end*/
      3:
      begin
        //statef<=statef+1;
      //end
      //4:
      //begin
        //regfft_wren<=0;
        //addsubfft_sel<=0;//sua lai
     //   if(regfft_addr==127) //Thuong 31Oct13
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
          regdct_addr<=0;
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
          //addsubfft_sel<=0;//them vao
          //addsubfft_en<=1;//them vao
          //regfft_addr<=regfft_addr;
          //regfft_addrt<=regfft_addrt;
        //end
        statef<=0;
        end
      end
      endcase
  end

  6://fft 2nd-7th,dct,delta
  begin
//  if(frame_num!=0&&frame_num!=1)//sua
  if(frame_num!=0)// Thuong for frame calculation
  begin
    case(statem)
    0:
    begin
      muldct_en<=1;//moi sua
      addsubdct_new<=0;
      addsubdct_en<=0;
      if(regdct_addr==1 && cdct_addr[7:4]!=0)
        regc_wren<=1;
        
      statem<=statem+1;
    end
    1:
    begin
      if(regdct_addr==22)
      begin
        regdct_addr<=0;
        cdct_addr[7:4]<=cdct_addr[7:4]+1;
        if(cdct_addr[7:4]==11)
        begin
          statem<=statem+1;
          cdct_addr[7:4]<=0;
        end
        else
        begin
          cdct_addr[7:4]<=cdct_addr[7:4]+1;
          statem<=0;
        end
      end
      else
      begin
        regdct_addr<=regdct_addr+1;
        if(regdct_addr<11)
          cdct_addr[3:0]<=cdct_addr[3:0]+1;
        else
          cdct_addr[3:0]<=cdct_addr[3:0]-1;
        statem<=0;
      end
      muldct_en<=0;
      if(regdct_addr==13 && cdct_addr[4]==0)
        addsubdct_sub<=1;
      if(regdct_addr!=0 || cdct_addr[7:4]!=0)
        addsubdct_en<=1;
      if(regdct_addr==1)
      begin
        addsubdct_new<=1;
        addsubdct_sub<=0;
      end
      if(regc_wren==1)
      begin
        regc_wren<=0;
        regc_addr[3:0]<=regc_addr[3:0]+1;
      end
      //statem<=0;//moi them
    end
    2:
    begin
      muldct_en<=0;
      addsubdct_en<=0;
      statem<=statem+1;
    end
    3:
    begin
      if(addsubdct_en==0)
        addsubdct_en<=1;
      else
      begin
        addsubdct_en<=0;
        regc_wren<=1;
        statem<=statem+1;
      end
    end
    4://////////
    begin
      regc_wren<=0;
      regc_addr[3:0]<=0;
      if(regc_addr[6:4]!=4 && dt==0)
      begin
        regc_addrt<=regc_addrt+1;//them
        //regc_addrt<=regc_addr[6:4]+1;
        statem<=10;
      end
      else //tinh he so delta
      begin
        //delta_new<=1;//moi them vao
        //delta_en<=1;//moi them vao
        regc_addrt<=regc_addr[6:4];//regc_addr=64
        dt<=1;
        regc_sel<=3;//
        delta_en<=1;//moi them
        delta_new<=1;//moi them
        delta_sub<=0;//moi them
        delta_shift<=0;//moi them
        statem<=statem+1;
      end
    end
    5:
    begin
      delta_new<=0;//moi them
      delta_sub<=1;//moi them
      delta_shift<=1;//moi them
      if(regc_addr[6:4]==4)
        regc_addr[6:4]<=0;
      else
        regc_addr[6:4]<=regc_addr[6:4]+1;
        
      statem<=statem+1;
    end
    6:
    begin
      delta_sub<=0;//moi them
      delta_shift<=0;//moi them
      case(regc_addr[6:4])
      0: regc_addr[6:4]<=3;//0--->48
      1: regc_addr[6:4]<=4;//16-->64
      2: regc_addr[6:4]<=0;//32-->0
      3: regc_addr[6:4]<=1;//48-->16
      4: regc_addr[6:4]<=2;//64-->32
      endcase
      /*delta_en<=1;
      if(delta_en==0)
        delta_new<=1;
      if(delta_new==1)
      begin
        delta_new<=0;
        delta_sub<=1;
        delta_shift<=1;
      end
      
      if(delta_shift==1)
      begin
        delta_sub<=0;
        delta_shift<=0;
        statem<=statem+1;
      end*/
      statem<=statem+1;
    end
    7:
    begin
      case(regc_addr[6:4])//moi them
      0: regc_addr[6:4]<=3;//0--->48
      1: regc_addr[6:4]<=4;//16-->64
      2: regc_addr[6:4]<=0;//32-->0
      3: regc_addr[6:4]<=1;//48-->16
      4: regc_addr[6:4]<=2;//64-->32
      endcase
      if(delta_sub==0)
        delta_sub<=1;
      else
      begin
        delta_sub<=0;
        delta_en<=0;
        regc_wren<=1;
        regc_addr[6:4]<=5;//addr=80
        statem<=statem+1;
        end
    end
    8://ghi he so delta vao thanh ghi regcep
    begin	
      regc_addr[3:0]<=regc_addr[3:0]+1;//moi them
      delta_en<=1;//moi them
      if(delta_en==0)
        delta_new<=1;
      if(delta_new==1)
      begin
        delta_new<=0;
        delta_sub<=1;
        delta_shift<=1;
      end
      
      if(delta_shift==1)
      begin
        delta_sub<=0;
        delta_shift<=0;
        statem<=statem+1;
      end//moi them
      regc_wren<=0;
      if(regc_addr[3:0]==12)//xong 13 he so cepstrum
        begin
        regc_addr[3:0]<=0;
        regc_addr[6:4]<=regc_addrc;
        if(regc_addrt!=4)
          regc_addrt<=regc_addrt+1;
        else
          regc_addrt<=0;
          
        if(regc_addrc!=4)
          regc_addrc<=regc_addrc+1;
            
      else
          regc_addrc<=0;
            
        regcep_wren<=1;//moi them,ghi cac phan tu vecto dac trung vao thanh ghi regcep
        cep_addr<=cep_addr+1;//moi them
        statem<=statem+1;
      end
      else
      begin
        regc_addr[6:4]<=regc_addrt;
        regc_addr[3:0]<=regc_addr[3:0]+1;
        statem<=5;//statem<=5;//moi sua
      end
    end
    //9:
    //begin
      //regc_addr[3:0]<=regc_addr[3:0]+1;
      //statem<=statem+1;
    //end
    9:
    begin
      if(cep_addr==25)//26 phan tu vec to dac trung
      begin
        cep_addr<=31;
        frame_addr<=frame_addr+1;//dem so vecto dac trung
        regcep_wren<=0;
        statem<=statem+1;
      end
      else
      begin
        regcep_wren<=1;
        cep_addr<=cep_addr+1;
        if(cep_addr==12)//moi sua
        begin
          regc_addr[6:4]<=5;
          regc_addr[3:0]<=0;
        end
        else
        begin
          regc_addr[3:0]<=regc_addr[3:0]+1;
        end
      end
  end
  endcase // endcase statem
  end
    case(statef)//tinh FFT
    0:
    begin
      cm_en<=0;
      statef<=statef+1;
      //cm_en<=1;//moi them vao
      //comadd_en<=0;//moi them vao
      //addsubfft_en<=0;//moi them vao
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
// Thuong 31Oct13
//      0: cfft_addr[5]<=~cfft_addr[5];
//      1: cfft_addr[5:4]<=cfft_addr[5:4]+1;
//      2: cfft_addr[5:3]<=cfft_addr[5:3]+1;
//      3: cfft_addr[5:2]<=cfft_addr[5:2]+1;
//      4: cfft_addr[5:1]<=cfft_addr[5:1]+1;
//      5: cfft_addr<=cfft_addr+1;
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
    //2://moi them
    //begin
     // cm_en<=1;
     // comadd_en<=0;//moi them
     // addsubfft_en<=0;//moi them vao
     // statef<=statef+1;
  //	end
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
// Thuong 31Oct13
//      0: cfft_addr[5]<=~cfft_addr[5];
//      1: cfft_addr[5:4]<=cfft_addr[5:4]+1;
//      2: cfft_addr[5:3]<=cfft_addr[5:3]+1;
//      3: cfft_addr[5:2]<=cfft_addr[5:2]+1;
//      4: cfft_addr[5:1]<=cfft_addr[5:1]+1;
//      5: cfft_addr<=cfft_addr+1;
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
          sroot_en<=1;//moi them
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
  
  if(regfft_addr==0)
    begin
    regffte_wren<=1;
    regffte_addr<=0;
    end
    
  if(regffte_wren==1)
    regffte_addr<=regffte_addr+1;

  if(regffte_addr==62)//moi them vao
  //if(regffte_addr==126)//moi them vao
    sroot_en<=0;//moi them vao
  
  if(regffte_addr==63)//Thuong for 256 point
  //if(regffte_addr==127)//moi them vao
    begin
    regffte_addr<=0;//moi them vao
    regffte_wren<=0;//moi them vao
    end
  
  //if(regfft_addr==65)
    //sroot_en<=0;
  
  if(sroot_en==0)
    regffte_wren<=0;
    
  //if(regffte_wren==0)
    //regffte_addr<=0;
    
  // if(regfft_addr==66) Thuong modify for timing
   if(regfft_addr==255)
  begin
      regfft_insel<=0;
      if(frame_num==255)
      begin
        fefinish<=1;
        framenum<=frame_addr-2;
        ram_addr<=0;
        ram_addrt<=0;
        statef<=0;
        state<=0;
      end
      else
      begin
        frame_num<=frame_num+1;
        statef<=1;
        state<=1;
      end
    end
  end
  endcase
end
end
endmodule
