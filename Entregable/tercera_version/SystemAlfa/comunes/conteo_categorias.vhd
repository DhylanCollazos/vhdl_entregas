library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conteo_categorias is
    port (
        reloj, reinicio, registrar : in std_logic;

        categoria : in std_logic_vector(3 downto 0);
        seleccion : in std_logic_vector(2 downto 0);

        por_color : in std_logic;

        total, cantidad_seleccionada :
            out std_logic_vector(9 downto 0);

        limite : out std_logic
    );
end entity conteo_categorias;

architecture estructural of conteo_categorias is

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    type seis_contadores is array (1 to 6)
        of std_logic_vector(9 downto 0);

    type tres_contadores is array (1 to 3)
        of std_logic_vector(9 downto 0);

    signal cantidades : seis_contadores;
    signal colores : tres_contadores;

    signal habilitar_categoria : std_logic_vector(6 downto 1);
    signal habilitar_color : std_logic_vector(3 downto 1);

    signal cuenta_total : std_logic_vector(9 downto 0);
    signal aceptar, completa : std_logic;

begin

    completa <= '1'
        when unsigned(cuenta_total) >= 999
        else '0';

    -- Solo se aceptan las categorias 1 a 6.
    aceptar <= registrar and not completa
        when categoria = "0001" or
             categoria = "0010" or
             categoria = "0011" or
             categoria = "0100" or
             categoria = "0101" or
             categoria = "0110"
        else '0';

    U_TOTAL : contador_ascendente
        generic map (
            ANCHO_BITS => 10
        )
        port map (
            reloj     => reloj,
            reinicio  => reinicio,
            habilitar => aceptar,
            CUENTA    => cuenta_total
        );

    -- Se crean seis contadores, uno para cada categoria.
    G_CATEGORIAS : for indice in 1 to 6 generate

        habilitar_categoria(indice) <= aceptar
            when categoria = std_logic_vector(to_unsigned(indice, 4))
            else '0';

        U_CATEGORIA : contador_ascendente
            generic map (
                ANCHO_BITS => 10
            )
            port map (
                reloj     => reloj,
                reinicio  => reinicio,
                habilitar => habilitar_categoria(indice),
                CUENTA    => cantidades(indice)
            );

    end generate G_CATEGORIAS;

    -- Rojo: categorias 1 y 2.
    habilitar_color(1) <=
        habilitar_categoria(1) or habilitar_categoria(2);

    -- Verde: categorias 3 y 4.
    habilitar_color(2) <=
        habilitar_categoria(3) or habilitar_categoria(4);

    -- Azul: categorias 5 y 6.
    habilitar_color(3) <=
        habilitar_categoria(5) or habilitar_categoria(6);

    G_COLORES : for indice in 1 to 3 generate

        U_COLOR : contador_ascendente
            generic map (
                ANCHO_BITS => 10
            )
            port map (
                reloj     => reloj,
                reinicio  => reinicio,
                habilitar => habilitar_color(indice),
                CUENTA    => colores(indice)
            );

    end generate G_COLORES;

    -- Selecciona el contador que se mostrara en el menu.
    process(seleccion, por_color, cantidades, colores)
    begin

        cantidad_seleccionada <= (others => '0');

        if por_color = '0' then

            case seleccion is
                when "001" =>
                    cantidad_seleccionada <= cantidades(1);

                when "010" =>
                    cantidad_seleccionada <= cantidades(2);

                when "011" =>
                    cantidad_seleccionada <= cantidades(3);

                when "100" =>
                    cantidad_seleccionada <= cantidades(4);

                when "101" =>
                    cantidad_seleccionada <= cantidades(5);

                when "110" =>
                    cantidad_seleccionada <= cantidades(6);

                when others =>
                    null;
            end case;

        else

            case seleccion is
                when "001" =>
                    cantidad_seleccionada <= colores(1);

                when "010" =>
                    cantidad_seleccionada <= colores(2);

                when "011" =>
                    cantidad_seleccionada <= colores(3);

                when others =>
                    null;
            end case;

        end if;

    end process;

    total <= cuenta_total;
    limite <= completa;

end architecture estructural;