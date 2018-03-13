import apb_pkg::*;

class example_env extends uvm_component;

   `uvm_component_utils_begin(example_env)
      `uvm_field_object(regmodel, UVM_ALL_ON)
   `uvm_component_utils_end

   BLK_regmodel regmodel; 
   apb_agent    apb;
   uvm_reg_sequence seq;
`ifdef EXPLICIT_MON
   uvm_reg_predictor#(apb_rw) apb2reg_predictor; `endif

   function new(string name, uvm_component parent=null);
      super.new(name,parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      if (regmodel == null) begin
         regmodel = BLK_regmodel::type_id::create("regmodel", this);
         regmodel.build();
         regmodel.lock_model();
         
         apb = apb_agent::type_id::create("apb", this); `ifdef EXPLICIT_MON
         apb2reg_predictor = new("apb2reg_predictor", this); `endif
      end
      
      begin
        string hdl_root = "tb_top.dut";
        void'($value$plusargs("ROOT_HDL_PATH=%s",hdl_root));
        regmodel.set_hdl_path_root(hdl_root);
      end

   endfunction

   virtual function void connect_phase(uvm_phase phase);
      if (apb != null) begin
         reg2apb_adapter reg2apb = new;
         regmodel.default_map.set_sequencer(apb.sqr,reg2apb);
`ifdef EXPLICIT_MON
         apb2reg_predictor.map = regmodel.default_map;
         apb2reg_predictor.adapter = reg2apb;
         regmodel.default_map.set_auto_predict(0);
         apb.mon.ap.connect(apb2reg_predictor.bus_in);
`else
         regmodel.default_map.set_auto_predict(1);
`endif
      end
      //regmodel.print();
   endfunction

endclass
