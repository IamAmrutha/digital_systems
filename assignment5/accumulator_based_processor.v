module pc(
    input clk_sig,
    input rst_sig,
    input load,
    input [3:0] addr_in,
    output reg [3:0] addr_out
);
    always @(posedge clk_sig or posedge rst_sig) begin
        if (rst_sig)
            addr_out <= 4'b0000;
        else if (load)
            addr_out <= addr_in;
        else
            addr_out <= addr_out + 1;
    end
endmodule


module control_unit(
    input [7:0] instr,
    output reg [7:0] opcode,
    output reg [3:0] operand,
    output reg pc_load,
    output reg acc_load,
    output reg cb_update,
    output reg wr_enable,
    output reg ext_load
);
    always @(*) begin
        opcode = instr;
        operand = instr[3:0];
        pc_load = 0;
        acc_load = 0;
        cb_update = 0;
        wr_enable = 0;
        ext_load = 0;

        case (instr[7:4])
            4'b0000: begin
                acc_load = (instr[3:0] != 4'b0000);
                cb_update = (instr[3:0] == 4'b0110 || instr[3:0] == 4'b0111);
            end
            4'b0001: begin acc_load = 1; cb_update = 1; end
            4'b0010: begin acc_load = 1; cb_update = 1; end
            4'b0011: begin acc_load = 1; ext_load = 1; end
            4'b0101: acc_load = 1;
            4'b0110: acc_load = 1;
            4'b0111: cb_update = 1;
            4'b1000: pc_load = 1;
            4'b1001: acc_load = 1;
            4'b1010: wr_enable = 1;
            4'b1011: pc_load = 1;
            default: ;
        endcase
    end
endmodule

module register_file(
    input clk_sig,
    input wr_enable,
    input [3:0] wr_addr,
    input [3:0] rd_addr,
    input [7:0] data_in_reg,
    output [7:0] data_out_reg
);
    reg [7:0] registers [15:0];
    integer i;

   initial begin
    for (i = 0; i < 16; i = i + 1)
        registers[i] = 8'h00;

    registers[1] = 8'h02;  // R1 = 2
    registers[2] = 8'h03;  // R2 = 3
    registers[3] = 8'h05;  // R3 = 5

    registers[5] = 8'h02;  // R5 = 2
    registers[6] = 8'h03;  // R6 = 3
    end


    always @(posedge clk_sig) begin
        if (wr_enable)
            registers[wr_addr] <= data_in_reg;
    end

    assign data_out_reg = registers[rd_addr];
endmodule

module accumulator(
    input clk_sig,
    input rst_sig,
    input load,
    input [7:0] data_in,
    output reg [7:0] data_out
);
    always @(posedge clk_sig or posedge rst_sig) begin
        if (rst_sig)
            data_out <= 8'h00;
        else if (load)
            data_out <= data_in;
    end
endmodule

module alu(
    input [7:0] opcode,
    input [7:0] acc,
    input [7:0] reg_val,
    output reg [7:0] result,
    output reg [7:0] ext,
    output reg cb_flag
);
    always @(*) begin
        result = 8'd0;
        ext = 8'd0;
        cb_flag = 0;

        case (opcode[7:4])
            4'b0000: begin
                case (opcode[3:0])
                    4'b0000: result = acc;
                    4'b0001: result = {acc[6:0], 1'b0};
                    4'b0010: result = {1'b0, acc[7:1]};
                    4'b0011: result = {acc[0], acc[7:1]};
                    4'b0100: result = {acc[6:0], acc[7]};
                    4'b0101: result = {acc[7], acc[7:1]};
                    4'b0110: {cb_flag, result} = acc + 8'd1;
                    4'b0111: {cb_flag, result} = acc - 8'd1;
                    default: result = acc;
                endcase
            end
            4'b0001: {cb_flag, result} = acc + reg_val;
            4'b0010: {cb_flag, result} = acc - reg_val;
            4'b0011: {ext, result} = acc * reg_val;
            4'b0101: result = acc & reg_val;
            4'b0110: result = acc ^ reg_val;
            4'b0111: begin
                result = acc - reg_val;
                cb_flag = (acc < reg_val);
            end
            default: result = acc;
        endcase
    end
endmodule

module ext_register(
    input clk_sig,
    input load,
    input [7:0] data_in,
    output reg [7:0] data_out
);
    always @(posedge clk_sig) begin
        if (load)
            data_out <= data_in;
    end
endmodule

module cb_flag_register(
    input clk_sig,
    input rst_sig,
    input set,
    input value,
    output reg cb
);
    always @(posedge clk_sig or posedge rst_sig) begin
        if (rst_sig)
            cb <= 0;
        else if (set)
            cb <= value;
    end
endmodule

