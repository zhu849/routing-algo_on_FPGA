//////////////////////////
// File : four_bits_trie.v
// Author : Kuan-Ying, Zhu
// Modified Data: 2021/08/10
// Version: 1.0
// Description: Foutbit Trie pipeline structure with 10k rule
// Memory Design: X_XXXXXXXX_? => exist bit(1) + nexthop(8) + next_stage_address(variable)
//				  next_stage_address => index indicated the block with 16-entrys
//////////////////////////

module stage_ram
#(
	parameter FILE_NAME = "stage_ram.txt",
	parameter NUM_ENTRY = 0, // # of this ram's height(entry)
	parameter DATA_WIDTH = 0, // data width = exist bit(1) + nexthop(8) + next_stage_address(variable)
	parameter ADDR_LEN = 0
)
(
	output reg [DATA_WIDTH-1:0] dout,
	
	input [ADDR_LEN-1:0] addr,
	input clk
);

(* ROM_STYLE="AUTO" *) reg [DATA_WIDTH-1:0] rule_ram [NUM_ENTRY-1:0];// mem define

initial
	$readmemb(FILE_NAME, rule_ram, 0, NUM_ENTRY-1);// read data from ram file


always@(posedge clk)
begin
	dout <= rule_ram[addr];
end
endmodule