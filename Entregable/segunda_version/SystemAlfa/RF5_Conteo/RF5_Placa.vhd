library ieee;
use ieee.std_logic_1164.all;

entity RF5_Placa is
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
end entity RF5_Placa;

architecture estructural of RF5_Placa is

    component RF5_Conteo is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );
        port (
            RELOJ         : in std_logic;
            REINICIO_BAJO : in std_logic;
            PRESENCIA     : in std_logic;

            SELECTOR_COLOR : in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO    : in std_logic;
            CAMBIO_VELOCIDAD   : in std_logic;
            LINEA_MARCHA       : in std_logic;

            VISOR_TOTAL       : out std_logic_vector(6 downto 0);
            VISOR_TOTAL_MEDIO : out std_logic_vector(6 downto 0);
            VISOR_TOTAL_ALTO  : out std_logic_vector(6 downto 0);

            VISOR_VELOCIDAD :
                out std_logic_vector(6 downto 0);

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO   : out std_logic;
            LINEA_ACTIVA : out std_logic;
            LED_RECHAZO  : out std_logic;
            ALARMA       : out std_logic;
            LED_LIMITE   : out std_logic
        );
    end component;

    signal visor_total :
        std_logic_vector(6 downto 0);

    signal visor_total_medio :
        std_logic_vector(6 downto 0);

    signal visor_total_alto :
        std_logic_vector(6 downto 0);

    signal visor_velocidad :
        std_logic_vector(6 downto 0);

    signal led_color :
        std_logic_vector(1 downto 0);

    signal led_tamano   : std_logic;
    signal linea_activa : std_logic;
    signal led_rechazo  : std_logic;
    signal alarma       : std_logic;
    signal limite       : std_logic;

begin

    U_RF5 : RF5_Conteo
        port map (
            RELOJ         => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA     => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            CAMBIO_VELOCIDAD => BUTTON(2),
            LINEA_MARCHA     => SW(3),

            VISOR_TOTAL       => visor_total,
            VISOR_TOTAL_MEDIO => visor_total_medio,
            VISOR_TOTAL_ALTO  => visor_total_alto,

            VISOR_VELOCIDAD => visor_velocidad,

            LED_COLOR => led_color,

            LED_TAMANO   => led_tamano,
            LINEA_ACTIVA => linea_activa,
            LED_RECHAZO  => led_rechazo,
            ALARMA       => alarma,
            LED_LIMITE   => limite
        );

    LEDG(1 downto 0) <= led_color;

    LEDG(2) <= led_tamano;
    LEDG(3) <= linea_activa;
    LEDG(4) <= led_rechazo;

    LEDG(7 downto 5) <= (others => '0');

    LEDG(8) <= alarma;
    LEDG(9) <= limite;

    HEX0 <= visor_total;
    HEX1 <= visor_velocidad;
    HEX2 <= visor_total_medio;
    HEX3 <= visor_total_alto;

end architecture estructural;