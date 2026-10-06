library ieee;
use ieee.std_logic_1164.all;

entity RF2_Inspeccion is
    generic (
        CICLOS_FILTRO : positive := 500000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO : in std_logic;

        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO, LED_PIEZA : out std_logic
    );
end entity RF2_Inspeccion;

architecture estructural of RF2_Inspeccion is

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

    signal reinicio_alto, nueva : std_logic;

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
            presencia_activa => open,
            color            => LED_COLOR,
            tamano           => LED_TAMANO
        );

    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            LED_PIEZA <= '0';

        elsif rising_edge(RELOJ) then
            if nueva = '1' then
                LED_PIEZA <= '1';
            end if;
        end if;
    end process;

end architecture estructural;