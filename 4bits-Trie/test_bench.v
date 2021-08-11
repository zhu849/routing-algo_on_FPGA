//////////////////////////
// File : four_bits_trie.v
// Author : Kuan-Ying, Zhu
// Modified Data: 2021/08/10
// Version: 1.0
// Description: Foutbit Trie pipeline structure with 10k rule
// Memory Design: X_XXXXXXXX_? => exist bit(1) + nexthop(8) + next_stage_address(variable)
//				  next_stage_address => index indicated the block with 16-entrys
//////////////////////////

`timescale 1ns / 1ps
`define CYCLE 10

module test_bench;

reg [31:0] ip;
reg clk;
reg rst;

wire [7:0] nexthop;

reg [31:0] ip_mem [0:10260];
reg [7:0] nexthop_mem [0:10260];
integer i, err;


initial
begin
	$readmemh("./ip.txt", ip_mem);
	$readmemh("./golden_nexthop.txt", nexthop_mem);
end

four_bits_trie fbt(
	.nexthop(nexthop),
	
	.ip(ip),
	.clk(clk),
	.rst(rst)
);

always #(`CYCLE/2) clk=~clk;


initial 
begin
	ip = 0;
	clk = 0;
	rst = 1;
	err = 0;
	
	#(`CYCLE*11000);
	if(err == 0)
	begin
		$display("============================================================================");
		$display("\n \\(^0^)// CONGRATULATIONS!!  The simulation result is PASS!!!\n");
		$display("============================================================================");
	end
	$finish;
end

initial
begin
	#15 rst = 0;

	for(i=0;i<=10260;i=i+1)
	begin
		@(posedge clk)
			ip = ip_mem[i];
			if(i>9)
				if(nexthop != nexthop_mem[i-10])
				begin
					err = err + 1;
					$display( "%dst: nexthop = [%d] not expected [%d]", i-10, nexthop, nexthop_mem[i-10]); 
				end
	end

end

endmodule