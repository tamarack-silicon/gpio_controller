package gpio_ctrl_csr_ral_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;
	import gpio_ctrl_bank_csr_ral_pkg::*;

	class gpio_ctrl_intr_status_reg extends uvm_reg;
		rand uvm_reg_field intr_status;

		function new(string name = "gpio_ctrl_intr_status_reg");
			super.new(name, 32, UVM_NO_COVERAGE);
		endfunction : new

		virtual function void build();
			this.intr_status = new("intr_status");
			this.intr_status.configure(this, 32, 0, "W1C", 0, 'h0, 1, 1, 0);
		endfunction : build
	endclass : gpio_ctrl_intr_status_reg

	class gpio_ctrl_csr #(integer NUM_BANKS = 8) extends uvm_reg_block;

		`uvm_object_param_utils(gpio_ctrl_csr#(NUM_BANKS))

		gpio_ctrl_bank_csr bank_csr[NUM_BANKS];
		gpio_ctrl_intr_status_reg intr_status;

		function new(string name = "gpio_ctrl_csr");
			super.new(name, UVM_NO_COVERAGE);
		endfunction // new

		virtual function void build();
			default_map = create_map("gpio_ctrl_csr_map", 0, 4, UVM_LITTLE_ENDIAN);

			foreach (bank_csr[i]) begin
				bank_csr[i] = gpio_ctrl_bank_csr::type_id::create($sformatf("bank_csr[%0d]", i));
				bank_csr[i].configure(this);
				bank_csr[i].build();
				default_map.add_submap(bank_csr[i].default_map, i * 'h10);
			end

			intr_status = new("intr_status");
			intr_status.configure(this);
			intr_status.build();
			default_map.add_reg(this.intr_status, 'h200);
		endfunction // build

	endclass // gpio_ctrl_csr

endpackage: gpio_ctrl_csr_ral_pkg
