`include "config.v"

`define IRamSize (`IRam_KB*1024/4) //kB->B->4B
`define SRamSize (`SRam_KB*1024/4) //kB->B->4B
`define RstPC 32'h0000_0000 //复位后PC值在0000

`ifdef STABLE_REV_RTL
`define STABLE_REV_RTL 1'b1
`else
`define STABLE_REV_RTL 1'b0
`endif



// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// R and M type inst
`define INST_TYPE_R_M 7'b0110011
// R type inst
`define INST_ADD    3'b000
`define INST_SUB    3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SRA    3'b101
`define INST_SRL    3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111
// M type inst
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_RET    32'h00008067

// J type inst
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111

// CSR inst
`define INST_SYS    7'b1110011
//fun3
`define INST_CSRRW  3'b001
`define INST_CSRRS  3'b010
`define INST_CSRRC  3'b011
`define INST_CSRRWI 3'b101
`define INST_CSRRSI 3'b110
`define INST_CSRRCI 3'b111
//特殊指令fun3=0,inst_i[31:15]
`define INST_SI     3'b000
`define INST_ECALL  17'h0
`define INST_EBREAK 17'b000000000001_00000
`define INST_MRET   17'b0011000_00010_00000
`define INST_WFI    17'b0001000_00101_00000

// CSR addr
`define CSR_MSTATUS    12'h300
`define CSR_MISA       12'h301
`define CSR_MIE        12'h304
`define CSR_MTVEC      12'h305
`define CSR_MSCRATCH   12'h340
`define CSR_MEPC       12'h341
`define CSR_MCAUSE     12'h342
`define CSR_MTVAL      12'h343
`define CSR_MIP        12'h344
`define CSR_MSIP       12'h345
`define CSR_MPRINTS    12'h346//sim标准输出
`define CSR_MENDS      12'h347//仿真结束

`define CSR_MINSTRET   12'hB02//
`define CSR_MINSTRETH  12'hB82//
`define CSR_MTIME      12'hB03//
`define CSR_MTIMEH     12'hB83//
`define CSR_MTIMECMP   12'hB04//
`define CSR_MTIMECMPH  12'hB84//
`define CSR_MCCTR      12'hB88//系统控制

`define CSR_MVENDORID  12'hF11
`define CSR_MARCHID    12'hF12
`define CSR_MIMPID     12'hF13
`define CSR_MHARTID    12'hF14



`define MemBus 31:0
`define MemAddrBus 31:0
`define CsrAddrBus 11:0

`define InstBus 31:0
`define InstAddrBus 31:0

// common regs
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32

/*
"defines.v is licensed under Apache-2.0 (http://www.apache.org/licenses/LICENSE-2.0)
   by Blue Liang, liangkangnan@163.com.
   I added more message.
*/