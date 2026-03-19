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
wire push_q;
assign eqz=(count==0);
assign q0=Q[0];
wire q0_internal=Q[0];
assign product_internal={A,Q};
assign push_q=(addsub[1])?A[0]:Z[0];


alu unit(.addsub(addsub),.A(A),.M(M),.Z(Z));
pipo M_reg(.ldM(ldM),.in(data_in),.out(M),.clk(clk));
shiftreg A_reg(.sft(sftA),.clr(clrA),.ld(ldA),.in(Z),.out(A),
.clk(clk),.push(Z[15]));
shiftreg Q_reg(.sft(sftQ),.clr(clrQ),.ld(ldQ),.in(data_in),.push(push_q),
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
        if (ldcnt)count<=5'd15;
        else if(decr)count<=count-1;
    end

endmodule


module alu(
    input [1:0]addsub,
    input [15:0]A,M,
    output reg [15:0]Z
);
always @(*) begin
    case (addsub)
        0: Z = A + {{16{M[15]}}, M};
        1: Z = A - {{16{M[15]}}, M};
        default: Z = A;
    endcase
end
endmodule


module shiftreg(
    input sft,clr,ld,clk,
    input [15:0]in,
    input push,
    output reg [15:0]out
);

always@(posedge clk)begin
    if(clr) out<=16'd0;
    else if(ld) begin
        if(~sft)out<=in;
        else out<={push,in[15:1]};
    end
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