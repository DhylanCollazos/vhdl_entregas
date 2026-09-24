library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity registro_color is
    port (
        reloj, reinicio, HABILITAR : in std_logic;
        color_entrada : in std_logic_vector(1 downto 0);
        color_salida : out std_logic_vector(1 downto 0)
    );
end entity registro_color;

architecture estructural of registro_color is
begin

    U_REGISTRO : lpm_ff
        generic map (
            lpm_width  => 2,
            lpm_fftype => "DFF",
            lpm_type   => "LPM_FF"
        )
        port map (
            clock  => reloj,
            aclr   => reinicio,
            enable => HABILITAR,
            data   => color_entrada,
            q      => color_salida
        );

end architecture estructural;