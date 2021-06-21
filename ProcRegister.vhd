Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_arith.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
    port( bitin: in std_logic;
          bitout: out std_logic;
          writein: in std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
    signal q: std_logic;
begin
    process(writein) is
    begin
        if (rising_edge(writein)) then
            q <= bitin;
        end if;
    end process;
    bitout <= q;
end architecture memlike;

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_arith.all;
Use ieee.std_logic_unsigned.all;

entity register8mod is
    port(WriteData: in std_logic_vector(7 downto 0);
        WriteCmd: in std_logic;
        ReadData: out std_logic_vector(7 downto 0));
end entity register8mod;

architecture memmy of register8mod is
    component bitstorage
        port( bitin: in std_logic;
              bitout: out std_logic;
              writein: in std_logic);
    end component;
begin
    regloop: for i in 7 downto 0 generate
        reg8: bitstorage port map(WriteData(i), ReadData(i), WriteCmd);
    end generate;
end architecture memmy;

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_arith.all;
Use ieee.std_logic_unsigned.all;

entity register32mod is
    port( wordin: in std_logic_vector(31 downto 0);
          wordout: out std_logic_vector(31 downto 0);
          writeword, writelowhalfword, writelowbyte: in std_logic);
end entity register32mod;

architecture biggermem of register32mod is
    component register8mod
        port( WriteData: in std_logic_vector(7 downto 0);
              WriteCmd: in std_logic;
              ReadData: out std_logic_vector(7 downto 0));
    end component;
    signal writebyte1, writebyte2: std_logic;
begin
    writebyte1 <= writeword or writelowhalfword or writelowbyte;
    writebyte2 <= writeword or writelowhalfword;
    byte4: register8mod port map(wordin(31 downto 24), writeword, wordout(31 downto 24));
    byte3: register8mod port map(wordin(23 downto 16), writeword, wordout(23 downto 16));
    byte2: register8mod port map(wordin(15 downto 8), writebyte2, wordout(15 downto 8));
    byte1: register8mod port map(wordin(7 downto 0), writebyte1, wordout(7 downto 0));
end architecture biggermem;

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_arith.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
    port( datain: in std_logic_vector(31 downto 0);
          dir: in std_logic;
          shamt: in std_logic_vector(4 downto 0);
          dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
signal extdata: std_logic_vector(47 downto 0);
begin
    extdata <= "00000000" & datain & "00000000";
    with(dir & shamt) select
        dataout <= extdata(39 downto 8) when "000000",
                   extdata(39 downto 8) when "100000",
                   extdata(38 downto 7) when "000001",
                   extdata(37 downto 6) when "000010",
                   extdata(36 downto 5) when "000011",
                   extdata(35 downto 4) when "000100",
                   extdata(34 downto 3) when "000101",
                   extdata(33 downto 2) when "000110",
                   extdata(32 downto 1) when "000111",
                   extdata(31 downto 0) when "001000",
                   extdata(40 downto 9) when "100001",
                   extdata(41 downto 10) when "100010",
                   extdata(42 downto 11) when "100011",
                   extdata(43 downto 12) when "100100",
                   extdata(44 downto 13) when "100101",
                   extdata(45 downto 14) when "100110",
                   extdata(46 downto 15) when "100111",
                   extdata(47 downto 16) when "101000",
                   (others => 'Z') when others;
end shifter;

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_arith.all;
Use ieee.std_logic_unsigned.all;

entity bitadder is
    port( a,b,ci: in std_logic;
          c,co: out std_logic);
end entity bitadder;

architecture fulladder of bitadder is
begin
    c <= (a xor b) xor ci;
    co <= (a and b) or (ci and (a xor b));
end architecture fulladder;

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_arith.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
    port( datain_a: in std_logic_vector(31 downto 0);
          datain_b: in std_logic_vector(31 downto 0);
          add_sub: in std_logic;
          dataout: out std_logic_vector(31 downto 0);
          co: out std_logic);
end entity adder_subtracter;

architecture adder32 of adder_subtracter is
    component bitadder
        port(a,b,ci: in std_logic;
            c,co: out std_logic);
    end component;
    signal all_cio: std_logic_vector(32 downto 0);
    signal num2: std_logic_vector(31 downto 0); 
begin
    num2 <= datain_b when add_sub = '0' else
            not datain_b when add_sub = '1';
    all_cio(0) <= add_sub;
    adder32: for i in 0 TO 31 generate
        fa: bitadder port map(datain_a(i), num2(i), all_cio(i), dataout(i), all_cio(i+1));
    end generate;
    co <= all_cio(32);
end architecture adder32;