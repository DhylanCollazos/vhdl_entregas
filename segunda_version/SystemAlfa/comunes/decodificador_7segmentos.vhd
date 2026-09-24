library ieee;
use ieee.std_logic_1164.all;

entity decodificador_7segmentos is
    port (
        numero : in std_logic_vector(3 downto 0);
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity decodificador_7segmentos;

architecture combinacional of decodificador_7segmentos is
begin

    process(numero)
    begin
        case numero is
            when "0000" => segmentos <= "1000000"; -- 0
            when "0001" => segmentos <= "1111001"; -- 1
            when "0010" => segmentos <= "0100100"; -- 2
            when "0011" => segmentos <= "0110000"; -- 3
            when "0100" => segmentos <= "0011001"; -- 4
            when "0101" => segmentos <= "0010010"; -- 5
            when "0110" => segmentos <= "0000010"; -- 6
            when "0111" => segmentos <= "1111000"; -- 7
            when "1000" => segmentos <= "0000000"; -- 8
            when "1001" => segmentos <= "0010000"; -- 9
            when "1010" => segmentos <= "0001000"; -- A
            when "1011" => segmentos <= "0000011"; -- b
            when "1100" => segmentos <= "1000110"; -- C
            when "1101" => segmentos <= "0100001"; -- d
            when "1110" => segmentos <= "0000110"; -- E
            when "1111" => segmentos <= "0001110"; -- F

            when others =>
                segmentos <= "1111111"; -- Apagado
        end case;
    end process;

end architecture combinacional;