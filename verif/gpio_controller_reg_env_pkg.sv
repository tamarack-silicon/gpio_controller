package gpio_controller_reg_env_pkg;

	import uvm_pkg::*;
	import gpio_ctrl_csr_ral_pkg::*;
	import apb_agent_pkg::*;

	class reg2apb_adapter extends uvm_reg_adapter;

		`uvm_object_utils(reg2apb_adapter)

		function new(string name = "reg2apb_adapter");
			super.new(name);
		endfunction // new

		virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

		endfunction // reg2bus

		virtual function bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

		endfunction // bus2reg

	endclass // reg2apb_adapter

endpackage // gpio_controller_reg_env_pkg
