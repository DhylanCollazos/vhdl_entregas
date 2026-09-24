library ieee;
use ieee.std_logic_1164.all;

entity RF1_Placa is
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
end entity RF1_Placa;

architecture estructural of RF1_Placa is

    component RF1_Transporte is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ             : in std_logic;
            REINICIO_BAJO     : in std_logic;
            CAMBIO_VELOCIDAD  : in std_logic;
            LINEA_MARCHA      : in std_logic;

            VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
            LINEA_ACTIVA    : out std_logic
        );
    end component;

    signal visor_velocidad : std_logic_vector(6 downto 0);
    signal linea_activa    : std_logic;

begin

    U_RF1 : RF1_Transporte
        port map (
            RELOJ            => CLOCK_50,
            REINICIO_BAJO    => BUTTON(1),
            CAMBIO_VELOCIDAD => BUTTON(2),
            LINEA_MARCHA     => SW(3),

            VISOR_VELOCIDAD => visor_velocidad,
            LINEA_ACTIVA    => linea_activa
        );

    LEDG(2 downto 0) <= (others => '0');
    LEDG(3) <= linea_activa;
    LEDG(9 downto 4) <= (others => '0');

    HEX0 <= "1111111";
    HEX1 <= visor_velocidad;
    HEX2 <= "1111111";
    HEX3 <= "1111111";

end architecture estructural;