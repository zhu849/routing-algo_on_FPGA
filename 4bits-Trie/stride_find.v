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
	parameter FILE_NAME = "stage_ram.txt",
	parameter NUM_ENTRY = 16,
	parameter DATA_WIDTH = 16 // data width = search address len(variable) + stride(4)
)
(
	output reg [7:0] nexthop_out,
	output reg [DATA_WIDTH-10:0] next_stage_addr,
	
	input [3:0] stride, // index in one 16-entry block
	input [7:0] nexthop_in,
	input [DATA_WIDTH-10:0] search_addr, // which block in ram
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

wire [DATA_WIDTH-1:0] ram_data; // data width = exist(1) + nexthop(8) + DATA_WIDTH(variable)


stage_ram
#(
	.FILE_NAME(FILE_NAME),
	.NUM_ENTRY(NUM_ENTRY),
	.ADDR_LEN(log2(NUM_ENTRY)+4),
	.DATA_WIDTH(DATA_WIDTH)
)
sr(
	.clk(clk),
	.dout(ram_data),
	.addr({search_addr, stride})
);

always@(posedge clk)
begin
	if(rst)
	begin
		nexthop_out <= 8'b0;
		next_stage_addr <= 0;
	end
	
	next_stage_addr <= ram_data[DATA_WIDTH-10:0];
	
	// check if this nexthop exist
	if(ram_data[DATA_WIDTH-1])
	begin
		nexthop_out <= ram_data[DATA_WIDTH-2:DATA_WIDTH-9]; // assign this stage nexthop
	end
	else
	begin
		nexthop_out <= nexthop_in;
	end
end

endmodule