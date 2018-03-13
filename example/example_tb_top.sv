`include "apb.sv"
`include "example_dut.sv"
`include "example_regmodel.sv"
`include "example_env.sv"
`include "example_seq_lib.sv"
`include "example_test_lib.sv"

module tb_top;

   import uvm_pkg::*;
   import apb_pkg::*;

   bit clk = 0;
   bit rst = 1;

   apb_if apb_intf(clk);
   example_dut dut(apb_intf, rst);

   always #10 clk = ~clk;

   initial begin
       uvm_report_info("RESET","Performing reset of 5 cycles");
       repeat (5) @(posedge clk);
       rst <= 0;
   end

   initial begin
      uvm_config_db#(apb_vif)::set(null, "*.apb", "vif", apb_intf);
      run_test();
   end

   //dump fsdb
   //`ifdef FSDB
   initial begin
      $fsdbDumpfile("test.fsdb");
      $fsdbDumpvars(0, tb_top);
      $fsdbDumpflush;
   end
   //`endif

endmodule: tb_top
