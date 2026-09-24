library IEEE;
use IEEE.std_logic_1164.all;

entity decodificador is
port
(
    -- inputs
    c : in std_logic_vector(3 downto 0);

    -- output
    s : out std_logic_vector(6 downto 0)
);
end decodificador;

architecture arch_decodificador of decodificador is
signal m0 : std_logic_vector(6 downto 0);

begin

label_decoder: with c select

m0 <=  "1111110" when "0000", -- 0
       "0110000" when "0001", -- 1
       "1101101" when "0010", -- 2
       "1111001" when "0011", -- 3
       "0110011" when "0100", -- 4
       "1011011" when "0101", -- 5
       "1011111" when "0110", -- 6
       "1110000" when "0111", -- 7
       "1111111" when "1000", -- 8
       "1111011" when "1001", -- 9
       "1110111" when "1010", -- A
       "0011111" when "1011", -- b
       "1001110" when "1100", -- C
       "0111101" when "1101", -- d
       "1001111" when "1110", -- E
       "1000111" when others; -- F

s <= not m0;

end arch_decodificador;