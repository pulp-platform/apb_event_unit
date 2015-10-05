///////////////////////////////////////////////
//  _____            _     _                 //
// |  __ \          (_)   | |                //
// | |__) |___  __ _ _ ___| |_ ___ _ __ ___  //
// |  _  // _ \/ _` | / __| __/ _ \ '__/ __| //
// | | \ \  __/ (_| | \__ \ ||  __/ |  \__ \ //
// |_|  \_\___|\__, |_|___/\__\___|_|  |___/ //
//              __/ |                        //
//             |___/                         //
///////////////////////////////////////////////

// total number of address space reserved for the apb_event_unit
`define ADR_MAX_IDX				'd4

`define IRQ						2'b00
`define EVENT					2'b01
`define SLEEP					2'b10

// number of registers per (interrupt, event) service unit - 6 regs in total
`define REGS_MAX_IDX			'd2

`define REG_ENABLE 				2'b00
`define REG_PENDING      		2'b01
`define REG_ACK   				2'b10

`define REG_SLEEP_CTRL        	2'b00
`define REG_SLEEP_STATUS		2'b01
