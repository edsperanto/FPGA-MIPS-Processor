----------------------------------------------------------------------------------
-- Company: Seattle University
-- Engineer: Edward Gao 
-- 
-- Create Date:    18:10:34 05/27/2019
-- Design Name: 
-- Module Name:    Control - Boss 
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

entity Control is
    Port ( clk_in: in std_logic;
           opcode : in  std_logic_vector (5 downto 0);
           RegDst : out  std_logic;
           Jump: out std_logic;
           Branch : out  std_logic;
           MemRead : out  std_logic;
           MemtoReg : out  std_logic;
           ALUOp : out  std_logic_vector(1 downto 0);
           MemWrite : out  std_logic;
           ALUSrc : out  std_logic;
           RegWrite : out  std_logic);
end Control;

architecture Boss of Control is
    signal output: std_logic_vector(9 downto 0);
begin

    output <= "1000100010" when opcode = "000000" else   -- opcode: 0x00 (R-type)
              "0011110000" when opcode = "100011" else   -- opcode: 0x23 (lw)
              "X01X101000" when opcode = "101011" else   -- opcode: 0x2b (sw)
              "X00X100101" when opcode = "000100" else   -- opcode: 0x04 (beq)
              "0010100000" when opcode = "001000" else   -- opcode: 0x08 (addi)
              "X1XXXXXXXX" when opcode = "000010" else   -- opcode: 0x02 (jump)
              "XXXXXXXXXX";

    RegDst <= output(9);
    Jump <= output(8);
    ALUSrc <= output(7);
    MemtoReg <= output(6);
    RegWrite <= output(5) and clk_in;
    MemRead <= output(4);
    MemWrite <= output(3) and (not clk_in);
    Branch <= output(2);
    ALUOp <= output(1 downto 0);

end Boss;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decoder3To8 is
    Port ( E: in std_logic;
           A: in std_logic_vector(2 downto 0);
           X: out std_logic_vector(7 downto 0) );
end entity Decoder3To8;

architecture onehot of Decoder3To8 is
    signal onehotout: std_logic_vector(7 downto 0);
begin
    with(A) select
        onehotout <= "10000000" when "111",
                     "01000000" when "110",
                     "00100000" when "101",
                     "00010000" when "100",
                     "00001000" when "011",
                     "00000100" when "010",
                     "00000010" when "001",
                     "00000001" when "000",
                     "00000000" when others;
    X <= onehotout when E = '1' else
         "00000000" when E = '0';
end onehot;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decoder5To32 is
    Port ( E: in std_logic;
           A: in std_logic_vector(4 downto 0);
           X: out std_logic_vector(31 downto 0) );
end entity Decoder5To32;

architecture onehot of Decoder5To32 is
    component Decoder3To8
        Port ( E: in std_logic;
               A: in std_logic_vector(2 downto 0);
               X: out std_logic_vector(7 downto 0) );
    end component;
    signal en0, en1: std_logic;
    signal sel: std_logic_vector(2 downto 0);
    signal onehotout: std_logic_vector(31 downto 0);
    signal endec0, endec1, endec2, endec3: std_logic;
begin
    en0 <= A(4);
    en1 <= A(3);
    sel <= A(2 downto 0);
    endec0 <= (not en0) and (not en1);
    endec1 <= (not en0) and en1;
    endec2 <= en0 and (not en1);
    endec3 <= en0 and en1;
    dec0: Decoder3To8 port map(endec0, sel, onehotout(7 downto 0));
    dec1: Decoder3To8 port map(endec1, sel, onehotout(15 downto 8));
    dec2: Decoder3To8 port map(endec2, sel, onehotout(23 downto 16));
    dec3: Decoder3To8 port map(endec3, sel, onehotout(31 downto 24));
    X <= onehotout when E = '1' else
         "00000000000000000000000000000000" when E = '0';
end onehot;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registers is
    Port ( ReadReg1, ReadReg2, WriteReg: in std_logic_vector(4 downto 0);
           WriteData: in std_logic_vector(31 downto 0);
           WriteCmd: in std_logic;
           ReadData1, ReadData2: out std_logic_vector(31 downto 0) );
end entity Registers;

architecture remember of Registers is
    component register32mod
        port( wordin: in std_logic_vector(31 downto 0);
              wordout: out std_logic_vector(31 downto 0);
              writeword, writelowhalfword, writelowbyte: in std_logic);
    end component;
    component Decoder5To32
        Port ( E: in std_logic;
               A: in std_logic_vector(4 downto 0);
               X: out std_logic_vector(31 downto 0) );
    end component;
    type t_reg_mux is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_mux: t_reg_mux;
    signal write_mux: std_logic_vector(31 downto 0);
