module GENERAL_CONTROL_MODULE(
    input clk,
    input rstn,
    input ins [31:0],

    output pc_en,
    output immode[2:0],
    output wbe,
    output branch_occr[1:0],
    output a_sel[1:0],
    output b_sel[1:0],
    output alu_mode[5:0],
    output branch_cond[1:0],
    output data_mode[1:0],
    output dcache_rw,
    output dcache_en,
    output wbs[2:0]
);

//states
logic ID_ins[31:0], EX_ins[31:0], MEN_ins[31:0], WB_ins[31:0], hazard;

parameter
    R = 7'b0110011, 
    I_1 = 7'b0010011,
    I_2 = 7'b0000011, 
    I_3 = 7'b1100111,
    S = 7'b0100011, 
    B = 7'b1100011,
    U1 = 7'b0110111, 
    U2 = 7'b0010111,
    J = 7'b1101111, 
    NOP1 = 7'b0000000, 
    NOP2 = 7'b0001111, 
    NOP3 = 7'b1110011;

assign immode = (ins[6:0] == R) ? (0):
                (ins[6:0] == I_1 || ins[6:0] == I_2 || ins[6:0] == I_3) ? (1):
                (ins[6:0] == S) ? (2):
                (ins[6:0] == B) ? (3):
                (ins[6:0] == U) ? (4):
                (ins[6:0] == J) ? (5):
                (ins[6:0] == NOP1 || ins[6:0] == NOP2 || ins[6:0] == NOP3) ? (0):
                (0);

always_comb
begin
    case(ID_ins[6:0])
    R || I_2:
        begin
            addr_mode = 0;
            branch_occr = 0;
            a_sel = 0;
            b_sel = 0;
        end
    I_1 || I_2:
        begin
            addr_mode = 0;
            branch_occr = 0;
            a_sel = 0;
            b_sel = 1;
        end
    I_3:
        begin
            addr_mode = 1;
            branch_occr = 1;
            a_sel = 1;
            b_sel = 2;
        end
    S:
        begin
            addr_mode = 1;
            branch_occr = 0;
            a_sel = 0;
            b_sel = 0;
        end
    B:
        begin
            addr_mode = 0;
            branch_occr = 2;
            a_sel = 0;
            b_sel = 0;
        end
    U1 || U2:
        begin
            addr_mode = 0;
            branch_occr = 0;
            a_sel = ID_ins[5:4];
            b_sel = 0;
        end
    J:
        begin
            addr_mode = 0;
            branch_occr = 1;
            a_sel = 1;
            b_sel = 2;
        end
    NOP1 || NOP2 || NOP3:
        begin
            addr_mode = 0;
            branch_occr = 0;
            a_sel = 0;
            b_sel = 0;
        end
    endcase
end

always_comb
begin
    case(EX_ins[6:0])
    R:
        begin
            alu_mode = EX_ins[31:25] + EX_ins[14:12];
            branch_cond = 0;
        end
    I_1: //is this correct?
        begin
            alu_mode =  (EX_ins[14:12] == 3'h5) ? (EX_ins[31:25] + EX_ins[14:12]) : 
                        (EX_ins[14:12]);
            branch_cond = 0;
        end
    I_2 || I_3 || S || U1 || U2 || NOP1 || NOP2 || NOP3:
        begin
            alu_mode = EX_ins[31:25] + EX_ins[14:12];
            branch_cond = (EX_ins[6:0] == I_3 || EX_ins[6:0] == J) ? (3) : (0);
        end
    B:
        begin
            alu_mode =  (EX_ins[14:12] == 4 || EX_ins[14:12] == 5) ? (6'h02): 
                        (EX_ins[14:12] == 6 || EX_ins[14:12] == 7) ? (6'h03):
                        (6'h20);

            branch_cond =   (EX_ins[14:12] == 1 || EX_ins[14:12] == 4 || EX_ins[14:12] == 6) ? (1) :
                            (2);
        end
    J:
        begin
            alu_mode = 0;
            branch_cond = 0;
        end
    endcase
end

//always @(posedge clk)


endmodule