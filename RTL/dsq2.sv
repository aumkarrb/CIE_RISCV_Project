module dsq2 (
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

// should check the compatibility of this with the actual pcpi module interface

    wire [7:0] x1   = rs1[31:24];
    wire [7:0] x2   = rs1[23:16];
    wire [7:0] x3   = rs1[15:8];
    wire [7:0] x4   = rs1[7:0];

    wire [7:0] x1_d   = rs2[31:24];
    wire [7:0] x2_d   = rs2[23:16];
    wire [7:0] x3_d   = rs2[15:8];
    wire [7:0] x4_d   = rs2[7:0];

 	 wire signed [8:0] diff1 = $signed({1'b0, x1}) - $signed({1'b0, x1_d});
 	 wire signed [8:0] diff2 = $signed({1'b0, x2}) - $signed({1'b0, x2_d});
 	 wire signed [8:0] diff3 = $signed({1'b0, x3}) - $signed({1'b0, x3_d});
 	 wire signed [8:0] diff4 = $signed({1'b0, x4}) - $signed({1'b0, x4_d});

    wire [17:0] sq1 = diff1 * diff1;
    wire [17:0] sq2 = diff2 * diff2;
    wire [17:0] sq3 = diff3 * diff3;
    wire [17:0] sq4 = diff4 * diff4;
    
    wire [31:0] result = sq1 + sq2 + sq3 + sq4;   //16 bits of result, excluding sign operations... signed operations need extra bit for subtraction.
                                                  //Carry can be accomodated in the remaining 16 bits present.
    assign rd    = (valid?result:0);
    assign ready = valid;
    assign wait_ = 0;
    assign wr    = valid;
  
endmodule
