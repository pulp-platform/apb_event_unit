`include "defines.sv"

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

    // registers
    logic [0:`REGS_MAX_IDX] [31:0]  regs_q, regs_n;
    
    // internal signals
    logic [31:0] highest_pending_int, pending_int;
    // there is currently an interrupt beeing served
    logic interrupt_served_int;

    // APB register interface
    logic [`REGS_MAX_IDX-1:0]       register_adr;
    
    assign register_adr = PADDR[`REGS_MAX_IDX+2:2];
    // retrieve the highest pending interrupt
    assign highest_pending_int = log2(regs_q[`REG_IRQ_PENDING]);

    // APB logic: we are always ready to capture the data into our regs
    assign PREADY  = 1'b1;

    // Cave: an empty regs_q[`REG_IRQ_ACK] means that software does not serve an interrupt at the moment

    // interrupt signaling comb
    always_comb
    begin
        // as long as there are pending interrupts and core has acknowleged the last interrupt pull irq line high
        // indicating that there are still interrupts to be served
        if (regs_q[`REG_IRQ_ACK] == 'b0 & regs_q[`REG_IRQ_PENDING] != 'b0)
            irq_o = 1'b1;
        else
            irq_o = 1'b0;
        
    end

    // register write logic
    always_comb
    begin
        regs_n = regs_q;
        // update the pending register if new interrupts have arrived
        regs_n[`REG_IRQ_PENDING] = ((regs_q[`REG_IRQ_ENABLE] & irq_i) | regs_q[`REG_IRQ_PENDING]);

        // written from APB bus
        if (PSEL && PENABLE && PWRITE)
        begin

            unique case (register_adr)
                `REG_IRQ_ENABLE:
                    regs_n[`REG_IRQ_ENABLE] = PWDATA;

                // can be written e.g. for sw interrupts
                `REG_IRQ_PENDING:
                    regs_n[`REG_IRQ_PENDING] = PWDATA;
            endcase
        end

        // internal register is only set if no interrupt is served at the moment
        if (~regs_q[`REG_IRQ_ACK])
        begin
            regs_n[`REG_IRQ_ACK] = highest_pending_int;
            // clear the corresponding bit in the pending field ready to accept a new interrupt of the same priority
            regs_n[`REG_IRQ_PENDING] = regs_n[`REG_IRQ_PENDING] ^ highest_pending_int;
        end
    end

    // register read logic
    always_comb
    begin
        PRDATA = 'b0;

        if (PSEL && PENABLE && !PWRITE)
        begin
        
            unique case (register_adr)
                `REG_IRQ_ENABLE:
                    PRDATA = regs_q[`REG_IRQ_ENABLE];

                `REG_IRQ_PENDING:
                    PRDATA = regs_q[`REG_IRQ_PENDING];

                `REG_IRQ_ACK:
                    PRDATA = regs_q[`REG_IRQ_ACK];
            endcase
        end
    end

    // synchronouse part
    always_ff @(posedge HCLK, negedge HRESETn)
    begin
        if(~HRESETn)
        begin
            regs_q      <= '{default: 32'b0};
        end
        else            
            regs_q      <= regs_n;
        end
    

endmodule