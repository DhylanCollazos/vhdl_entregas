library ieee;
use ieee.std_logic_1164.all;

entity captura_pieza is
    generic (
        CICLOS_FILTRO : positive := 500000
    );
    port (
        reloj, reinicio, presencia_baja : in std_logic;

        color_selector : in std_logic_vector(1 downto 0);
        tamano_selector : in std_logic;

        nueva_pieza, presencia_activa : out std_logic;

        color : out std_logic_vector(1 downto 0);
        tamano : out std_logic
    );
end entity captura_pieza;

architecture estructural of captura_pieza is

    component sincronizador is
        generic (
            ANCHO_BITS : positive := 1
        );
        port (
            reloj, reinicio : in std_logic;
            entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
            salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
        );
    end component;

    signal boton, pulso_presencia, presente, libre_estable :
        std_logic;

    signal preparado, pendiente : std_logic := '0';

    signal entradas, estables, candidato :
        std_logic_vector(2 downto 0);

    signal cuenta_atributos :
        integer range 0 to CICLOS_FILTRO := 0;

begin

    boton <= not presencia_baja;
    entradas <= color_selector & tamano_selector;
    presencia_activa <= presente;

    U_SENSORES : sincronizador
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj,
            reinicio,
            entradas,
            estables
        );

    U_PRESENCIA : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj,
            reinicio,
            boton,
            pulso_presencia,
            presente
        );

    U_LIBERACION : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj,
            reinicio,
            presencia_baja,
            open,
            libre_estable
        );

    -- Estabiliza color y tamano como una sola palabra,
    -- no bit por bit.
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            candidato <= (others => '0');
            cuenta_atributos <= 0;

        elsif rising_edge(reloj) then

            if estables /= candidato then
                candidato <= estables;
                cuenta_atributos <= 0;

            elsif cuenta_atributos < CICLOS_FILTRO then
                cuenta_atributos <= cuenta_atributos + 1;
            end if;

        end if;
    end process;

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            preparado <= '0';
            pendiente <= '0';
            nueva_pieza <= '0';
            color <= "00";
            tamano <= '0';

        elsif rising_edge(reloj) then

            nueva_pieza <= '0';

            -- Tras un reinicio o una pieza, primero debe verse libre.
            if libre_estable = '1' then
                preparado <= '1';
                pendiente <= '0';

            elsif pulso_presencia = '1' and preparado = '1' then
                preparado <= '0';
                pendiente <= '1';

            elsif pendiente = '1' and presente = '1'
                  and cuenta_atributos = CICLOS_FILTRO
                  and estables = candidato then

                color <= candidato(2 downto 1);
                tamano <= candidato(0);
                nueva_pieza <= '1';
                pendiente <= '0';

            end if;

        end if;
    end process;

end architecture estructural;