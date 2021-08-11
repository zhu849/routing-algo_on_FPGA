//////////////////////////
// File : four_bits_trie.v
// Author : Kuan-Ying, Zhu
// Modified Data: 2021/08/10
// Version: 1.0
// Description: Foutbit Trie pipeline structure with 10k rule
//////////////////////////

`include "stage_ram.v"

module root_find
#(
	parameter FILE_NAME = "stage1_ram.txt",
	parameter NUM_ENTRY = 16,
	parameter READ_DATA_WIDTH = 13
)
(
	output reg [7:0] nexthop_out,
	output reg [READ_DATA_WIDTH-9-1:0] next_stage_index,
	
	input [3:0] stride,
	input rst,
	input clk
);

function integer log2;
    input integer number;
    begin
        log2=0;
        while(2**log2 < number)
            log2=log2+1;
    end
endfunction // log2

wire [READ_DATA_WIDTH-1:0] ram_data; // data width = exist(1) + nexthop(8) + DATA_WIDTH(variable)

stage_ram
#(
	.FILE_NAME(FILE_NAME),
	.NUM_ENTRY(NUM_ENTRY),
	.ADDR_LEN(log2(NUM_ENTRY)),
	.DATA_WIDTH(READ_DATA_WIDTH)
)
sr(
	.clk(clk),
	.dout(ram_data),
	.addr(stride)
);

always@(posedge clk)
begin
	nexthop_out <= 8'b0;
	next_stage_index <= ram_data[READ_DATA_WIDTH-9-1:0];
end


endmodule