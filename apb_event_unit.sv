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

    // irq processing
    input  logic               [31:0] irq_i,
    input  logic               [31:0] event_i,
    output logic               [31:0] irq_o,

    // Sleep control
    output logic                      fetch_enable_o,
    output logic                      clk_gate_core_o, // output to core's clock gate to
    input  logic                      core_busy_i
);

// one hot encoding
logic [2:0] psel_int;

// output, internal wires
logic [31:0] prdata_interrupt, prdata_event, prdata_sleep;
logic pready_interrupt, pready_event, pready_sleep, pslverr_interrupt, pslverr_event, pslverr_sleep;

// event from event unit in order to wake up the core after an event has occured
logic event_int, core_sleeping_int;

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
        default:
            psel_int = 3'b0;
    endcase

end

// output mux
always_comb
begin
    unique case(psel_int)
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
       3'b100:
       begin
            PRDATA = prdata_interrupt;
            PREADY = pready_interrupt;
            PSLVERR = pslverr_interrupt;
        end
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
    .core_sleeping_i    (core_sleeping_int),
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
    .core_sleeping_i    (core_sleeping_int),
    .irq_o              () // open - this is the main difference to the interrupt unit
);


// sleep unit
sleep_unit
#(
    .APB_ADDR_WIDTH(APB_ADDR_WIDTH)  //APB slaves are 4KB by default
)
i_sleep_unit
(
    .HCLK               (HCLK),
    .HRESETn            (HRESETn),
    .PADDR              (PADDR),
    .PWDATA             (PWDATA),
    .PWRITE             (PWRITE),
    .PSEL               (psel_int[2]),
    .PENABLE            (PENABLE),
    .PRDATA             (prdata_sleep),
    .PREADY             (pready_sleep),
    .PSLVERR            (pslverr_sleep),
    
    .signal_i           (irq_o[0]), // interrupt or event signal - for sleep ctrl
    .core_busy_i        (core_busy_i), // check if core is busy
    .fetch_en_o         (fetch_enable_o),
    .clk_gate_core_o    (clk_gate_core_o), // output to core's clock gate to
    .core_sleeping_o    (core_sleeping_int) // open to interrupt unit to defer interrupt 
                                            //signal in order to give the core enough time after wakeup to catch the signal
);

endmodule
