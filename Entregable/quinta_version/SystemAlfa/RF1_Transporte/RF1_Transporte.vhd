library ieee;
use ieee.std_logic_1164.all;

entity RF1_Transporte is
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
end entity RF1_Transporte;

architecture estructural of RF1_Transporte is

    component reinicio_seguro is
        port (
            reloj           : in std_logic;
            reinicio_bajo   : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component selector_velocidad is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            reloj        : in std_logic;
            reinicio     : in std_logic;
            boton_bajo   : in std_logic;

            nivel_salida : out std_logic_vector(1 downto 0);
            pulso_linea  : out std_logic;
            segmentos    : out std_logic_vector(6 downto 0)
        );
    end component;

    component control_linea is
        port (
            reloj               : in std_logic;
            reinicio            : in std_logic;
            marcha              : in std_logic;
            bloqueo             : in std_logic;
            pulso_linea_entrada : in std_logic;

            pulso_motor : out std_logic;
            led_linea   : out std_logic;
            en_marcha   : out std_logic
        );
    end component;

    signal reinicio_alto : std_logic;
    signal pulso_linea   : std_logic;

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_VELOCIDAD : selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO       => CICLOS_FILTRO
        )
        port map (
            reloj        => RELOJ,
            reinicio     => reinicio_alto,
            boton_bajo   => CAMBIO_VELOCIDAD,
            nivel_salida => open,
            pulso_linea  => pulso_linea,
            segmentos    => VISOR_VELOCIDAD
        );

    U_LINEA : control_linea
        port map (
            reloj                => RELOJ,
            reinicio             => reinicio_alto,
            marcha               => LINEA_MARCHA,
            bloqueo              => '0',
            pulso_linea_entrada  => pulso_linea,

            pulso_motor => open,
            led_linea   => LINEA_ACTIVA,
            en_marcha   => open
        );

end architecture estructural;