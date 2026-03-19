`timescale 1ns/1ps

module controller(
    input q0,qm1,start,clk,eqz,
    output reg ldA,clrA,sftA,ldQ,clrQ,sftQ,ldM,clrff,decr,ldcnt,done,
    output reg [1:0] addsub
);

localparam S0=3'd0,
           S1=3'd1,
           S2=3'd2,
           S3=3'd3,
           S4=3'd4,
           S5=3'd5,
           S6=3'd6,
           S7=3'd7;
reg[2:0]state=S0;

always@(posedge clk)begin
    case(state)
        S0:if(start)state<=S1;
        S1:state<=S2;
        S2:begin
            state<=S3;
        end
        S3:begin
            if(eqz==1)state<=S4;
            else state <= S3;
        end
        S4:state<=S0;
        default:state<=S0;
    endcase
end

always @(*) begin
    ldA=0; clrA=0; sftA=0; ldQ=0; clrQ=0; sftQ=0;
    ldM=0; clrff=0; decr=0; ldcnt=0; done=0; addsub=2;

    case(state)
        S0: begin
            addsub = 2;
        end

        S1: begin
            clrA=1; clrQ=1;
            ldM=1; clrff=1; ldcnt=1;
        end

        S2: begin
            ldQ=1;
        end

        S3: begin
            // Booth decision
            if ({q0, qm1} == 2'b01)
                addsub = 0;   // add
            else if ({q0, qm1} == 2'b10)
                addsub = 1;   // subtract
            else
                addsub = 2;   // pass

            ldA=1;
            sftA=1; sftQ=1;
            decr=1;
        end

        S4: begin
            done=1;
        end
    endcase
end


endmodule