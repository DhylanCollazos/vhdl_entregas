library ieee;
use ieee.std_logic_1164.all;

entity SystemAlfa_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON :
            in std_logic_vector(2 downto 0);

        SW :
            in std_logic_vector(9 downto 0);

        LEDG :
            out std_logic_vector(9 downto 0);

        HEX0 :
            out std_logic_vector(6 downto 0);

        HEX1 :
            out std_logic_vector(6 downto 0);

        HEX2 :
            out std_logic_vector(6 downto 0);

        HEX3 :
            out std_logic_vector(6 downto 0)
    );
end entity SystemAlfa_Placa;

architecture estructural of SystemAlfa_Placa is

    component SystemAlfa_Final is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );
        port (
            RELOJ             : in std_logic;
            REINICIO_BAJO     : in std_logic;
            PRESENCIA         : in std_logic;
            CAMBIO_VELOCIDAD  : in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO :
                in std_logic;

            LINEA_MARCHA :
                in std_logic;

            VER_HISTORIAL :
                in std_logic;

            SIGUIENTE_HISTORIAL :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO :
                out std_logic;

            LINEA_ACTIVA :
                out std_logic;

            RUTA_PIEZA :
                out std_logic_vector(3 downto 0);

            ALARMA :
                out std_logic;

            LED_LIMITE :
                out std_logic;

            VISOR_0 :
                out std_logic_vector(6 downto 0);

            VISOR_1 :
                out std_logic_vector(6 downto 0);

            VISOR_2 :
                out std_logic_vector(6 downto 0);

            VISOR_3 :
                out std_logic_vector(6 downto 0)
        );
    end component;


    signal led_color :
        std_logic_vector(1 downto 0);

    signal led_tamano :
        std_logic;

    signal linea_activa :
        std_logic;

    signal ruta :
        std_logic_vector(3 downto 0);

    signal alarma :
        std_logic;

    signal limite :
        std_logic;

begin

    U_SYSTEM_ALFA : SystemAlfa_Final
        port map (
            RELOJ =>
                CLOCK_50,

            REINICIO_BAJO =>
                BUTTON(1),

            PRESENCIA =>
                BUTTON(0),

            CAMBIO_VELOCIDAD =>
                BUTTON(2),

            SELECTOR_COLOR =>
                SW(1 downto 0),

            SELECTOR_TAMANO =>
                SW(2),

            LINEA_MARCHA =>
                SW(3),

            VER_HISTORIAL =>
                SW(4),

            SIGUIENTE_HISTORIAL =>
                SW(5),

            LED_COLOR =>
                led_color,

            LED_TAMANO =>
                led_tamano,

            LINEA_ACTIVA =>
                linea_activa,

            RUTA_PIEZA =>
                ruta,

            ALARMA =>
                alarma,

            LED_LIMITE =>
                limite,

            VISOR_0 =>
                HEX0,

            VISOR_1 =>
                HEX1,

            VISOR_2 =>
                HEX2,

            VISOR_3 =>
                HEX3
        );


    ------------------------------------------------------------
    -- LEDS
    ------------------------------------------------------------

    LEDG(0) <= led_color(0);
    LEDG(1) <= led_color(1);

    LEDG(2) <= led_tamano;

    LEDG(3) <= linea_activa;

    LEDG(4) <= ruta(0);
    LEDG(5) <= ruta(1);
    LEDG(6) <= ruta(2);
    LEDG(7) <= ruta(3);

    LEDG(8) <= alarma;
    LEDG(9) <= limite;

end architecture estructural;