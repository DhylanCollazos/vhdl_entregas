library ieee;
use ieee.std_logic_1164.all;

entity reinicio_seguro is
    port (
        reloj           : in std_logic;
        reinicio_bajo   : in std_logic;
        reinicio_salida : out std_logic
    );
end entity reinicio_seguro;

architecture comportamiento of reinicio_seguro is

    signal paso1 : std_logic := '1';
    signal paso2 : std_logic := '1';

begin

    process(reloj, reinicio_bajo)
    begin

        -- El pulsador activa el reinicio cuando vale cero.
        if reinicio_bajo = '0' then

            paso1 <= '1';
            paso2 <= '1';

        -- La liberacion del reinicio sigue el reloj.
        elsif rising_edge(reloj) then

            paso1 <= '0';
            paso2 <= paso1;

        end if;

    end process;

    -- La segunda etapa entrega el reinicio al resto del circuito.
    reinicio_salida <= paso2;

end architecture comportamiento;