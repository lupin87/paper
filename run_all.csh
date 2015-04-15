#!/bin/csh

set sample_speech_dir = ./sample_trung/
set sample = "sau_1_after_cut_to_HW.txt"
# foreach i (`ls $sample_speech_dir`) 
   cp $sample_speech_dir/$sample sample.txt
   vlogan -full64 -f rtl_list.lf +incdir+./rtl_split/ ; vcs -full64 test_core_tb -debug_pp;simv	
#    vcs -f rtl_list.lf -full64 -R +v2k -debug_pp test_core_tb.v -l log_simv +incdir+./rtl_split/ 
#    mv output.txt result/${i}_result
# end
