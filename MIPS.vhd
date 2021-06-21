library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MIPS is
    Port ( clock: in std_logic );
end MIPS;

architecture finished of MIPS is

    component Processor
        Port ( instruction: in std_logic_vector (31 downto 0);
               DataMemdatain: in  std_logic_vector (31 downto 0);
               DataMemdataout: out  std_logic_vector (31 downto 0);
               instMemAddr: out  std_logic_vector (31 downto 0);
               DataMemAddr: out  std_logic_vector (31 downto 0);
               DataMemRead, DataMemWrite: out std_logic;
               clock: in  std_logic );
    end component;

    component code_mem
        port(address: in std_logic_vector(31 downto 0) := x"00000000";
             instruction: out std_logic_vector(31 downto 0) );
    end component;

    component data_mem
        port(address: in std_logic_vector(31 downto 0);
             writedata: in std_logic_vector(31 downto 0);
             memwrite: in std_logic;
             memread: in std_logic;
             readdata: out std_logic_vector(31 downto 0) );
    end component;

    signal instruction : std_logic_vector (31 downto 0);
    signal DataMemdatain : std_logic_vector (31 downto 0);
    signal DataMemdataout : std_logic_vector (31 downto 0);
    signal instMemAddr : std_logic_vector (31 downto 0);
    signal DataMemAddr : std_logic_vector (31 downto 0);
    signal DataMemRead, DataMemWrite: std_logic;

begin

    myprocessor: Processor port map(instruction, DataMemdatain, DataMemdataout, 
	         instMemAddr, DataMemAddr, DataMemRead, DataMemWrite, clock);
    my_code_mem: code_mem port map(instMemAddr, instruction);
    my_data_mem: data_mem port map(DataMemAddr, DataMemdataout, DataMemWrite,
	         DataMemRead, DataMemdatain);
    
end finished;