begin
    registerbank: for i in 31 downto 1 generate
        regi: register32mod port map(WriteData, reg_mux(i), write_mux(i), '0', '0');
    end generate;
    writedec: Decoder5To32 port map(WriteCmd, WriteReg, write_mux);
    ReadData1 <= std_logic_vector(to_unsigned(0, 32)) when ReadReg1 = "00000" else
                 reg_mux(to_integer(unsigned(ReadReg1)));
    ReadData2 <= std_logic_vector(to_unsigned(0, 32)) when ReadReg2 = "00000" else
                 reg_mux(to_integer(unsigned(ReadReg2)));
end remember;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port( DataIn1,DataIn2: in std_logic_vector(31 downto 0);
          Control: in std_logic_vector(3 downto 0);
          shamt: in std_logic_vector(4 downto 0);
          Zero: out std_logic;
          ALUResult: out std_logic_vector(31 downto 0) );
end entity ALU;

architecture cogs of ALU is
    component adder_subtracter
        port( datain_a: in std_logic_vector(31 downto 0);
              datain_b: in std_logic_vector(31 downto 0);
              add_sub: in std_logic;
              dataout: out std_logic_vector(31 downto 0);
              co: out std_logic);
    end component;
    component shift_register
        port( datain: in std_logic_vector(31 downto 0);
              dir: in std_logic;
              shamt: in std_logic_vector(4 downto 0);
              dataout: out std_logic_vector(31 downto 0));
    end component;
    signal result: std_logic_vector(31 downto 0);
    signal addOrSub: std_logic;
    signal addSubResult: std_logic_vector(31 downto 0);
    signal slr: std_logic;
    signal shResult: std_logic_vector(31 downto 0);
    signal sltResult: std_logic_vector(31 downto 0);
begin

    addOrSub <= '1' when Control = "0110" else 
                '1' when Control = "0111" else
                '0' when Control = "0010";
    addsub: adder_subtracter port map(DataIn1, DataIn2, addOrSub, addSubResult);

    slr <= '0' when Control = "0011" else 
           '1' when Control = "0100" else
           'X';
    shifter: shift_register port map(DataIn2, slr, shamt, shResult);

    sltResult <= "00000000000000000000000000000001" when addSubResult(31) = '1' else
                 "00000000000000000000000000000000";

    with Control select
        result <= (DataIn1 and DataIn2) when "0000",   -- 0000 = and
                  (DataIn1 or DataIn2) when "0001",    -- 0001 = or
                  addSubResult when "0010",            -- 0010 = add
                  addSubResult when "0110",            -- 0110 = subtract
                  sltResult when "0111",               -- 0111 = slt
                  (DataIn1 nor DataIn2) when "1100",   -- 1100 = nor
                  shResult when "0011",                -- 0011 = sll
                  shResult when "0100",                -- 0100 = srl
                  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" when others;

    ALUResult <= result;
    Zero <= '1' when result = "00000000000000000000000000000000" else '0';

end architecture cogs;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
    Port( selector: in std_logic;
          In0, In1: in std_logic_vector(31 downto 0);
          Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
    with selector select
        Result <= In0 when '0',
                  In1 when '1',
                  In1 when others;

end architecture selection;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALUControl is
    Port( funct: in std_logic_vector(5 downto 0);
          shamtin: in std_logic_vector(4 downto 0);
          op: in std_logic_vector(1 downto 0);
          aluctrl: out std_logic_vector(3 downto 0);
          shamtout: out std_logic_vector(4 downto 0) );
end entity ALUControl;

architecture bossy of ALUControl is
begin
    shamtout <= shamtin;
    aluctrl <= "0010" when op = "00" else
               "0110" when op(0) = '1' else
               "0010" when op(1) = '1' and funct = "100000" else   -- add
               "0110" when op(1) = '1' and funct = "100010" else   -- sub
               "0000" when op(1) = '1' and funct = "100100" else   -- and
               "0001" when op(1) = '1' and funct = "100101" else   -- or
               "1100" when op(1) = '1' and funct = "100111" else   -- nor
               "0111" when op(1) = '1' and funct = "101010" else   -- slt
               "0011" when op(1) = '1' and funct = "000000" else   -- sll
               "0100" when op(1) = '1' and funct = "000010" else   -- srl
               "XXXX";
end architecture bossy;