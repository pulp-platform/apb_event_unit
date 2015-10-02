`define get_highest_bit(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : (VALUE) < ( 1048576 * 32 ) ? 25 : (VALUE) < ( 1048576 * 64 ) ? 26 : (VALUE) < ( 1048576 * 128 ) ? 27 : (VALUE) < ( 1048576 * 256 ) ? 28 : (VALUE) < ( 1048576 * 512 ) ? 29 : (VALUE) < ( 1048576 * 1024 ) ? 30 : (VALUE) < ( 1048576 * 2048 ) ? 31 : 32)

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
