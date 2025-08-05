// ADC controller
module controller(clk,go,valid,result, sample,value,cmp);
    input clk; // clock input
    input go; // go=1 to perform conversion
    output valid; // valid=1 when conversion finished
    output [7:0] result; // 8-bit result output
    output sample; // to S&H circuit
    output [7:0] value; // to DAC
    input cmp; // from comparator
    reg [1:0] state; // current state in state machine
    reg [7:0] mask; // bit to test in binary search
    reg [7:0] result; // hold partially converted result

    // state assignment
    parameter sWait=0, sSample=1, sConv=2, sDone=3;

    // synchronous design
    always @(posedge clk) begin
        if (!go)
            state <= sWait; // stop and reset if go=0
        else
            case (state) // choose next state in state machine
                sWait : state <= sSample;
                sSample : begin // start new conversion
                    state <= sConv; // enter convert state next
                    mask <= 8'b10000000; // reset mask to MSB only
                    result <= 8'b0; // clear result
                end
                sConv : begin
                    // set bit if comparator indicates input larger than value currently under consideration
                    if (cmp) result <= result | mask;
                    // shift mask to try next bit next time
                    mask <= mask >> 1;
                    // finished once LSB has been done
                    if (mask[0]) state <= sDone;
                end
                sDone :;
            endcase
    end

    assign sample = (state == sSample); // drive sample and hold
    assign value = result | mask; // (result so far) OR (bit to try)
    assign valid = (state == sDone); // indicate when finished
endmodule
