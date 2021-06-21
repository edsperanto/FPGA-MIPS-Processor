Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity code_mem is
    port(address: in std_logic_vector(31 downto 0);
         instruction: out std_logic_vector(31 downto 0) );
end entity code_mem;

architecture memlike of code_mem is
begin
    -- provide 16 instructions in response to 16 sequential addresses
    -- at the input. Choose instructions we will implement.
    with to_integer(unsigned(address)) select
        instruction <= x"20081001" when 0,
                       x"00084200" when 4,
                       x"00084200" when 8,
                       x"21090004" when 12,
                       x"212a0004" when 16,
                       x"8d0b0000" when 20,
                       x"8d2c0000" when 24,
                       x"8d4d0000" when 28,
                       x"016c8020" when 32,
                       x"020c7022" when 36,
                       x"100e0002" when 40,
                       x"01cc7022" when 44,
                       x"0800000a" when 48,
                       x"016d9024" when 52,
                       x"018d9825" when 56,
                       x"ad130000" when 60,
                       std_logic_vector(to_unsigned(0, 32)) when others;
end architecture memlike;
