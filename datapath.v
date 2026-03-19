`timescale 1ns/1ps

module datapath(
    input ldA,clrA,sftA,ldQ,clrQ,sftQ,ldM,clrff,clk,ldcnt,decr,
    input [1:0]addsub,
    input[15:0]data_in,
    output eqz,qm1,q0,
    output[31:0]product_internal
);
wire [31:0]shiftedaqqm;
wire [15:0]A,M,Q,Z;
wire [4:0]count;
assign eqz=(count==0);
assign q0=Q[0];
wire q0_internal=Q[0];
assign product_internal={A,Q};


alu unit(.addsub(addsub),.A(A),.M(M),.Z(Z),.clk(clk));
pipo M_reg(.ldM(ldM),.in(data_in),.out(M),.clk(clk));
shiftreg A_reg(.sft(sftA),.clr(clrA),.ld(ldA),.in(Z),.out(A),
.clk(clk),.push(A[15]));
shiftreg Q_reg(.sft(sftQ),.clr(clrQ),.ld(ldQ),.in(data_in),.push(A[0]),
.out(Q),.clk(clk));
dff qmin(.clrff(clrff),.qm1(qm1),.q0(q0_internal),.clk(clk),.sft(sftQ));
counter cn(.count(count),.decr(decr),.ldcnt(ldcnt),.clk(clk));

assign shiftedaqqm={A,Q};

endmodule


module dff(
    input clrff,q0,clk,sft,
    output reg qm1
);
always@(posedge clk)begin
    if(clrff)qm1<=0;
    else if(sft) qm1<=q0;
end

endmodule


module counter(
    input decr,ldcnt,clk,
    output reg [4:0]count
);
    always@(posedge clk)begin
        if (ldcnt)count<=5'd16;
        else if(decr)count<=count-1;
    end

endmodule


module alu(
    input [1:0]addsub,
    input clk,
    input [15:0]A,M,
    output [15:0]Z
);
    assign Z=(!addsub)?(A - {{1{M[15]}}, M}):(A + {{1{M[15]}}, M});

endmodule


module shiftreg(
    input sft,clr,ld,clk,
    input [15:0]in,
    input push,
    output reg [15:0]out
);

always@(posedge clk)begin
    if(clr) out<=16'd0;
    else if(ld) out<=in;
    else if(sft)out<={push,out[15:1]};
end

endmodule


module pipo(
    input clk,ldM,
    input [15:0]in,
    output reg [15:0] out
);

always@(posedge clk)begin
    if(ldM) out<=in;
end

endmodule