class example_base_test extends uvm_test;

  `uvm_component_utils(example_base_test)

  example_env example_env0;

  // The test’s constructor
  function new (string name = "example_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    example_env0 = example_env::type_id::create("example_env0", this);
    uvm_config_db#(uvm_object_wrapper)::set(this, "example_env0.apb.sqr.run_phase",
      "default_sequence", example_base_seq::type_id::get());
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_resource_db#(BLK_regmodel)::set("top_resource", "reg_model", example_env0.regmodel);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

  virtual task run_phase(uvm_phase phase);
    //set a drain-time for the environment if desired 
    phase.phase_done.set_drain_time(this, 1000);
  endtask

endclass


class example_backdoor_test extends example_base_test;

  `uvm_component_utils(example_backdoor_test)

  // The test’s constructor
  function new (string name = "example_backdoor_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_object_wrapper)::set(this, "example_env0.apb.sqr.run_phase",
      "default_sequence", example_backdoor_seq::type_id::get());
  endfunction

endclass