module TH_5(
    input clk_sig,
    input rst_sig,
    output [7:0] acc_final,
    output is_halted
);
    wire [3:0] pc_value, operand;
    wire [7:0] opcode, instr_code, reg_val, alu_out, ext_out;
    wire [7:0] acc_val;
    wire alu_cb_flag, cb_status;
    wire pc_load, acc_load, cb_update, wr_enable, ext_load;
    reg halt_state = 0;

    reg [7:0] instr_rom [15:0];
    wire [7:0] ext_reg_out;

    pc PC_INST(
        .clk_sig(clk_sig),
        .rst_sig(rst_sig),
        .load(pc_load && (opcode[7:4] != 4'b1000 || cb_status)),
        .addr_in(operand),
        .addr_out(pc_value)
    );

    control_unit CU_INST(
        .instr(instr_code),
        .opcode(opcode),
        .operand(operand),
        .pc_load(pc_load),
        .acc_load(acc_load),
        .cb_update(cb_update),
        .wr_enable(wr_enable),
        .ext_load(ext_load)
    );

    register_file RF_INST(
        .clk_sig(clk_sig),
        .wr_enable(wr_enable),
        .wr_addr(operand),
        .rd_addr(operand),
        .data_in_reg(acc_val),
        .data_out_reg(reg_val)
    );

    accumulator ACC_INST(
        .clk_sig(clk_sig),
        .rst_sig(rst_sig),
        .load(acc_load),
        .data_in((opcode[7:4] == 4'b1001) ? reg_val : alu_out),
        .data_out(acc_val)
    );

    alu ALU_INST(
        .opcode(opcode),
        .acc(acc_val),
        .reg_val(reg_val),
        .result(alu_out),
        .ext(ext_out),
        .cb_flag(alu_cb_flag)
    );

    cb_flag_register CB_INST(
        .clk_sig(clk_sig),
        .rst_sig(rst_sig),
        .set(cb_update),
        .value(alu_cb_flag),
        .cb(cb_status)
    );

    ext_register EXT_INST(
        .clk_sig(clk_sig),
        .load(ext_load),
        .data_in(ext_out),
        .data_out(ext_reg_out)
    );

    assign instr_code = instr_rom[pc_value];
    assign acc_final = acc_val;
    assign is_halted = halt_state;

    initial begin
    instr_rom[0] = 8'b0000_0000;  // NOP
    instr_rom[1] = 8'b1001_0001; // MOV ACC, R1 - Move contents of R1 to ACC
    instr_rom[2] = 8'b0000_0110; // INC ACC - Increment ACC by 1
    instr_rom[3] = 8'b1001_0010; // MOV ACC, R2 - Move contents of R2 to ACC
    instr_rom[4] = 8'b0001_0101; // ADD R5 - Add R5 to ACC, store result in ACC, update C/B  
    instr_rom[5] = 8'b0010_0110; // SUB R6 - Subtract R6 from ACC, store result in ACC, update C/B
    instr_rom[6] = 8'b0011_0101; // MUL R5 - Multiply ACC with R5, store result in ACC, update EXT
    instr_rom[7] = 8'b0101_0101; // AND R5 - Bitwise AND between ACC and R5, store result in ACC
    instr_rom[8] = 8'b0110_0101; // XOR R5 - Bitwise XOR between ACC and R5, store result in ACC
    instr_rom[9] = 8'b0111_0110; // CMP R6 - Compare ACC with R6, update C/B (no effect on ACC)
    instr_rom[10] = 8'b0000_0001; // LSL ACC - Logical Shift Left ACC by 1 bit  
    instr_rom[11] = 8'b0000_0010; // LSR ACC - Logical Shift Right ACC by 1 bit
    instr_rom[12] = 8'b0000_0011; // CIR ACC - Circular Right Shift ACC
    instr_rom[13] = 8'b0000_0100; // CIL ACC - Circular Left Shift ACC
    instr_rom[14] = 8'b0000_0111; // DEC ACC - Decrement ACC by 1
    instr_rom[15] = 8'b1111_1111; // HLT - Stop the processor
    end

    always @(posedge clk_sig or posedge rst_sig) begin
        if (rst_sig)
            halt_state <= 0;
        else if (instr_code == 8'b1111_1111)
            halt_state <= 1;
    end
endmodule

//TEST BENCH: 
module TH_5_tb();
    reg clk_sig;
    reg rst_sig;
    wire [7:0] acc_final;
    wire is_halted;

    TH_5 DUT (
        .clk_sig(clk_sig),
        .rst_sig(rst_sig),
        .acc_final(acc_final),
        .is_halted(is_halted)
    );

    always #5 clk_sig = ~clk_sig;

    initial begin
        clk_sig = 0;
        rst_sig = 1;
        #10 rst_sig = 0;
        wait(is_halted);
        #20;
        $finish;
    end
endmodule