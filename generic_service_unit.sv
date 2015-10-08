`include "defines_event_unit.sv"

module generic_service_unit 
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
	
	input  logic			   [31:0] signal_i, // generic signal could be an interrupt or an event
    input  logic                      core_sleeping_i,
	output logic					  irq_o
);

    // registers
    logic [0:`REGS_MAX_IDX] [31:0]  regs_q, regs_n;
    
    // internal signals
    logic [31:0] highest_pending_int;

    // the ackowledge register is read
    logic reg_ack_read_int;
    logic serving_isr_n, serving_isr_q;

    // APB register interface
    logic [`REGS_MAX_IDX-1:0]       register_adr;
    
    assign register_adr = PADDR[`REGS_MAX_IDX + 2:2];
    // retrieve the highest pending interrupt
    //assign highest_pending_int = `get_highest_bit(regs_q[`REG_PENDING]);
    always_comb
    begin
        highest_pending_int = 'b0;
        
        for (logic[4:0] i = 31; i > 0; i--)
        begin
            if (regs_q[`REG_PENDING][i])
            begin
                highest_pending_int = i;
                break;
            end
        end 
    end
    // APB logic: we are always ready to capture the data into our regs
    // not supporting transfare failure    assign PREADY  = 1'b1;
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;

    // Cave: an empty regs_q[`REG_ACK] means that software does not serve an interrupt at the moment

    // interrupt signaling comb
    always_comb
    begin
        // as long as there are pending interrupts and core has acknowleged the last interrupt pull irq line high
        // indicating that there are still interrupts to be served
        if (regs_q[`REG_PENDING] != 'b0 || (serving_isr_q & core_sleeping_i))
            irq_o = 1'b1;
        else
            irq_o = 1'b0;
        
    end

    logic [31:00] pending_int;
    // register write logic
    always_comb
    begin
        regs_n = regs_q;
        serving_isr_n = serving_isr_q;

        //clear if acknowledge register is read
        if (reg_ack_read_int)
        begin
            regs_n[`REG_ACK] = 32'b0;
            serving_isr_n = 1'b0;
        end

        // update the pending register if new interrupts have arrived
        pending_int = ((regs_q[`REG_ENABLE] & signal_i) | regs_q[`REG_PENDING]);

        // internal register is only set if no interrupt is served at the moment and interrupts are pending
        if (~serving_isr_q && regs_q[`REG_PENDING] != 'b0)
        begin
            regs_n[`REG_ACK] = highest_pending_int;
            serving_isr_n = 1'b1;
            // clear the corresponding bit in the pending field ready to accept a new interrupt of the same priority
            pending_int[highest_pending_int] = 1'b0;
        end
        
        // written from APB bus
        if (PSEL && PENABLE && PWRITE)
        begin

            unique case (register_adr)
                `REG_ENABLE:
                    regs_n[`REG_ENABLE] = PWDATA;

                // can be written e.g. for sw interrupts or clearing all pending interrupts
                `REG_PENDING:
                    pending_int = PWDATA;
            endcase
        end

        regs_n[`REG_PENDING] = pending_int;

    end

    // register read logic
    always_comb
    begin
        PRDATA = 'b0;
        reg_ack_read_int = 1'b0;

        if (PSEL && PENABLE && !PWRITE)
        begin

            unique case (register_adr)
                `REG_ENABLE:
                    PRDATA = regs_q[`REG_ENABLE];

                `REG_PENDING:
                    PRDATA = regs_q[`REG_PENDING];

                `REG_ACK:
                begin
                    PRDATA = regs_q[`REG_ACK];
                    reg_ack_read_int = 1'b1;
                end
                default:
                    PRDATA = 'b0;
            endcase
        end
    end

    // synchronouse part
    always_ff @(posedge HCLK, negedge HRESETn)
    begin
        if(~HRESETn)
        begin
            regs_q          <= '{default: 32'b0};
            serving_isr_q   <= 1'b0;
        end
        else
        begin            
            regs_q          <= regs_n;
            serving_isr_q   <= serving_isr_n;
        end
    end
    

endmodule