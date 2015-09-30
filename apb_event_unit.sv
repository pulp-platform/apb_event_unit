`include "defines.sv"

module apb_event_unit 
#(
	parameter APB_ADDR_WIDTH = 12,  //APB slaves are 4KB by default
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