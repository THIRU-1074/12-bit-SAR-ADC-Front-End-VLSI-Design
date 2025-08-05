module testbench();
    // Registers to hold inputs to circuit under test, wires for outputs
    reg clk, go;
    wire valid, sample, cmp;
    wire [7:0] result;
    wire [7:0] value;

    // Instantiate the controller circuit
    controller c(clk, go, valid, result, sample, value, cmp);

    // Generate a clock with period of 20 time units
    always begin
        #10;
        clk = ~clk;
    end
    initial clk = 0;

    // Simulate analogue circuit with a digital model
    reg [7:0] hold;
    always @(posedge sample) hold = 8'b01000110;
    assign cmp = (hold >= value);

    // Monitor some signals and provide input stimuli
    initial begin
        $monitor($time, " go=%b valid=%b result=%b sample=%b value=%b cmp=%b state=%b mask=%b",
                 go, valid, result, sample, value, cmp, c.state, c.mask);
        #100; go = 0;
        #100; go = 1;
        #5000; go = 0;
        #5000; go = 1;
        #40; go = 0;
        #5000;
        $stop;
    end
endmodule
