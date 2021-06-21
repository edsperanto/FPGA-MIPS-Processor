Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

-- start at 10010000hex

entity data_mem is
    port(address: in std_logic_vector(31 downto 0);
         writedata: in std_logic_vector(31 downto 0);
         memwrite: in std_logic;
         memread: in std_logic;
         readdata: out std_logic_vector(31 downto 0) );
end entity data_mem;

architecture datamemlike of data_mem is
    type data_mem_arr is array (0 to 7) of std_logic_vector(31 downto 0);
    signal data_mem: data_mem_arr := (0 => x"00030000", 1 => x"00010000", 2 => x"11111111",others=> (others=>'0'));
    signal memreadaddr: std_logic_vector(35 downto 0);
begin
    memreadaddr <= "000" & memread & address;

    with (memreadaddr) select
        readdata <= data_mem(0) when x"110010000",
                    data_mem(1) when x"110010004",
                    data_mem(2) when x"110010008",
                    data_mem(3) when x"11001000c",
                    data_mem(4) when x"110010010",
                    data_mem(5) when x"110010014",
                    data_mem(6) when x"110010018",
                    data_mem(7) when x"11001001c",
                    std_logic_vector(to_unsigned(0, 32)) when others;
    process(memwrite)
    begin
        if rising_edge(memwrite) then
            if(address = x"10010000") then data_mem(0) <= writedata; end if;
            if(address = x"10010004") then data_mem(1) <= writedata; end if;
            if(address = x"10010008") then data_mem(2) <= writedata; end if;
            if(address = x"1001000c") then data_mem(3) <= writedata; end if;
            if(address = x"10010010") then data_mem(4) <= writedata; end if;
            if(address = x"10010014") then data_mem(5) <= writedata; end if;
            if(address = x"10010018") then data_mem(6) <= writedata; end if;
            if(address = x"1001001c") then data_mem(7) <= writedata; end if;
        end if;
    end process;
end architecture datamemlike;
