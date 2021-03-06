#!/bin/sh

# Clean up the results directory
rm -rf results
mkdir results

#Synthesize the Wrapper Files
echo 'Synthesizing XST wrapper file (core_top.vhd) with XST';
echo 'Synthesizing example design with XST';
xst -ifn xst.scr
cp BRAM_WF_top.ngc ./results/


# Copy the netlist generated by Coregen
echo 'Copying files from the netlist directory to the results directory'
cp ../../BRAM_WF.ngc results/

#  Copy the constraints files generated by Coregen
echo 'Copying files from constraints directory to results directory'
cp ../example_design/BRAM_WF_top.ucf results/

cd results

echo 'Running ngdbuild'
ngdbuild -p xc6slx45-fgg484-3 BRAM_WF_top

echo 'Running map'
map BRAM_WF_top -o mapped.ncd -pr i

echo 'Running par'
par mapped.ncd routed.ncd

echo 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

echo 'Running design through bitgen'
bitgen -w routed

echo 'Running netgen to create gate level VHDL model'
netgen -ofmt vhdl -sim -tm BRAM_WF_top -pcf mapped.pcf -w routed.ncd routed.vhd
