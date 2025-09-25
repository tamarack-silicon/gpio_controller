package apb_agent_pkg;

	import uvm_pkg::*;

	class apb_item extends uvm_sequence_item;

		`uvm_object_utils(apb_item)

		function new(string name = "apb_item");
			super.new(name);
		endfunction // new

		rand bit [11:0] paddr;
		rand bit		pwrite;
		rand bit		psel;
		rand bit		penable;
		rand bit [3:0]	pstrb;
		rand bit [31:0]	pwdata;
		bit [31:0]		prdata;
		bit				pready;
		bit				pslverr;

	endclass // apb_item

	class apb_driver extends uvm_driver;

		`uvm_component_utils(apb_driver)

		function new(string name = "apb_driver", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual apb_if apb_vif;

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) begin
				`uvm_fatal("APB_DRIVER", "Can not get virtual interface")
			end
		endfunction // build_phase

	endclass // apb_driver

	class apb_agent extends uvm_agent;

		`uvm_component_utils(apb_agent)

		apb_driver driver;
		uvm_sequencer#(apb_item) sequencer;

		function new(string name = "apb_agent", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			sequencer = uvm_sequencer#(apb_item)::type_id::create("sequencer", this);
			driver = apb_driver::type_id::create("driver", this);
		endfunction // build_phase

	endclass // apb_agent

endpackage // apb_agent_pkg
