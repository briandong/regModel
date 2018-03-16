`timescale 1ns/1ns

module example_dut(apb_if apb,
             input bit rst);

reg [31:0] pr_data;
assign apb.prdata = (apb.psel && apb.penable && !apb.pwrite) ? pr_data : 'z;

reg [31:0] REG_ID;
reg [31:0] REG_DATA;
reg [31:0] REG_CLUSTER[8];
reg [31:0] MEM_RAM[1024];

always @ (posedge apb.pclk)
  begin
   if (rst) begin
      REG_ID <= {4'h0, 10'h176, 8'h5A, 8'h03};
      REG_DATA <= 'h00;
      foreach (REG_CLUSTER[i]) begin
         REG_CLUSTER[i] <= 32'h0;
      end
      pr_data <= 32'h0;
   end
   else begin

      // Wait for a SETUP+READ or ENABLE+WRITE cycle
      if (apb.psel == 1'b1 && apb.penable == apb.pwrite) begin
         pr_data <= 32'h0;
         if (apb.pwrite) begin
            casex (apb.paddr)
              16'h0104: REG_DATA <= apb.pwdata;
              16'h011X, 16'h012X: REG_CLUSTER[(apb.paddr-'h110)>>2] <= apb.pwdata; 
              16'h02XX: MEM_RAM[(apb.paddr-'h200)>>2] <= apb.pwdata;
            endcase
         end
         else begin
            casex (apb.paddr)
              16'h0100: pr_data <= REG_ID;
              16'h0104: pr_data <= REG_DATA;
              16'h011X, 16'h012X: pr_data <= REG_CLUSTER[(apb.paddr-'h110)>>2];
              16'h02XX: pr_data <= MEM_RAM[(apb.paddr-'h200)>>2];
            endcase
         end
      end
   end
end

endmodule
