//////////////////////////
// File : four_bits_trie.v
// Author : Kuan-Ying, Zhu
// Modified Data: 2021/08/10
// Version: 1.0
// Description: Foutbit Trie pipeline structure with 10k rule
//////////////////////////

`include "stage_ram.v"

module stride_find
#( 
	parameter FILE_NAME = "stageX_ram.txt",
	parameter NUM_ENTRY = 0,
	parameter READ_DATA_WIDTH = 0, // read file data width = exist(1) + nexthop(8) + next stage index(vaiable) 
	parameter RAM_DATA_WIDTH = 0
)
(
	output reg [7:0] nexthop_out,
	output reg [READ_DATA_WIDTH-9-1:0] next_stage_index,
	
	input [3:0] stride, // index in one 16-entry block
	input [7:0] nexthop_in,
	input [RAM_DATA_WIDTH-1:0] ram_index, // which one block in ram
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
	.ADDR_LEN(RAM_DATA_WIDTH+4),
	.DATA_WIDTH(READ_DATA_WIDTH)
)
sr(
	.clk(clk),
	.dout(ram_data),
	.addr({ram_index, stride})
);

always@(posedge clk)
begin
	if(rst)
	begin
		nexthop_out <= 8'b0;
		next_stage_index <= 0;
	end
	else
	begin
		next_stage_index <= ram_data[READ_DATA_WIDTH-9-1:0];

		// check if this nexthop exist, 0 mean yes, 1 mean no
		if(ram_data[READ_DATA_WIDTH-2:READ_DATA_WIDTH-9]!=0)
			nexthop_out <= ram_data[READ_DATA_WIDTH-2:READ_DATA_WIDTH-9]; // assign this stage nexthop
		else
			nexthop_out <= nexthop_in;
	end
end

endmodule