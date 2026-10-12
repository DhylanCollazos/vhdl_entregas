library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_segundos is
    port (
        reloj, reinicio, pulso_segundo : in std_logic;
        segundos : out std_logic_vector(7 downto 0)
    );
end entity contador_segundos;

architecture comportamiento of contador_segundos is

    signal cuenta : unsigned(7 downto 0);

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            cuenta <= (others => '0');

        elsif rising_edge(reloj) then
            if pulso_segundo = '1' then

                if cuenta = 179 then
                    cuenta <= (others => '0');

                else
                    cuenta <= cuenta + 1;
                end if;
            end if;
        end if;
    end process;

    segundos <= std_logic_vector(cuenta);

end architecture comportamiento;	