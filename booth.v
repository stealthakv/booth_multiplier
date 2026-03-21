`timescale 1ns/1ps

module booth_multiplier(
    input clk,start,
    input [15:0]data_in,
    output done,
    output[31:0]product
);

wire ldA,clrA,sftA,ldQ,clrQ,sftQ;
wire ldM,clrff,decr,ldcnt;
wire eqz,qm1,q0,q1;
wire [2:0]addsub,q0qm;
wire [31:0]product_internal;

controller ctrl(
.q0(q0), .qm1(qm1), .q1(q1), .start(start), .clk(clk), .eqz(eqz),
.ldA(ldA), .clrA(clrA), .sftA(sftA),
.ldQ(ldQ), .clrQ(clrQ), .sftQ(sftQ),
.addsub(addsub), .ldM(ldM), .clrff(clrff),
.decr(decr), .ldcnt(ldcnt), .done(done)
);

datapath dp(
.ldA(ldA), .clrA(clrA), .sftA(sftA),
.ldQ(ldQ), .clrQ(clrQ), .sftQ(sftQ),
.ldM(ldM), .clrff(clrff),
.addsub(addsub),
.clk(clk),
.ldcnt(ldcnt),
.decr(decr),
.data_in(data_in),
.eqz(eqz),
.qm1(qm1),
.q0(q0),
.q1(q1),
.product_internal(product_internal)
);

assign product=product_internal;
assign q0qm={q1,q0,qm1};

endmodule

// Radix-4 Booth Encoding
// 000 ->  0; addsub=2;
// 001 -> +m; addsub=0;
// 010 -> +m; addsub=0;
// 011 -> +2m; addsub=1;
// 100 -> -2m; addsub=3;
// 101 -> -m; addsub=4;
// 110 -> -m; addsub=4;
// 111 ->  0; addsub=2;