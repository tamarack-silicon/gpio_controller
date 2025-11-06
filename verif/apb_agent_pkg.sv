package apb_agent_pkg;

	`include "uvm_macros.svh"

	import uvm_pkg::*;

	class apb_item extends uvm_sequence_item;

		function new(string name = "apb_item");
			super.new(name);
		endfunction // new

		rand bit [10:0] paddr;
		rand bit		pwrite;
		rand bit [3:0]	pstrb;
		rand bit [31:0]	pwdata;

		bit [31:0]		prdata;
		bit				pslverr;

		`uvm_object_utils_begin(apb_item)
			`uvm_field_int(paddr, UVM_DEFAULT)
			`uvm_field_int(pwrite, UVM_DEFAULT)
			`uvm_field_int(pstrb, UVM_DEFAULT)
			`uvm_field_int(pwdata, UVM_DEFAULT)
			`uvm_field_int(prdata, UVM_DEFAULT)
			`uvm_field_int(pslverr, UVM_DEFAULT)
		`uvm_object_utils_end

	endclass // apb_item

	class apb_driver extends uvm_driver#(apb_item);

		`uvm_component_utils(apb_driver)

		virtual apb_if apb_vif;

		function new(string name = "apb_driver", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			if(!uvm_config_db#(virtual apb_if)::get(this, "uvm_test_top", "apb_vif", apb_vif)) begin
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
			@(apb_vif.requester_cb);
			for(integer i = 0; i < 64; i++) begin // Timeout 64 cycles
				if(apb_vif.requester_cb.pready) begin
					apb_vif.requester_cb.psel <= 1'b0;
					apb_vif.requester_cb.penable <= 1'b0;
					break;
				end else begin
					@(apb_vif.requester_cb);
				end
			end
		endtask // drive_item

	endclass // apb_driver

	class apb_monitor extends uvm_monitor;

		`uvm_component_utils(apb_monitor)

		function new(string name = "apb_monitor", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		uvm_analysis_port #(apb_item) mon_analysis_port;
		virtual apb_if apb_vif;

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			if(!uvm_config_db#(virtual apb_if)::get(this, "uvm_test_top", "apb_vif", apb_vif)) begin
				`uvm_fatal("APB_MON", "Could not get vif")
			end

			mon_analysis_port = new("mon_analysis_port", this);
		endfunction // build_phase

		virtual task run_task(uvm_phase phase);
			automatic apb_item m_item = apb_item::type_id::create("apb_item");

			super.run_phase(phase);

			forever begin

				@(apb_vif.requester_cb); // FIXME make sure DUT is out of reset
				// FIXME capture data

				m_item.print();
				mon_analysis_port.write(m_item);

			end
		endtask // run_task

	endclass

	class apb_agent extends uvm_agent;

		`uvm_component_utils(apb_agent)

		apb_driver m_driver;
		apb_monitor m_monitor;
		uvm_sequencer#(apb_item) m_sequencer;

		function new(string name = "apb_agent", uvm_component parent = null);
			super.new(name, parent);
		endfunction // new

		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			m_sequencer = uvm_sequencer#(apb_item)::type_id::create("sequencer", this);
			m_driver = apb_driver::type_id::create("driver", this);
			m_monitor = apb_monitor::type_id::create("apb_monitor", this);
		endfunction // build_phase

		virtual function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);
			m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		endfunction // connect_phase
		
	endclass // apb_agent

endpackage // apb_agent_pkg
