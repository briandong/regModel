`timescale 1ns/1ns

module example_dut(apb_if apb,
             input bit rst);

reg [31:0] pr_data;
assign apb.prdata = (apb.psel && apb.penable && !apb.pwrite) ? pr_data : 'z;

reg [31:0] REG_ID;
reg [31:0] REG_DATA;
//reg [63:0] SOCKET[256];
reg [31:0] MEM_RAM[1024];

always @ (posedge apb.pclk)
  begin
   if (rst) begin
      REG_ID <= {4'h0, 10'h176, 8'h5A, 8'h03};
      REG_DATA <= 'h00;
      //foreach (SOCKET[i]) begin
      //   SOCKET[i] <= 64'h0000_0000;
      //end
      pr_data <= 32'h0;
   end
   else begin

      // Wait for a SETUP+READ or ENABLE+WRITE cycle
      if (apb.psel == 1'b1 && apb.penable == apb.pwrite) begin
         pr_data <= 32'h0;
         if (apb.pwrite) begin
            casex (apb.paddr)
              16'h0104: REG_DATA <= apb.pwdata;
              //16'h1XX0: SOCKET[apb.paddr[11:4]][63:32] <= apb.pwdata; 
              //16'h1XX4: SOCKET[apb.paddr[11:4]][31: 0] <= apb.pwdata;
              16'h011X: MEM_RAM[apb.paddr[11:2]] <= apb.pwdata;
            endcase
         end
         else begin
            casex (apb.paddr)
              16'h0100: pr_data <= REG_ID;
              16'h0104: pr_data <= REG_DATA;
              //16'h1XX0: pr_data <= SOCKET[apb.paddr[11:4]][63:32];
              //16'h1XX4: pr_data <= SOCKET[apb.paddr[11:4]][31: 0];
              16'h011X: pr_data <= MEM_RAM[apb.paddr[11:2]];
            endcase
         end
      end
   end
end

endmodule
