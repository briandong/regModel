class example_base_seq #(type BASE=uvm_sequence #(uvm_reg_item)) extends uvm_reg_sequence #(BASE);

  rand int count;
  constraint c1 { count > 0; count < 10; }

  // Register with the factory
  `uvm_object_utils_begin(example_base_seq)
    `uvm_field_int(count, UVM_ALL_ON)
    `uvm_field_object(regmodel, UVM_ALL_ON)
  `uvm_object_utils_end

  BLK_regmodel regmodel;

  // The sequence’s constructor
  function new (string name = "example_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
	uvm_reg_data_t data, data_exp;

    //`uvm_info(get_type_name(), $psprintf("has %0d item(s)", count), UVM_LOW)
    //repeat (count)
    //  `uvm_do(req)

    // Check ID
	regmodel.REG_ID.read(status, data, .parent(this));
	if (status == UVM_NOT_OK)
	  `uvm_error(get_full_name(), "REGMODEL BAD READ OP");
	data_exp = 'h01765A03;
	if (data != data_exp)
	  `uvm_error(get_full_name(), $sformatf("REGMODEL BAD READ DATA: expected-%0h got-%0h", data_exp, data));

    // Check Data
	data_exp = 'h5A5AA5A5;
	regmodel.REG_DATA.write(status, data_exp, .parent(this));
	if (status == UVM_NOT_OK)
	  `uvm_error(get_full_name(), "REGMODEL BAD WRITE OP");
	regmodel.REG_DATA.read(status, data, .parent(this));
	if (status == UVM_NOT_OK)
	  `uvm_error(get_full_name(), "REGMODEL BAD READ OP");
	if (data != data_exp)
	  `uvm_error(get_full_name(), $sformatf("REGMODEL BAD READ DATA: expected-%0h got-%0h", data_exp, data));

    // Check Cluster
	for (int i=0; i<8; i++)
	  regmodel.REG_CLUSTER[i].write(status, i, .parent(this));
	for (int i=0; i<8; i++) begin
	  regmodel.REG_CLUSTER[i].read(status, data, .parent(this));
	  if (data != i)
	    `uvm_error(get_full_name(), $sformatf("REGMODEL BAD READ DATA: expected-%0h got-%0h", i, data));
	end
  endtask

  virtual task pre_body();
    uvm_test_done.raise_objection(this);

	uvm_resource_db#(BLK_regmodel)::read_by_name("top_resource", "reg_model", regmodel);
	if (regmodel == null) 
	  `uvm_error(get_full_name(), "REGMODEL IS NULL");

    #200;
  endtask

  virtual task post_body();
    uvm_test_done.drop_objection(this);
  endtask

endclass


class example_backdoor_seq extends example_base_seq;
  // Register with the factory
  `uvm_object_utils(example_backdoor_seq)

  // The sequence’s constructor
  function new (string name = "example_backdoor_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
	uvm_reg_data_t data, data_exp;

	super.body();

    // Check ID
	regmodel.REG_ID.read(status, data, UVM_BACKDOOR, .parent(this));
	if (status == UVM_NOT_OK)
	  `uvm_error(get_full_name(), "REGMODEL BAD READ OP");
	data_exp = 'h01765A03;
	if (data != data_exp)
	  `uvm_error(get_full_name(), $sformatf("REGMODEL BAD READ DATA: expected-%0h got-%0h", data_exp, data));

    // Check Data
	data_exp = 'hC001C0DE;
	regmodel.REG_DATA.write(status, data_exp, UVM_BACKDOOR, .parent(this));
	if (status == UVM_NOT_OK)
	  `uvm_error(get_full_name(), "REGMODEL BAD WRITE OP");
	regmodel.REG_DATA.read(status, data, UVM_BACKDOOR, .parent(this));
	if (status == UVM_NOT_OK)
	  `uvm_error(get_full_name(), "REGMODEL BAD READ OP");
	if (data != data_exp)
	  `uvm_error(get_full_name(), $sformatf("REGMODEL BAD READ DATA: expected-%0h got-%0h", data_exp, data));

    // Check Cluster
	for (int i=0; i<8; i++)
	  regmodel.REG_CLUSTER[i].write(status, 7-i, UVM_BACKDOOR, .parent(this));
	for (int i=0; i<8; i++) begin
	  regmodel.REG_CLUSTER[i].read(status, data, UVM_BACKDOOR, .parent(this));
	  if (data != 7-i)
	    `uvm_error(get_full_name(), $sformatf("REGMODEL BAD READ DATA: expected-%0h got-%0h", 7-i, data));
	end
  endtask

endclass
