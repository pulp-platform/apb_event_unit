`include "defines_event_unit.sv"

module apb_event_unit 
#(
	parameter APB_ADDR_WIDTH = 12  //APB slaves are 4KB by default
)
(
    input  logic                      HCLK,
    input  logic                      HRESETn,
    input  logic [APB_ADDR_WIDTH-1:0] PADDR,
    input  logic               [31:0] PWDATA,
    input  logic                      PWRITE,
    input  logic                      PSEL,
    input  logic                      PENABLE,
    output logic               [31:0] PRDATA,
    output logic                      PREADY,
    output logic                      PSLVERR,
	
	input  logic			   [31:0] irq_i,
	input  logic			   [31:0] event_i,
	output logic					  fetch_enable_o,
	output logic					  irq_o
);

// one hot encoding
logic [2:0] psel_int;

// output, internal wires 
logic [31:0] prdata_interrupt, prdata_event, prdata_sleep;
logic pready_interrupt, pready_event, pready_sleep, pslverr_interrupt, pslverr_event, pslverr_sleep;

// address selector - select right peripheral
always_comb
begin
    psel_int = 3'b0;

    unique case(PADDR[`ADR_MAX_IDX + 2:`REGS_MAX_IDX + 2])
        `IRQ:
            psel_int[0] = PSEL;
        `EVENT:
            psel_int[1] = PSEL;
        `SLEEP:
            psel_int[2] = PSEL;
    endcase

end

// output mux
always_comb
begin
    case(psel_int)
        3'b001:
        begin
            PRDATA = prdata_interrupt;
            PREADY = pready_interrupt;
            PSLVERR = pslverr_interrupt;
        end
        3'b010:
        begin
            PRDATA = prdata_event;
            PREADY = pready_event;
            PSLVERR = pslverr_interrupt;
        end        
//       3'b100:
//       begin
//            PRDATA = prdata_interrupt;
//            PREADY = pready_interrupt;
//            PSLVERR = pslverr_interrupt;
//        end
        default:
        begin
            PRDATA = 'b0;
            PREADY = 1'b0;
            PSLVERR = 1'b0;
        end
    endcase
end

// interrupt unit

generic_service_unit 
#(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH)  //APB slaves are 4KB by default
)
i_interrupt_unit
(
    .HCLK               (HCLK),
    .HRESETn            (HRESETn),
    .PADDR              (PADDR),
    .PWDATA             (PWDATA),
    .PWRITE             (PWRITE),
    .PSEL               (psel_int[0]),
    .PENABLE            (PENABLE),
    .PRDATA             (prdata_interrupt),
    .PREADY             (pready_interrupt),
    .PSLVERR            (pslverr_interrupt),
    
    .signal_i           (irq_i), // generic signal could be an interrupt or an event
    .irq_o              (irq_o)
);


// event unit

generic_service_unit 
#(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH)  //APB slaves are 4KB by default
)
i_event_unit
(
    .HCLK               (HCLK),
    .HRESETn            (HRESETn),
    .PADDR              (PADDR),
    .PWDATA             (PWDATA),
    .PWRITE             (PWRITE),
    .PSEL               (psel_int[1]),
    .PENABLE            (PENABLE),
    .PRDATA             (prdata_event),
    .PREADY             (pready_event),
    .PSLVERR            (pslverr_event),
    
    .signal_i           (event_i), // generic signal could be an interrupt or an event
    .irq_o              ( ) // open - this is the main difference to the interrupt unit
);


// sleep unit


endmodule