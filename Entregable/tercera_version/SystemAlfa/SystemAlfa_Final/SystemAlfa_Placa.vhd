library ieee;
use ieee.std_logic_1164.all;

entity SystemAlfa_Placa is
    port (
        CLOCK_50 : in std_logic;

        BUTTON : in std_logic_vector(2 downto 0);
        SW : in std_logic_vector(9 downto 0);

        LEDG : out std_logic_vector(9 downto 0);

        HEX0, HEX1, HEX2, HEX3 :
            out std_logic_vector(6 downto 0)
    );
end entity SystemAlfa_Placa;

architecture estructural of SystemAlfa_Placa is

    component SystemAlfa_Final is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO : positive := 500000;
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA, CAMBIO_VELOCIDAD :
                in std_logic;

            SELECTOR_COLOR : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO, LINEA_MARCHA : in std_logic;

            VER_HISTORIAL, SIGUIENTE_HISTORIAL : in std_logic;
            SELECCION_HISTORIAL, VER_CANTIDADES : in std_logic;
            IR_ULTIMO, CONTAR_POR_COLOR : in std_logic;

            LED_COLOR : out std_logic_vector(1 downto 0);
            LED_TAMANO, LINEA_ACTIVA : out std_logic;
            RUTA_PIEZA : out std_logic_vector(3 downto 0);
            ALARMA, LED_LIMITE : out std_logic;

            VISOR_0, VISOR_1, VISOR_2, VISOR_3 :
                out std_logic_vector(6 downto 0)
        );
    end component;

    signal color : std_logic_vector(1 downto 0);
    signal tamano, linea, alarma, limite : std_logic;
    signal categoria : std_logic_vector(3 downto 0);

begin

    U_SISTEMA : SystemAlfa_Final
        port map (
            RELOJ => CLOCK_50,
            REINICIO_BAJO => BUTTON(1),
            PRESENCIA => BUTTON(0),
            CAMBIO_VELOCIDAD => BUTTON(2),

            SELECTOR_COLOR => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),
            LINEA_MARCHA => SW(3),

            VER_HISTORIAL => SW(4),
            SIGUIENTE_HISTORIAL => SW(5),
            SELECCION_HISTORIAL => SW(6),
            VER_CANTIDADES => SW(7),
            IR_ULTIMO => SW(8),
            CONTAR_POR_COLOR => SW(9),

            LED_COLOR => color,
            LED_TAMANO => tamano,
            LINEA_ACTIVA => linea,
            RUTA_PIEZA => categoria,
            ALARMA => alarma,
            LED_LIMITE => limite,

            VISOR_0 => HEX0,
            VISOR_1 => HEX1,
            VISOR_2 => HEX2,
            VISOR_3 => HEX3
        );

    LEDG(1 downto 0) <= color;
    LEDG(2) <= tamano;
    LEDG(3) <= linea;
    LEDG(7 downto 4) <= categoria;
    LEDG(8) <= alarma;
    LEDG(9) <= limite;

end architecture estructural;