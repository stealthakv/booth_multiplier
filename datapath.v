`timescale 1ns/1ps

module datapath(
    input ldA,clrA,sftA,ldQ,clrQ,sftQ,ldM,clrff,clk,ldcnt,decr,
    input [2:0]addsub,
    input[15:0]data_in,
    output eqz,
    output q0,q1,qm1,
    output[31:0]product_internal
);
wire [17:0]A,Z;
wire [15:0]Q,M;
wire [4:0]count;
wire q1_internal=q1;
assign product_internal={A[15:0],Q};
assign push_q=(addsub==2)?A[1:0]:Z[1:0];
assign q0=Q[0];
assign q1=Q[1];
assign eqz=(count==0);


alu unit(.addsub(addsub),.A(A),.M(M),.Z(Z));
pipo M_reg(.ldM(ldM),.in(data_in),.out(M),.clk(clk));
shiftreg_A A_reg(.sft(sftA),.clr(clrA),.ld(ldA),.in(Z),.out(A),
.clk(clk),.push(Z[17:16]));
shiftreg_Q Q_reg(.sft(sftQ),.clr(clrQ),.ld(ldQ),.in(data_in),.push(Z[1:0]),
.out(Q),.clk(clk));
dff qmin(.clrff(clrff),.qm1(qm1),.q1(q1_internal),.clk(clk),.sft(sftQ));
counter cn(.count(count),.decr(decr),.ldcnt(ldcnt),.clk(clk));

endmodule


module dff(
    input clrff,q1,clk,sft,
    output reg qm1
);
always@(posedge clk)begin
    if(clrff)qm1<=0;
    else if(sft) qm1<=q1;
end

endmodule


module counter(
    input decr,ldcnt,clk,
    output reg [4:0]count
);
    always@(posedge clk)begin
        if (ldcnt)count<=5'd7;
        else if(decr)count<=count-1;
    end

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


module alu(
    input  [2:0]addsub,
    input signed [17:0]A,
    input signed [15:0]M,
    output reg signed [17:0]Z
);
wire signed [17:0]M_ext,M_ext_2;
assign M_ext = {M[15],M[15],M};
assign M_ext_2 = M_ext<<1;

always @(*) begin
    case (addsub)
        0: Z=A+M_ext;
        1: Z=A+M_ext_2;
        2: Z=A;
        3: Z= A-M_ext_2;
        4: Z= A-M_ext;
        
    endcase
end
endmodule


module shiftreg_A(
    input sft,clr,ld,clk,
    input [17:0]in,
    input [1:0]push,
    output reg [17:0]out
);

always@(posedge clk)begin
    if(clr) out<=17'd0;
    else if(ld) begin
        if(~sft)out<=in;
        else out<={push,in[17:2]};
    end
    else if(sft)out<={push,out[17:2]};
end

endmodule

module shiftreg_Q(
    input sft,clr,ld,clk,
    input [15:0]in,
    input [1:0]push,
    output reg [15:0]out
);

always@(posedge clk)begin
    if(clr) out<=16'd0;
    else if(ld)out<=in;
    else if(sft)out<={push,out[15:2]};
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

