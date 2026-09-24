library ieee;
use ieee.std_logic_1164.all;

entity sincronizador is
    generic (
        ANCHO_BITS : positive := 1
    );
    port (
        reloj, reinicio : in std_logic;
        entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
        salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
    );
end entity sincronizador;

architecture comportamiento of sincronizador is

    signal etapa1, etapa2 :
        std_logic_vector(ANCHO_BITS-1 downto 0);

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa1 <= (others => '0');
            etapa2 <= (others => '0');

        elsif rising_edge(reloj) then
            etapa1 <= entrada;
            etapa2 <= etapa1;
        end if;
    end process;

    salida <= etapa2;

end architecture comportamiento;