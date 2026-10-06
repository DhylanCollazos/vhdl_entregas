library ieee;
use ieee.std_logic_1164.all;

entity RF4_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW     : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end entity RF4_Placa;

architecture estructural of RF4_Placa is

    component RF4_Historial is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ         : in std_logic;
            REINICIO_BAJO : in std_logic;
            PRESENCIA     : in std_logic;

            SELECTOR_COLOR  : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO : in std_logic;

            VER_HISTORIAL       : in std_logic;
            SIGUIENTE_HISTORIAL : in std_logic;

            VISOR_TOTAL      : out std_logic_vector(6 downto 0);
            VISOR_TOTAL_ALTO : out std_logic_vector(6 downto 0);

            TIEMPO_HISTORIAL_ALTO :
                out std_logic_vector(6 downto 0);

            TIEMPO_HISTORIAL_BAJO :
                out std_logic_vector(6 downto 0);

            LED_COLOR : out std_logic_vector(1 downto 0);

            LED_TAMANO           : out std_logic;
            LED_REGISTRO_VALIDO  : out std_logic;
            LED_REGLA_VALIDA     : out std_logic;
            LED_LIMITE           : out std_logic;

            RUTA_REGLA : out std_logic_vector(3 downto 0)
        );
    end component;

    signal led_color : std_logic_vector(1 downto 0);

    signal led_tamano          : std_logic;
    signal registro_valido     : std_logic;
    signal regla_valida        : std_logic;
    signal limite              : std_logic;

    signal ruta_regla :
        std_logic_vector(3 downto 0);

    signal visor_total :
        std_logic_vector(6 downto 0);

    signal visor_total_alto :
        std_logic_vector(6 downto 0);

    signal tiempo_bajo :
        std_logic_vector(6 downto 0);

    signal tiempo_alto :
        std_logic_vector(6 downto 0);

begin

    U_RF4 : RF4_Historial
        port map (
            RELOJ         => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA     => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            VER_HISTORIAL       => SW(4),
            SIGUIENTE_HISTORIAL => SW(5),

            VISOR_TOTAL      => visor_total,
            VISOR_TOTAL_ALTO => visor_total_alto,

            TIEMPO_HISTORIAL_ALTO => tiempo_alto,
            TIEMPO_HISTORIAL_BAJO => tiempo_bajo,

            LED_COLOR => led_color,

            LED_TAMANO          => led_tamano,
            LED_REGISTRO_VALIDO => registro_valido,
            LED_REGLA_VALIDA    => regla_valida,
            LED_LIMITE          => limite,

            RUTA_REGLA => ruta_regla
        );

    LEDG(1 downto 0) <= led_color;
    LEDG(2) <= led_tamano;
    LEDG(3) <= registro_valido;

    LEDG(7 downto 4) <= ruta_regla;

    LEDG(8) <= regla_valida;
    LEDG(9) <= limite;

    HEX0 <= visor_total;
    HEX1 <= visor_total_alto;
    HEX2 <= tiempo_bajo;
    HEX3 <= tiempo_alto;

end architecture estructural;