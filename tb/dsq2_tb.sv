`timescale 1ns / 1ps

module tb_dsq2;

  // Clock & reset
  logic clk;
  logic resetn;

  // PCPI-like inputs
  logic [31:0] rs1;
  logic [31:0] rs2;
  logic [31:0] instr;
  logic        valid;

  // PCPI-like outputs
  logic        ready;
  logic        wait_;
  logic [31:0] rd;
  logic        wr;

  // Instantiate the DUT
  dsq2 uut (
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

  // Clock generation: 10 ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Dump VCD
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_dsq2);
  end

  // Task to apply test
  task automatic do_test(
    input logic [7:0] x1, input logic [7:0] x2,
    input logic [7:0] x3, input logic [7:0] x4,
    input logic [7:0] x1_d, input logic [7:0] x2_d,
    input logic [7:0] x3_d, input logic [7:0] x4_d,
    input int expected
  );
    begin
      rs1   = {x1, x2, x3, x4};
      rs2   = {x1_d, x2_d, x3_d, x4_d};
      instr = 32'h00000000;
      valid = 1;
      @(posedge clk); #1;

      // Handshake checks
      if (!ready) $error("[%0t] READY not asserted", $time);
      if (wait_ !== 0) $error("[%0t] WAIT_ should be 0", $time);
      if (!wr) $error("[%0t] WR not asserted", $time);

      if (rd === expected)
        $display("[%0t] PASS: inputs (%0d,%0d),(%0d,%0d),(%0d,%0d),(%0d,%0d) => rd=%0d", $time,
                 x1, x1_d, x2, x2_d, x3, x3_d, x4, x4_d, rd);
      else
        $error("[%0t] FAIL: inputs (%0d,%0d),(%0d,%0d),(%0d,%0d),(%0d,%0d) => rd=%0d (expected %0d)",
               $time, x1, x1_d, x2, x2_d, x3, x3_d, x4, x4_d, rd, expected);

      valid = 0;
      @(posedge clk); #1;
    end
  endtask

  // Run tests
  initial begin
    resetn = 0; rs1 = 0; rs2 = 0; valid = 0; instr = 0;
    repeat (2) @(posedge clk); resetn = 1; @(posedge clk);

    // Test 1: all zero diffs => result = 0
    do_test(8'd10, 8'd10, 8'd10, 8'd10, 8'd10, 8'd10, 8'd10, 8'd10, 0);

    // Test 2: mixed diffs => (20-10)^2 + (30-10)^2 + (15-15)^2 + (0-10)^2 = 100 + 400 + 0 + 100 = 600
    do_test(8'd20, 8'd30, 8'd15, 8'd0, 8'd10, 8'd10, 8'd15, 8'd10, 600);

    // Test 3: max diff => 255-0 => (255)^2 * 4 = 260100
    do_test(8'd255, 8'd255, 8'd255, 8'd255, 8'd0, 8'd0, 8'd0, 8'd0, 260100);

    // Test 4: (128-0)^2 + (64-32)^2 + (1-255)^2 + (0-127)^2 = 16384 + 1024 + 64516 + 16129 = 98053
    do_test(8'd128, 8'd64, 8'd1, 8'd0, 8'd0, 8'd32, 8'd255, 8'd127, 98053);

    // Test 5: small negative diffs => (3-5)^2 + (4-7)^2 + (10-11)^2 + (6-9)^2 = 4 + 9 + 1 + 9 = 23
    do_test(8'd3, 8'd4, 8'd10, 8'd6, 8'd5, 8'd7, 8'd11, 8'd9, 23);

    $display("All tests completed");
    #10;
    $finish;
  end

endmodule
