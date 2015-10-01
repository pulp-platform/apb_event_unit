`define log2(VALUE) ((VALUE) < ( 1 ) ? 0 : (VALUE) < ( 2 ) ? 1 : (VALUE) < ( 4 ) ? 2 : (VALUE) < ( 8 ) ? 3 : (VALUE) < ( 16 )  ? 4 : (VALUE) < ( 32 )  ? 5 : (VALUE) < ( 64 )  ? 6 : (VALUE) < ( 128 ) ? 7 : (VALUE) < ( 256 ) ? 8 : (VALUE) < ( 512 ) ? 9 : (VALUE) < ( 1024 ) ? 10 : (VALUE) < ( 2048 ) ? 11 : (VALUE) < ( 4096 ) ? 12 : (VALUE) < ( 8192 ) ? 13 : (VALUE) < ( 16384 ) ? 14 : (VALUE) < ( 32768 ) ? 15 : (VALUE) < ( 65536 ) ? 16 : (VALUE) < ( 131072 ) ? 17 : (VALUE) < ( 262144 ) ? 18 : (VALUE) < ( 524288 ) ? 19 : (VALUE) < ( 1048576 ) ? 20 : (VALUE) < ( 1048576 * 2 ) ? 21 : (VALUE) < ( 1048576 * 4 ) ? 22 : (VALUE) < ( 1048576 * 8 ) ? 23 : (VALUE) < ( 1048576 * 16 ) ? 24 : (VALUE) < ( 1048576 * 32 ) ? 25 : (VALUE) < ( 1048576 * 64 ) ? 26 : (VALUE) < ( 1048576 * 128 ) ? 27 : (VALUE) < ( 1048576 * 256 ) ? 28 : (VALUE) < ( 1048576 * 512 ) ? 29 : (VALUE) < ( 1048576 * 1024 ) ? 30 : 31)

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

`define REGS_MAX_IDX			'd8

`define REG_IRQ_ENABLE         	3'b000 //BASEADDR+0x00
`define REG_IRQ_PENDING      	3'b001 //BASEADDR+0x04
`define REG_IRQ_ACK   			3'b010 //BASEADDR+0x08
`define REG_EVENT_ENABLE 		3'b011 //BASEADDR+0x0C
`define REG_EVENT_PENDING    	3'b100 //BASEADDR+0x10
`define REG_EVENT_ACK      		3'b101 //BASEADDR+0x14
`define REG_SLEEP_CTRL        	3'b110 //BASEADDR+0x18
`define REG_SLEEP_STATUS		3'b111 //BASEADDR+0x1C