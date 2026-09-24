library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity historial is
    port (
        reloj, reinicio, escribir : in std_logic;

        posicion_escritura, posicion_lectura :
            in std_logic_vector(2 downto 0);

        tiempo_entrada, identificador_entrada :
            in std_logic_vector(7 downto 0);

        color_entrada : in std_logic_vector(1 downto 0);
        tamano_entrada : in std_logic;

        tiempo_salida, identificador_salida :
            out std_logic_vector(7 downto 0);

        color_salida : out std_logic_vector(1 downto 0);
        tamano_salida, registro_valido : out std_logic
    );
end entity historial;

architecture comportamiento of historial is

    type tipo_memoria is array (0 to 7)
        of std_logic_vector(18 downto 0);

    signal memoria : tipo_memoria;
    signal validos : std_logic_vector(7 downto 0);
    signal dato : std_logic_vector(18 downto 0);

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            memoria <= (others => (others => '0'));
            validos <= (others => '0');

        elsif rising_edge(reloj) then
            if escribir = '1' then

                memoria(to_integer(unsigned(posicion_escritura))) <=
                    tiempo_entrada &
                    identificador_entrada &
                    color_entrada &
                    tamano_entrada;

                validos(to_integer(unsigned(posicion_escritura))) <= '1';

            end if;
        end if;
    end process;

    dato <= memoria(to_integer(unsigned(posicion_lectura)));

    tiempo_salida <= dato(18 downto 11);
    identificador_salida <= dato(10 downto 3);
    color_salida <= dato(2 downto 1);
    tamano_salida <= dato(0);

    registro_valido <= validos(to_integer(unsigned(posicion_lectura)));

end architecture comportamiento;