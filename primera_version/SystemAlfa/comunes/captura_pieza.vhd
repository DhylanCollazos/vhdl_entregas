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

    component registro_color is
        port (
            reloj, reinicio, HABILITAR : in std_logic;
            color_entrada : in std_logic_vector(1 downto 0);
            color_salida : out std_logic_vector(1 downto 0)
        );
    end component;

    component registro_tamano is
        port (
            reloj, reinicio, HABILITAR, tamano_entrada :
                in std_logic;
            tamano_salida : out std_logic
        );
    end component;

    signal boton, capturar : std_logic;
    signal entradas, estables : std_logic_vector(2 downto 0);

begin

    boton <= not presencia_baja;
    entradas <= color_selector & tamano_selector;

    U_SENSORES : sincronizador
        generic map (
            ANCHO_BITS => 3
        )
        port map (
            reloj    => reloj,
            reinicio => reinicio,
            entrada  => entradas,
            salida   => estables
        );

    U_PRESENCIA : filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj         => reloj,
            reinicio      => reinicio,
            boton_entrada => boton,
            pulso_salida  => capturar,
            estado_salida => presencia_activa
        );

    U_COLOR : registro_color
        port map (
            reloj         => reloj,
            reinicio      => reinicio,
            HABILITAR     => capturar,
            color_entrada => estables(2 downto 1),
            color_salida  => color
        );

    U_TAMANO : registro_tamano
        port map (
            reloj          => reloj,
            reinicio       => reinicio,
            HABILITAR      => capturar,
            tamano_entrada => estables(0),
            tamano_salida  => tamano
        );

    -- El aviso se entrega despues de capturar los atributos.
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            nueva_pieza <= '0';

        elsif rising_edge(reloj) then
            nueva_pieza <= capturar;
        end if;
    end process;

end architecture estructural;