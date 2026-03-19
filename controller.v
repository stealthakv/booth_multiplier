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
            if(~q0&&qm1)state<=S3;
            else if(~qm1&&q0)state<=S4;
            else state<=S5;
        end
        S3:state<=S5;
        S4:state<=S5;
        S5:begin
            if((~q0&&qm1)&&~eqz)state<=S3;
            else if((~qm1&&q0)&&~eqz)state<=S4;
            else if(eqz==1)state<=S6;
            else state <= S5;
        end
        S6:state<=S0;
        default:state<=S0;
    endcase
end

always@(state)begin
        ldA=0;clrA=0;sftA=0;ldQ=0;clrQ=0;sftQ=0;
        ldM=0;clrff=0;decr=0;ldcnt=0;done=0;addsub=0;   
    case(state)
        S0:begin
            addsub=1;
        end
        S1:begin
            clrA=1;clrQ=1;
            ldM=1;clrff=1;ldcnt=1;addsub=1;
        end
        S2:begin
            ldQ=1;
        end
        S3:begin
            ldA=1;
            addsub=1;
        end
        S4:begin
            ldA=1;
            addsub=0;
        end
        S5:begin
            sftA=1;sftQ=1;
            decr=1;
        end
        S6:begin
            sftA=0;sftQ=0;
            decr=0;
            ldA=0;ldQ=0;done=1;
        end
        default: begin
            clrA=0;sftA=0;ldQ=0;sftQ=0;
        end
    endcase
end


endmodule