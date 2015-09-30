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
    

    // APB register interface
    
    logic [APB_ADDR_WIDTH-1:0]      apb_paddr;
    logic [31:0]                    apb_pwdata;
    logic                           apb_pwrite, apb_psel, apb_penable;

    logic [`REGS_MAX_IDX-1:0]       register_adr;
    
    assign register_adr = apb_paddr[`REGS_MAX_IDX+2:2];

    // we are always ready to capture the data into our regs
    assign PREADY  = 1'b1;
    
    // write
    always_comb
    begin
        if (apb_psel && apb_penable && apb_pwrite)
        begin
            regs_n = regs_q;
            unique case (register_adr)
                `REG_IRQ_ENABLE:
                    regs_n[`REG_IRQ_ENABLE] = apb_pwdata;

                `REG_IRQ_PENDING:
                    regs_n[`REG_IRQ_PENDING] = apb_pwdata;

                `REG_IRQ_ACK:
                    regs_n[`REG_IRQ_ACK] = apb_pwdata;

                `REG_EVENT_ENABLE:
                    regs_n[`REG_EVENT_ENABLE] = apb_pwdata;

                `REG_EVENT_PENDING:
                    regs_n[`REG_EVENT_PENDING] = apb_pwdata;

                `REG_EVENT_ACK:
                    regs_n[`REG_EVENT_ACK] = apb_pwdata;

                `REG_SLEEP_CTRL:
                    regs_n[`REG_SLEEP_CTRL] = apb_pwdata;

                `REG_SLEEP_STATUS:
                    regs_n[`REG_SLEEP_STATUS] = apb_pwdata;
            endcase
        end
    end

    // read
    always_comb
    begin
        if (apb_psel && apb_penable && !apb_pwrite)
        begin
            unique case (register_adr)
                `REG_IRQ_ENABLE:
                    PRDATA = regs_q[`REG_IRQ_ENABLE];

                `REG_IRQ_PENDING:
                    PRDATA = regs_q[`REG_IRQ_PENDING];

                `REG_IRQ_ACK:
                    PRDATA = regs_q[`REG_IRQ_ACK];

                `REG_EVENT_ENABLE:
                    PRDATA = regs_q[`REG_EVENT_ENABLE];

                `REG_EVENT_PENDING:
                    PRDATA = regs_q[`REG_EVENT_PENDING];

                `REG_EVENT_ACK:
                    PRDATA = regs_q[`REG_EVENT_ACK];

                `REG_SLEEP_CTRL:
                    PRDATA = regs_q[`REG_SLEEP_CTRL];

                `REG_SLEEP_STATUS:
                    PRDATA = regs_q[`REG_SLEEP_STATUS];
            endcase
        end
    end

    // synchronouse part
    always_ff @(posedge HCLK, negedge HRESETn)
    begin
        if(~HRESETn)
        begin
            apb_paddr   <= 'b0;
            apb_pwdata  <= 32'b0;
            apb_pwrite  <= 'b0;
            apb_psel    <= 'b0;
            apb_penable <= 'b0;

            regs_q      <= 'b0;
        end
        else
            apb_paddr   <= PADDR;
            apb_pwdata  <= PWDATA;
            apb_pwrite  <= PWRITE;
            apb_psel    <= PSEL;
            apb_penable <= PENABLE;
            
            regs_q      <= regs_n;
        end
    

endmodule