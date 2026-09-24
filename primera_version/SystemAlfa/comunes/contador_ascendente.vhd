library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity contador_ascendente is
    generic (
        ANCHO_BITS : positive := 4
    );
    port (
        reloj, reinicio, habilitar : in std_logic;
        CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
    );
end entity contador_ascendente;

architecture estructural of contador_ascendente is
begin

    U_CONTADOR : lpm_counter
        generic map (
            lpm_width     => ANCHO_BITS,
            lpm_direction => "UP",
            lpm_type      => "LPM_COUNTER"
        )
        port map (
            clock  => reloj,
            aclr   => reinicio,
            cnt_en => habilitar,
            q      => CUENTA
        );

end architecture estructural;