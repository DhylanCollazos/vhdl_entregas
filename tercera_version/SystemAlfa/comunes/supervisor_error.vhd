library ieee;
use ieee.std_logic_1164.all;

entity supervisor_error is
    generic (
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        reloj, reinicio, marcha, presencia_activa : in std_logic;
        nueva_pieza, pieza_valida : in std_logic;
        alarma : out std_logic
    );
end entity supervisor_error;

architecture comportamiento of supervisor_error is

    signal cuenta :
        integer range 0 to CICLOS_ATASCO-1 := 0;

    signal error : std_logic := '0';

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            cuenta <= 0;
            error <= '0';

        elsif rising_edge(reloj) then

            if marcha = '1' and
               nueva_pieza = '1' and
               pieza_valida = '0' then

                error <= '1';
            end if;

            if marcha = '0' or presencia_activa = '0' then
                cuenta <= 0;

            elsif cuenta = CICLOS_ATASCO-1 then
                error <= '1';

            else
                cuenta <= cuenta + 1;
            end if;
        end if;
    end process;

    alarma <= error;

end architecture comportamiento;