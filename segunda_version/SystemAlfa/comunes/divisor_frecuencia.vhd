library ieee;
use ieee.std_logic_1164.all;

entity divisor_frecuencia is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000
    );
    port (
        reloj, reinicio : in std_logic;
        nivel : in std_logic_vector(1 downto 0);
        pulso_linea : out std_logic
    );
end entity divisor_frecuencia;

architecture comportamiento of divisor_frecuencia is

    signal cuenta :
        integer range 0 to 2*FRECUENCIA_RELOJ_HZ-1 := 0;

    signal periodo :
        integer range 1 to 2*FRECUENCIA_RELOJ_HZ;

    signal anterior :
        std_logic_vector(1 downto 0) := "00";

begin

    process(nivel)
    begin
        case nivel is
            when "00" =>
                periodo <= FRECUENCIA_RELOJ_HZ/2;

            when "01" =>
                periodo <= FRECUENCIA_RELOJ_HZ;

            when "10" =>
                periodo <= (FRECUENCIA_RELOJ_HZ+1)/3;

            when others =>
                periodo <= 2*FRECUENCIA_RELOJ_HZ;
        end case;
    end process;

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            cuenta <= 0;
            anterior <= "00";
            pulso_linea <= '0';

        elsif rising_edge(reloj) then
            pulso_linea <= '0';
            anterior <= nivel;

            if nivel /= anterior then
                cuenta <= 0;

            elsif cuenta = periodo-1 then
                cuenta <= 0;
                pulso_linea <= '1';

            else
                cuenta <= cuenta + 1;
            end if;
        end if;
    end process;

end architecture comportamiento;