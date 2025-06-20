// Code your design here
module dsq (
    input         clk,
    input         resetn,
    input  [31:0] rs1,      
    input  [31:0] rs2,      
    input  [31:0] instr,    
    input         valid,    
    output        ready,    
    output        wait_,    
    output [31:0] rd,       
    output        wr       
);

    wire [7:0] x1   = rs1[31:24];
    wire [7:0] x1_d = rs1[23:16];
    wire [7:0] x2   = rs1[15:8];
    wire [7:0] x2_d = rs1[7:0];
    wire signed [8:0] diff1 = $signed({1'b0, x1}) - $signed({1'b0, x1_d});
    wire signed [8:0] diff2 = $signed({1'b0, x2}) - $signed({1'b0, x2_d});

    wire [17:0] sq1 = diff1 * diff1;
    wire [17:0] sq2 = diff2 * diff2;

    wire [31:0] result = rs2 + sq1 + sq2;   //rs2 holds previous value

    assign rd    = valid ? result : 0;
    assign ready = valid;
    assign wait_ = 0;
    assign wr    = valid;

endmodule
