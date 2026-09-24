library ieee;
use ieee.std_logic_1164.all;

entity RF3_Clasificacion is
    generic (
        CICLOS_FILTRO : positive := 500000;
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO : in std_logic;

        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO : out std_logic;
        RUTA_PIEZA : out std_logic_vector(3 downto 0);
        ALARMA : out std_logic
    );
end entity RF3_Clasificacion;

architecture estructural of RF3_Clasificacion is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
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
    end component;

    component clasificador_ruta is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            aceptada : out std_logic
        );
    end component;

    component supervisor_error is
        generic (
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            reloj, reinicio, marcha, presencia_activa : in std_logic;
            nueva_pieza, pieza_valida : in std_logic;
            alarma : out std_logic
        );
    end component;

    signal reinicio_alto, nueva, presente, tamano, valida :
        std_logic;

    signal color : std_logic_vector(1 downto 0);
    signal ruta : std_logic_vector(3 downto 0);

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => presente,
            color            => color,
            tamano           => tamano
        );

    U_CLASIFICADOR : clasificador_ruta
        port map (
            color    => color,
            tamano   => tamano,
            ruta     => ruta,
            aceptada => valida
        );

    U_ERRORES : supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            marcha           => '1',
            presencia_activa => presente,
            nueva_pieza      => nueva,
            pieza_valida     => valida,
            alarma           => ALARMA
        );

    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            RUTA_PIEZA <= "0000";

        elsif rising_edge(RELOJ) then
            if nueva = '1' then
                RUTA_PIEZA <= ruta;
            end if;
        end if;
    end process;

    LED_COLOR <= color;
    LED_TAMANO <= tamano;

end architecture estructural;