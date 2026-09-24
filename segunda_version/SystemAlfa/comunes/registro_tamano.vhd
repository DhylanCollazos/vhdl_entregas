library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity registro_tamano is
    port (
        reloj, reinicio, HABILITAR, tamano_entrada : in std_logic;
        tamano_salida : out std_logic
    );
end entity registro_tamano;

architecture estructural of registro_tamano is

    signal dato, valor : std_logic_vector(0 downto 0);

begin

    dato(0) <= tamano_entrada;

    U_REGISTRO : lpm_ff
        generic map (
            lpm_width  => 1,
            lpm_fftype => "DFF",
            lpm_type   => "LPM_FF"
        )
        port map (
            clock  => reloj,
            aclr   => reinicio,
            enable => HABILITAR,
            data   => dato,
            q      => valor
        );

    tamano_salida <= valor(0);

end architecture estructural;