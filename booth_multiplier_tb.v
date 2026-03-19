`timescale 1ns/1ps

module booth_multiplier_tb;

reg clk;
reg start;
reg signed [15:0] data_in;

wire done;
wire signed [31:0] product;


// DUT
booth_multiplier uut (
    .clk(clk),
    .start(start),
    .data_in(data_in),
    .done(done),
    .product(product)
);


// Clock generation
always #5 clk = ~clk;



// Task to run one test
task run_test;

input signed [15:0] multiplicand;
input signed [15:0] multiplier;

reg signed [31:0] expected;

begin

    expected = multiplicand * multiplier;

    // Load multiplicand
    @(posedge clk);
    start = 1;
    data_in = multiplicand;

    @(posedge clk);
    start = 0;

    // Load multiplier
    @(posedge clk);
    data_in = multiplier;

    // Wait for completion
    wait(done);

    // Compare results
    if(product === expected)
        $display("PASS: %0d x %0d = %0d", multiplicand, multiplier, product);
    else
        $display("FAIL: %0d x %0d -> DUT=%0d Expected=%0d",
                 multiplicand, multiplier, product, expected);

    #20;

end

endtask



integer i;
reg signed [15:0] a,b;

initial begin

    clk = 0;
    start = 0;
    data_in = 0;

    #20;

    // ===== Zero Cases =====
    run_test(0,0);
    run_test(0,123);
    run_test(123,0);
    run_test(-456,0);
    run_test(0,-789);

    // ===== ±1 Cases =====
    run_test(1,999);
    run_test(-1,999);
    run_test(999,1);
    run_test(999,-1);
    run_test(-1,-1);

    // ===== Boundary (16-bit stress) =====
    run_test(32767,1);
    run_test(32767,2);
    run_test(32767,32767);

    // ===== Power-of-2 / Shift Sensitive =====
    run_test(1,128);
    run_test(8,16);
    run_test(128,-1);
    run_test(-64,4);

    // ===== Bit Pattern Stress =====
    run_test(85,170);
    run_test(-85,170);
    run_test(85,-170);
    run_test(-85,-170);

    // ===== Dense / Sparse Bits =====
    run_test(255,3);
    run_test(127,127);
    run_test(-127,127);
    run_test(255,-255);

    // ===== Near-Zero Edge Transitions =====
    run_test(1,-1);
    run_test(-1,1);
    run_test(2,-1);
    run_test(-2,1);
    run_test(1,-2);

    // ===== Random Stress =====
    run_test(1234,5678);
    run_test(-2345,678);
    run_test(4095,-1023);
    run_test(-3000,-2000);


    // ===== Boundary (16-bit stress) =====
    run_test(-32768,1);
    run_test(-32768,-1);
    run_test(-32768,-32768);   
    //These are wrong because signed and unsigned manipulation in testbench (insufficient length syndrome)

    #50;
    $finish;

end

endmodule