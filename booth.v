`timescale 1ns/1ps

module booth_multiplier(
    input clk,start,
    input [15:0]data_in,
    output done,
    output[31:0]product
);

wire ldA,clrA,sftA,ldQ,clrQ,sftQ;
wire ldM,clrff,decr,ldcnt;
wire eqz,qm1,q0;
wire [1:0]addsub,q0qm;
wire [31:0]product_internal;

controller ctrl(
.q0(q0), .qm1(qm1), .start(start), .clk(clk), .eqz(eqz),
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
.product_internal(product_internal)
);

assign product=product_internal;

endmodule