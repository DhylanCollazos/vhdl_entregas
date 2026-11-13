library ieee;
use ieee.std_logic_1164.all;

entity RF2_Placa is
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
end entity RF2_Placa;

architecture estructural of RF2_Placa is

    component RF2_Inspeccion is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            RELOJ          : in std_logic;
            REINICIO_BAJO  : in std_logic;
            PRESENCIA      : in std_logic;

            SELECTOR_COLOR  : in std_logic_vector(1 downto 0);
            SELECTOR_TAMANO : in std_logic;

            LED_COLOR  : out std_logic_vector(1 downto 0);
            LED_TAMANO : out std_logic;
            LED_PIEZA  : out std_logic
        );
    end component;

    signal led_color  : std_logic_vector(1 downto 0);
    signal led_tamano : std_logic;
    signal led_pieza  : std_logic;

begin

    U_RF2 : RF2_Inspeccion
        port map (
            RELOJ          => CLOCK_50,
            REINICIO_BAJO  => BUTTON(1),
            PRESENCIA      => BUTTON(0),

            SELECTOR_COLOR  => SW(1 downto 0),
            SELECTOR_TAMANO => SW(2),

            LED_COLOR  => led_color,
            LED_TAMANO => led_tamano,
            LED_PIEZA  => led_pieza
        );

    LEDG(1 downto 0) <= led_color;
    LEDG(2) <= led_tamano;
    LEDG(3) <= led_pieza;
    LEDG(9 downto 4) <= (others => '0');

    HEX0 <= "1111111";
    HEX1 <= "1111111";
    HEX2 <= "1111111";
    HEX3 <= "1111111";

end architecture estructural;