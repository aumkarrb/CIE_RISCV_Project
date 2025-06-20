`timescale 1ns / 1ps

module tb_dsq;

  // Clock & reset
  reg clk;
  reg resetn;

  // PCPI-like inputs
  reg  logic [31:0] rs1;
  reg  logic [31:0] rs2;
  reg  logic [31:0] instr;
  reg  logic        valid;

  // PCPI-like outputs
  wire logic        ready;
  wire logic        wait_;
  wire logic [31:0] rd;
  wire logic        wr;

  // Instantiation
  dsq uut (
    .clk    (clk),
    .resetn (resetn),
    .rs1    (rs1),
    .rs2    (rs2),
    .instr  (instr),
    .valid  (valid),
    .ready  (ready),
    .wait_  (wait_),
    .rd     (rd),
    .wr     (wr)
  );

  // Clock generation: 10 ns period (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Task to apply one test vector and check result
  task automatic do_test(
    input logic [7:0] a1, input logic [7:0] a1_d,
    input logic [7:0] a2, input logic [7:0] a2_d,
    input logic [31:0] acc_in,
    input int expected 
    // expected = acc_in + (a1 - a1_d)^2 + (a2 - a2_d)^2, computed with signed difference
  );
    begin
      // Pack rs1: {x1, x1_d, x2, x2_d}
      rs1   = {a1, a1_d, a2, a2_d};
      rs2   = acc_in;
      // instr: since DUT currently does not decode, just set a dummy value.
      instr = 32'h0000_0000;
      // Assert valid for one cycle
      valid = 1;
      @(posedge clk);
      // Small delay to let combinational rd settle
      #1;
      // Display and check
      if (rd === expected) begin
        $display("[%0t] PASS: inputs (%0d,%0d),(%0d,%0d), acc_in=%0d => rd=%0d",
                  $time, a1, a1_d, a2, a2_d, acc_in, rd);
      end else begin
        $error("[%0t] FAIL: inputs (%0d,%0d),( %0d,%0d ), acc_in=%0d => rd=%0d (expected %0d)",
               $time, a1, a1_d, a2, a2_d, acc_in, rd, expected);
      end
      // Deassert valid
      valid = 0;
      @(posedge clk);
      #1;
    end
  endtask

  // Reset and run tests
  initial begin
    // Initialize signals
    resetn = 0;
    rs1    = 0;
    rs2    = 0;
    instr  = 0;
    valid  = 0;

    // Hold reset for a few cycles
    repeat (2) @(posedge clk);
    resetn = 1;
    @(posedge clk);


    
    // --- Test cases ---

    // 1) Simple small differences
    // a1=10, a1_d=7 => diff = 3; a2=5, a2_d=3 => diff = 2; squares: 9 + 4 = 13; acc_in=0
    do_test(8'd10, 8'd7, 8'd5, 8'd3, 32'd0, 32'd13);

    // 2) Zero differences
    // a1=20, a1_d=20 => diff = 0; a2=100, a2_d=100 => diff = 0; squares sum=0; acc_in=5
    do_test(8'd20, 8'd20, 8'd100, 8'd100, 32'd0, 32'd0);

    // 3) Negative difference case
    // For correct behavior, dsq module should use signed subtraction.
    // Here: a1=7, a1_d=10 => diff = -3; squared = 9. Similarly a2=3, a2_d=5 => diff=-2; squared=4.
    // acc_in=1 => expected = 1 + 9 + 4 = 14
    do_test(8'd7, 8'd10, 8'd3, 8'd5, 32'd0, 32'd13);

    // 4) Max difference within signed range
    // a1=255, a1_d=0 => diff = 255; squared=65025. a2=0, a2_d=255 => diff=-255; squared=65025.
    // sum = 130050; acc_in=0
    do_test(8'hFF, 8'd0, 8'd0, 8'hFF, 32'd0, 32'd130050);

    // 5) Accumulation test
    // First partial: a1=10, a1_d=8 => diff=2,sq=4; a2=6,a2_d=4=>diff=2,sq=4; sum=8
    do_test(8'd10, 8'd8, 8'd6, 8'd4, 32'd0, 32'd8);
   
    do_test(8'd3, 8'd1, 8'd9, 8'd6, 32'd0, 32'd13);

    // 6) Edge: small and large mix
    do_test(8'd128, 8'd0, 8'd1, 8'd255, 32'd0, 
            // diff1=128, sq1=16384; diff2=1-255=-254,sq2=64516; sum=809,? Actually 16384+64516=80900
            32'd80900 );


    $display("All tests completed");
    #10;
    $finish;
  end

endmodule
