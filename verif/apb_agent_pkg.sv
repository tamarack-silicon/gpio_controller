package apb_agent_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;

	class apb_item extends uvm_sequence_item;

		`uvm_object_utils(apb_item)

		function new(string name = "apb_item");
			super.new(name);
		endfunction // new

		rand bit [10:0] paddr;
		rand bit		pwrite;
		rand bit [3:0]	pstrb;
		rand bit [31:0]	pwdata;

		bit [31:0]		prdata;
		bit				pslverr;

	endclass // apb_item

	class apb_driver extends uvm_driver#(apb_item);

		`uvm_component_utils(apb_driver)

		virtual apb_if apb_vif;

		function new(string name = "apb_driver", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) begin
				`uvm_fatal("APB_DRV", "Cannot get virtual interface")
			end
		endfunction // build_phase

		virtual task run_phase(uvm_phase phase);
			super.run_phase(phase);
			forever begin
				apb_item m_item;
				`uvm_info("APB_DRV", $sformatf("Waiting for item"), UVM_HIGH)
				seq_item_port.get_next_item(m_item);
				drive_item(m_item);
				seq_item_port.item_done();
			end
		endtask // run_phase

		virtual task drive_item(apb_item m_item);
			@(apb_vif.requester_cb);
			apb_vif.requester_cb.paddr <= m_item.paddr;
			apb_vif.requester_cb.pwrite <= m_item.pwrite;
			apb_vif.requester_cb.psel <= 1'b1;
			apb_vif.requester_cb.penable <= 1'b0;
			apb_vif.requester_cb.pstrb <= m_item.pstrb;
			apb_vif.requester_cb.pwdata <= m_item.pwdata;
			@(apb_vif.requester_cb);
			apb_vif.requester_cb.penable <= 1'b1;
			repeat(10) @(apb_vif.requester_cb); // FIXME check pready
		endtask // drive_item

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
