module gpio_ctrl_top_tb;

    logic        clk;
    logic        rst_n;

    logic [9:0] paddr;
    logic        pwrite;
    logic        psel;
    logic        penable;
    logic [3:0]  pstrb;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;
    logic		 pslverr;

	logic		 interrupt;

    logic [255:0] gpio_in_data;
    logic [255:0] gpio_out_data;
	logic [255:0] gpio_out_enable;

    gpio_ctrl_top #(
		.NUM_BANKS(8)
	) u_dut (.*);

    clocking apb_clk @(posedge clk);

        output paddr;
        output pwrite;
        output psel;
        output penable;
        output pstrb;
        output pwdata;

        input  prdata;
        input  pready;
        input  pslverr;

    endclocking // apb_clk

    initial begin
        rst_n = 1'b0;

        paddr = 10'h0;
        pwrite = 1'b0;
        psel = 1'b0;
        penable = 1'b0;
        pstrb = 4'b1111;
        pwdata = 32'h0;

        gpio_in_data = 256'h90abcdef00000000;

        #100;
        rst_n = 1'b1;
        #200;

		// Test GPIO output

        @apb_clk;
        apb_clk.paddr <= 10'h4;
        apb_clk.pwrite <= 1'b1;
        apb_clk.psel <= 1'b1;
        apb_clk.pwdata <= 32'h12345678;
        @apb_clk;
        apb_clk.penable <= 1'b1;
        @apb_clk;
        apb_clk.psel <= 1'b0;
        apb_clk.penable <= 1'b0;
        @apb_clk;

        #100;

		// Test GPIO input

        @apb_clk;
        apb_clk.paddr <= 10'h18;
        apb_clk.pwrite <= 1'b0;
        apb_clk.psel <= 1'b1;
        @apb_clk;
        apb_clk.penable <= 1'b1;
        @apb_clk;
        apb_clk.psel <= 1'b0;
        apb_clk.penable <= 1'b0;
        @apb_clk;

		#100;

		// Since all interrupts are default disabled, no interrupt shall be triggered on input change

		gpio_in_data = gpio_out_enable | 256'h1_00000000_00000000;

		#100;

		// Enable Rising edge interrupt on 3rd GPIO bank

        @apb_clk;
        apb_clk.paddr <= 10'h2C;
        apb_clk.pwrite <= 1'b1;
        apb_clk.psel <= 1'b1;
        apb_clk.pwdata <= 32'hffffffff;
        @apb_clk;
        apb_clk.penable <= 1'b1;
        @apb_clk;
        apb_clk.psel <= 1'b0;
        apb_clk.penable <= 1'b0;
        @apb_clk;

		#100;

		// Rising edge on a pin

		gpio_in_data = gpio_out_enable | 256'h3_00000000_00000000;

		#100;

		// Read interrupt status register

        @apb_clk;
        apb_clk.paddr <= 10'h200;
        apb_clk.pwrite <= 1'b0;
        apb_clk.psel <= 1'b1;
        @apb_clk;
        apb_clk.penable <= 1'b1;
        @apb_clk;
        apb_clk.psel <= 1'b0;
        apb_clk.penable <= 1'b0;
        @apb_clk;

		#100;

		// Clear interrupt

        @apb_clk;
        apb_clk.paddr <= 10'h200;
        apb_clk.pwrite <= 1'b1;
        apb_clk.psel <= 1'b1;
        apb_clk.pwdata <= 32'h00000004;
        @apb_clk;
        apb_clk.penable <= 1'b1;
        @apb_clk;
        apb_clk.psel <= 1'b0;
        apb_clk.penable <= 1'b0;
        @apb_clk;

        #200;

        $finish;
    end

    initial begin
        clk = 1'b0;
        forever begin
            #10;
            clk = ~clk;
        end
    end

    initial begin
        $dumpfile("gpio_ctrl_top_tb.vcd");
        $dumpvars;
    end

endmodule // gpio_ctrl_top_tb
