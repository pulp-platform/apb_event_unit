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