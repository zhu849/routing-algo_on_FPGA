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
	// every stage's nodes need how many address to express
    parameter STAGE1_INDEX_LEN = 4,
	parameter STAGE2_INDEX_LEN = 8,
	parameter STAGE3_INDEX_LEN = 12,
	parameter STAGE4_INDEX_LEN = 15,
	parameter STAGE5_INDEX_LEN = 17,
	parameter STAGE6_INDEX_LEN = 18,
	parameter STAGE7_INDEX_LEN = 19,
	parameter STAGE8_INDEX_LEN = 14,
	
	// record how many node in those stage
	parameter STAGE0_ENTRY = 16,
	parameter STAGE1_ENTRY = 224,
	parameter STAGE2_ENTRY = 2960,
	parameter STAGE3_ENTRY = 29472,
	parameter STAGE4_ENTRY = 121120,
	parameter STAGE5_ENTRY = 200672,
	parameter STAGE6_ENTRY = 276320,
	parameter STAGE7_ENTRY = 8304
)
(
	output reg [7:0] nexthop, // search result
	
	input [31:0] ip, // search ip 
	input rst,
	input clk
);

// reg, wire, mem definition
wire [7:0] nexthop_wire [7:0]; // store every stage's nexthop (longest prefix match nexthop)
wire [STAGE1_INDEX_LEN-1:0] stage1_index; // this is stage 1's ram index
wire [STAGE2_INDEX_LEN-1:0] stage2_index; 
wire [STAGE3_INDEX_LEN-1:0] stage3_index; 
wire [STAGE4_INDEX_LEN-1:0] stage4_index; 
wire [STAGE5_INDEX_LEN-1:0] stage5_index; 
wire [STAGE6_INDEX_LEN-1:0] stage6_index; 
wire [STAGE7_INDEX_LEN-1:0] stage7_index; 
wire [STAGE8_INDEX_LEN-1:0] stage8_index; 

// Stage-0
root_find
#(
	.FILE_NAME("stage0_ram.txt"),
	.NUM_ENTRY(STAGE0_ENTRY),
	.READ_DATA_WIDTH(STAGE1_INDEX_LEN+9)
)
stage0(
	.nexthop_out(nexthop_wire[0]),
	.stride(ip[31:28]),
	.next_stage_index(stage1_index),
	.rst(rst),
	.clk(clk)
);

// Stage-1
stride_find
#(
	.FILE_NAME("stage1_ram.txt"),
	.NUM_ENTRY(STAGE1_ENTRY),
	.READ_DATA_WIDTH(STAGE2_INDEX_LEN+9),
	.RAM_DATA_WIDTH(STAGE1_INDEX_LEN)
)
stage1(
	.nexthop_in(nexthop_wire[0]),
	.nexthop_out(nexthop_wire[1]),
	.next_stage_index(stage2_index),
	.ram_index(stage1_index),
	.stride(ip[27:24]),
	.rst(rst),
	.clk(clk)
);

// Stage-2
stride_find
#(
	.FILE_NAME("stage2_ram.txt"),
	.NUM_ENTRY(STAGE2_ENTRY),
	.READ_DATA_WIDTH(STAGE3_INDEX_LEN+9),
	.RAM_DATA_WIDTH(STAGE2_INDEX_LEN)
)
stage2(
	.nexthop_in(nexthop_wire[1]),
	.nexthop_out(nexthop_wire[2]),
	.next_stage_index(stage3_index),
	.ram_index(stage2_index),
	.stride(ip[23:20]),
	.rst(rst),
	.clk(clk)
);

// Stage-3
stride_find
#(
	.FILE_NAME("stage3_ram.txt"),
	.NUM_ENTRY(STAGE3_ENTRY),
	.READ_DATA_WIDTH(STAGE4_INDEX_LEN+9),
	.RAM_DATA_WIDTH(STAGE3_INDEX_LEN)
)
stage3(
	.nexthop_in(nexthop_wire[2]),
	.nexthop_out(nexthop_wire[3]),
	.next_stage_index(stage4_index),
	.ram_index(stage3_index),
	.stride(ip[19:16]),
	.rst(rst),
	.clk(clk)
);

// Stage-4
stride_find
#(
	.FILE_NAME("stage4_ram.txt"),
	.NUM_ENTRY(STAGE4_ENTRY),
	.READ_DATA_WIDTH(STAGE5_INDEX_LEN+9),
	.RAM_DATA_WIDTH(STAGE4_INDEX_LEN)
)
stage4(
	.nexthop_in(nexthop_wire[3]),
	.nexthop_out(nexthop_wire[4]),
	.next_stage_index(stage5_index),
	.ram_index(stage4_index),
	.stride(ip[15:12]),
	.rst(rst),
	.clk(clk)
);

// Stage-5
stride_find
#(
	.FILE_NAME("stage5_ram.txt"),
	.NUM_ENTRY(STAGE5_ENTRY),
	.READ_DATA_WIDTH(STAGE6_INDEX_LEN+9),
	.RAM_DATA_WIDTH(STAGE5_INDEX_LEN)
)
stage5(
	.nexthop_in(nexthop_wire[4]),
	.nexthop_out(nexthop_wire[5]),
	.next_stage_index(stage6_index),
	.ram_index(stage5_index),
	.stride(ip[11:8]),
	.rst(rst),
	.clk(clk)
);

// Stage-6
stride_find
#(
	.FILE_NAME("stage6_ram.txt"),
	.NUM_ENTRY(STAGE6_ENTRY),
	.READ_DATA_WIDTH(STAGE7_INDEX_LEN+9),
	.RAM_DATA_WIDTH(STAGE6_INDEX_LEN)
)
stage6(
	.nexthop_in(nexthop_wire[5]),
	.nexthop_out(nexthop_wire[6]),
	.next_stage_index(stage7_index),
	.ram_index(stage6_index),
	.stride(ip[7:4]),
	.rst(rst),
	.clk(clk)
);

// Stage-7
leaf_find
#(
	.FILE_NAME("stage7_ram.txt"),
	.NUM_ENTRY(STAGE7_ENTRY),
	.RAM_DATA_WIDTH(STAGE7_INDEX_LEN)
)
stage7(
	.nexthop_in(nexthop_wire[6]),
	.nexthop_out(nexthop_wire[7]),
	.ram_index(stage7_index),
	.stride(ip[3:0]),
	.rst(rst),
	.clk(clk)
);

reg [10:0] count = 0;

always@(posedge clk)
begin
	if(!rst)
	begin
		nexthop <= nexthop_wire[7];
		$display("count:%d\n----------------\n",count);
		$display("nexthop 0 :%d\n",nexthop_wire[0]);
		$display("nexthop 1 :%d\n",nexthop_wire[1]);
		$display("nexthop 2 :%d\n",nexthop_wire[2]);
		$display("nexthop 3 :%d\n",nexthop_wire[3]);
		$display("nexthop 4 :%d\n",nexthop_wire[4]);
		$display("nexthop 5 :%d\n",nexthop_wire[5]);
		$display("nexthop 6 :%d\n",nexthop_wire[6]);
		$display("nexthop 7 :%d\n",nexthop_wire[7]);
		$display("-------------------------------\n");
		count <= count + 1;
	end
	else
		count <= 0;
end

endmodule
