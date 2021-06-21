----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:11:17 02/27/2008 
-- Design Name: 
-- Module Name:    Processor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SmallBusMux2to1 is
    Port( selector: in std_logic;
          In0, In1: in std_logic_vector(4 downto 0);
          Result: out std_logic_vector(4 downto 0) );
end entity SmallBusMux2to1;

architecture switching of SmallBusMux2to1 is
begin
    with selector select
        Result <= In0 when '0',
                  In1 when '1',
                  In1 when others;
end architecture switching;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( instruction : in  std_logic_vector (31 downto 0);
           DataMemdatain : in  std_logic_vector (31 downto 0);
           DataMemdataout : out  std_logic_vector (31 downto 0);
           instMemAddr : out  std_logic_vector (31 downto 0);
           DataMemAddr : out  std_logic_vector (31 downto 0);
           DataMemRead, DataMemWrite: out std_logic;
           clock : in  std_logic );
end Processor;

architecture holistic of Processor is

    component Control
        Port( clk_in: in std_logic;
              opcode : in  std_logic_vector (5 downto 0);
              RegDst : out  std_logic;
              Jump: out std_logic;
              Branch : out  std_logic;
              MemRead : out  std_logic;
              MemtoReg : out  std_logic;
              ALUOp : out std_logic_vector(1 downto 0);
              MemWrite : out  std_logic;
              ALUSrc : out  std_logic;
              RegWrite : out  std_logic);
    end component;

    component Registers
        Port ( ReadReg1, ReadReg2, WriteReg: in std_logic_vector(4 downto 0);
               WriteData: in std_logic_vector(31 downto 0);
               WriteCmd: in std_logic;
               ReadData1, ReadData2: out std_logic_vector(31 downto 0));
    end component;
    
    component ALU
        Port( DataIn1,DataIn2: in std_logic_vector(31 downto 0);
              Control: in std_logic_vector(3 downto 0);
              shamt: in std_logic_vector(4 downto 0);
              Zero: out std_logic;
              ALUResult: out std_logic_vector(31 downto 0) );
    end component;
    
    component BusMux2to1
        Port( selector: in std_logic;
              In0, In1: in std_logic_vector(31 downto 0);
              Result: out std_logic_vector(31 downto 0) );
    end component;
    
    component SmallBusMux2to1
        Port( selector: in std_logic;
              In0, In1: in std_logic_vector(4 downto 0);
              Result: out std_logic_vector(4 downto 0) );
    end component;
    
    component ALUControl
        Port( funct: in std_logic_vector(5 downto 0);
              shamtin: in std_logic_vector(4 downto 0);
              op: in std_logic_vector(1 downto 0);
              aluctrl: out std_logic_vector(3 downto 0);
              shamtout: out std_logic_vector(4 downto 0) );
    end component;
    
    component register32mod
        port( wordin: in std_logic_vector(31 downto 0);
              wordout: out std_logic_vector(31 downto 0);
              writeword, writelowhalfword, writelowbyte: in std_logic);
    end component;
    
    component adder_subtracter
        port( datain_a: in std_logic_vector(31 downto 0);
              datain_b: in std_logic_vector(31 downto 0);
              add_sub: in std_logic;
              dataout: out std_logic_vector(31 downto 0);
              co: out std_logic);
    end component;

    signal instr31to26, instr5to0: std_logic_vector(5 downto 0);
    signal instr25to21, instr20to16, instr15to11, instr10to6: std_logic_vector(4 downto 0);
    signal instr15to0: std_logic_vector(15 downto 0);
    signal instr25to0: std_logic_vector(25 downto 0);
    signal muxToWrReg: std_logic_vector(4 downto 0);
    signal muxToWrData: std_logic_vector(31 downto 0);
    signal ReadData1, ReadData2: std_logic_vector(31 downto 0);
    signal RegDst, Jump, Branch, MemtoReg, ALUSrc, RegWrite: std_logic;
    signal ALUOp: std_logic_vector(1 downto 0);
    signal extImm, muxToALU, ALUresult: std_logic_vector(31 downto 0);
    signal ALUCtrltoALU: std_logic_vector(3 downto 0);
    signal shamtRedir: std_logic_vector(4 downto 0);
    signal ALUzero, andToMuxSel: std_logic;
    signal extImmSL2: std_logic_vector(31 downto 0);
    signal PCin, PCout, incr4out, addToMux, muxMuxOut, pcMuxOut: std_logic_vector(31 downto 0);
    signal jAddr: std_logic_vector(31 downto 0);
    signal four: std_logic_vector(31 downto 0);
    signal useless, notRegWrite: std_logic;

begin

    instr31to26 <= instruction(31 downto 26);
    instr25to21 <= instruction(25 downto 21);
    instr20to16 <= instruction(20 downto 16);
    instr15to11 <= instruction(15 downto 11);
    instr15to0 <= instruction(15 downto 0);
    instr10to6 <= instr15to0(10 downto 6);
    instr5to0 <= instr15to0(5 downto 0);
    instr25to0 <= instruction(25 downto 0);
    extImm <= "0000000000000000" & instr15to0 when instr15to0(15) = '0' else
              "1111111111111111" & instr15to0 when instr15to0(15) = '1' else
              "XXXXXXXXXXXXXXXX" & instr15to0;

    myctrl: Control port map(clock, instr31to26, RegDst, Jump, Branch, 
            DataMemRead, MemtoReg, ALUOp, DataMemWrite, ALUSrc, RegWrite);

    instrMux: SmallBusMux2to1 port map(RegDst, instr20to16, instr15to11, muxToWrReg);

    notRegWrite <= not RegWrite;
    myregisters: Registers port map(instr25to21, instr20to16, muxToWrReg, muxToWrData,
                 notRegWrite, ReadData1, ReadData2);

    DataMemdataout <= ReadData2;

    regToMux: BusMux2to1 port map(ALUSrc, ReadData2, extImm, muxToALU);

    ALUCtrl: ALUControl port map(instr5to0, instr10to6, ALUOp, ALUCtrltoALU, shamtRedir);

    myALU: ALU port map(ReadData1, muxToALU, ALUCtrltoALU, shamtRedir, ALUzero, ALUresult);

    DataMemAddr <= ALUresult;

    memToMux: BusMux2to1 port map(MemtoReg, ALUresult, DataMemdatain, muxToWrData);

    extImmSL2 <= extImm(29 downto 0) & "00";

    PCin <= x"00000000" when pcMuxOut = "XXXXXXXX" else pcMuxOut;
    PC: register32mod port map(PCin, PCout, clock, '0', '0');

    instMemAddr <= PCout;

    four <= "00000000000000000000000000000100";
    incrPCby4: adder_subtracter port map(PCout, four, '0', incr4out, useless);

    branchAdder: adder_subtracter port map(incr4out, extImmSL2, '0', addToMux, useless);
    
    jAddr <= incr4out(31 downto 28) & instr25to0 & "00";
    
    jMux: BusMux2to1 port map(Jump, muxMuxOut, jAddr, pcMuxOut);

    andToMuxSel <= Branch and ALUzero;
    muxToMux: BusMux2to1 port map(andToMuxSel, incr4out, addToMux, muxMuxOut);

end holistic;

