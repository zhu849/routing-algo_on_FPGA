//////////////////////////
// File : four_bits_trie.v
// Author : Kuan-Ying, Zhu
// Modified Data: 2021/08/10
// Version: 1.0
// Description: Foutbit Trie pipeline structure 
//////////////////////////

`include "stride_find.v"

module four_bits_trie
#(  
    parameter STAGE0_ADDR_LEN = 4,
	parameter STAGE1_ADDR_LEN = 8,
	parameter STAGE2_ADDR_LEN = 12,
	parameter STAGE3_ADDR_LEN = 15,
	parameter STAGE4_ADDR_LEN = 17,
	parameter STAGE5_ADDR_LEN = 18,
	parameter STAGE6_ADDR_LEN = 19,
	parameter STAGE7_ADDR_LEN = 14
)
(
	output reg [7:0] nexthop, // search result
	
	input [31:0] ip, // search ip 
	input rst,
	input clk
);

// reg, wire, mem definition
wire [7:0] nexthop_wire [7:0]; // store every stage's nexthop (longest prefix match nexthop)
wire [STAGE0_ADDR_LEN-1:0] stage0_addr;
wire [STAGE1_ADDR_LEN-1:0] stage1_addr;
wire [STAGE2_ADDR_LEN-1:0] stage2_addr;
wire [STAGE3_ADDR_LEN-1:0] stage3_addr;
wire [STAGE4_ADDR_LEN-1:0] stage4_addr;
wire [STAGE5_ADDR_LEN-1:0] stage5_addr;
wire [STAGE6_ADDR_LEN-1:0] stage6_addr;
wire [STAGE7_ADDR_LEN-1:0] stage7_addr;

// Stage-0
stride_find
#(
	.FILE_NAME("stage0_ram.txt"),
	.NUM_ENTRY(16),
	.DATA_WIDTH(STAGE0_ADDR_LEN+9)
)
stage0(
	.nexthop_in(8'b00000000),
	.nexthop_out(nexthop_wire[0]),
	.next_stage_addr(stage0_addr),
	.stride(ip[31:28]),
	.search_addr(stage0_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-1
stride_find
#(
	.FILE_NAME("stage1_ram.txt"),
	.NUM_ENTRY(224),
	.DATA_WIDTH(STAGE1_ADDR_LEN+9)
)
stage1(
	.nexthop_in(nexthop_wire[0]),
	.nexthop_out(nexthop_wire[1]),
	.next_stage_addr(stage1_addr),
	.stride(ip[27:24]),
	.search_addr(stage1_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-2
stride_find
#(
	.FILE_NAME("stage2_ram.txt"),
	.NUM_ENTRY(2960),
	.DATA_WIDTH(STAGE2_ADDR_LEN+9)
)
stage2(
	.nexthop_in(nexthop_wire[1]),
	.nexthop_out(nexthop_wire[2]),
	.next_stage_addr(stage2_addr),
	.stride(ip[23:20]),
	.search_addr(stage2_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-3
stride_find
#(
	.FILE_NAME("stage3_ram.txt"),
	.NUM_ENTRY(29472),
	.DATA_WIDTH(STAGE3_ADDR_LEN+9)
)
stage3(
	.nexthop_in(nexthop_wire[2]),
	.nexthop_out(nexthop_wire[3]),
	.next_stage_addr(stage3_addr),
	.stride(ip[19:16]),
	.search_addr(stage3_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-4
stride_find
#(
	.FILE_NAME("stage4_ram.txt"),
	.NUM_ENTRY(121120),
	.DATA_WIDTH(STAGE4_ADDR_LEN+9)
)
stage4(
	.nexthop_in(nexthop_wire[3]),
	.nexthop_out(nexthop_wire[4]),
	.next_stage_addr(stage4_addr),
	.stride(ip[15:12]),
	.search_addr(stage4_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-5
stride_find
#(
	.FILE_NAME("stage5_ram.txt"),
	.NUM_ENTRY(200672),
	.DATA_WIDTH(STAGE5_ADDR_LEN+9)
)
stage5(
	.nexthop_in(nexthop_wire[4]),
	.nexthop_out(nexthop_wire[5]),
	.next_stage_addr(stage5_addr),
	.stride(ip[11:8]),
	.search_addr(stage5_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-6
stride_find
#(
	.FILE_NAME("stage6_ram.txt"),
	.NUM_ENTRY(276320),
	.DATA_WIDTH(STAGE6_ADDR_LEN+9)
)
stage6(
	.nexthop_in(nexthop_wire[5]),
	.nexthop_out(nexthop_wire[6]),
	.next_stage_addr(stage6_addr),
	.stride(ip[7:4]),
	.search_addr(stage6_addr),
	.rst(rst),
	.clk(clk)
);

// Stage-7
stride_find
#(
	.FILE_NAME("stage7_ram.txt"),
	.NUM_ENTRY(8304),
	.DATA_WIDTH(STAGE7_ADDR_LEN+9)
)
stage7(
	.nexthop_in(nexthop_wire[6]),
	.nexthop_out(nexthop_wire[7]),
	.next_stage_addr(stage7_addr),
	.stride(ip[3:0]),
	.search_addr(stage7_addr),
	.rst(rst),
	.clk(clk)
);

always@(posedge clk)
begin
	nexthop <= nexthop_wire[7];
end

endmodule
