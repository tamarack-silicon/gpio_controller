interface apb_if (
	input logic clk
);

    logic [11:0] paddr;
    logic        pwrite;
    logic        psel;
    logic        penable;
    logic [3:0]  pstrb;
    logic [31:0] pwdata;
    logic [31:0] prdata;
    logic        pready;
    logic		 pslverr;

	modport requester (
		input prdata, pready, pslverr,
		output paddr, pwrite, psel, penable, pstrb, pwdata
	);

	modport completer (
		input paddr, pwrite, psel, penable, pstrb, pwdata,
		output prdata, pready, pslverr
	);

endinterface // apb_if
