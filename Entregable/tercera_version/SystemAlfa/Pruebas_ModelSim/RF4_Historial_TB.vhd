library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF4_Historial_TB is
end entity RF4_Historial_TB;

architecture RF4_Historial_TB_arch
of RF4_Historial_TB is

    component RF4_Historial is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO,
            VER_HISTORIAL,
            SIGUIENTE_HISTORIAL :
                in std_logic;

            VISOR_TOTAL,
            VISOR_TOTAL_ALTO :
                out std_logic_vector(6 downto 0);

            TIEMPO_HISTORIAL_ALTO,
            TIEMPO_HISTORIAL_BAJO :
                out std_logic_vector(6 downto 0);

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO,
            LED_REGISTRO_VALIDO,
            LED_REGLA_VALIDA,
            LED_LIMITE :
                out std_logic;

            RUTA_REGLA :
                out std_logic_vector(3 downto 0)
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal VER_HISTORIAL_TB :
        std_logic := '0';

    signal SIGUIENTE_HISTORIAL_TB :
        std_logic := '0';

    signal VISOR_TOTAL_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_TOTAL_ALTO_TB :
        std_logic_vector(6 downto 0);

    signal TIEMPO_HISTORIAL_ALTO_TB :
        std_logic_vector(6 downto 0);

    signal TIEMPO_HISTORIAL_BAJO_TB :
        std_logic_vector(6 downto 0);

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal LED_REGISTRO_VALIDO_TB :
        std_logic;

    signal LED_REGLA_VALIDA_TB :
        std_logic;

    signal LED_LIMITE_TB :
        std_logic;

    signal RUTA_REGLA_TB :
        std_logic_vector(3 downto 0);

    signal FIN_TB :
        boolean := false;

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", "1111001", "0100100", "0110000",
        "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011",
        "1000110", "0100001", "0000110", "0001110"
    );

    function leer_hex(
        s : std_logic_vector(6 downto 0)
    ) return integer is
    begin

        for i in 0 to 15 loop
            if s = PATRONES(i) then
                return i;
            end if;
        end loop;

        return -1;

    end function;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF4_Historial
        generic map (
            FRECUENCIA_RELOJ_HZ => 1000,
            CICLOS_FILTRO       => 3
        )
        port map (
            RELOJ                  => RELOJ_TB,
            REINICIO_BAJO          => REINICIO_BAJO_TB,
            PRESENCIA              => PRESENCIA_TB,
            SELECTOR_COLOR         => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO        => SELECTOR_TAMANO_TB,
            VER_HISTORIAL          => VER_HISTORIAL_TB,
            SIGUIENTE_HISTORIAL    => SIGUIENTE_HISTORIAL_TB,
            VISOR_TOTAL            => VISOR_TOTAL_TB,
            VISOR_TOTAL_ALTO       => VISOR_TOTAL_ALTO_TB,
            TIEMPO_HISTORIAL_ALTO  => TIEMPO_HISTORIAL_ALTO_TB,
            TIEMPO_HISTORIAL_BAJO  => TIEMPO_HISTORIAL_BAJO_TB,
            LED_COLOR              => LED_COLOR_TB,
            LED_TAMANO             => LED_TAMANO_TB,
            LED_REGISTRO_VALIDO    => LED_REGISTRO_VALIDO_TB,
            LED_REGLA_VALIDA       => LED_REGLA_VALIDA_TB,
            LED_LIMITE             => LED_LIMITE_TB,
            RUTA_REGLA             => RUTA_REGLA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure ingresar(id : positive) is
        begin

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned(((id - 1) mod 6) / 2 + 1, 2)
                );

            if id mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '1';
            else
                SELECTOR_TAMANO_TB <= '0';
            end if;

            esperar(8);

            PRESENCIA_TB <= '0';
            esperar(10);

            PRESENCIA_TB <= '1';
            esperar(10);

        end procedure;

        procedure avanzar is
        begin
            SIGUIENTE_HISTORIAL_TB <= '1';
            esperar(10);

            SIGUIENTE_HISTORIAL_TB <= '0';
            esperar(10);
        end procedure;

    begin

        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(12);

        -- Historial inicialmente vacío.
        VER_HISTORIAL_TB <= '1';
        esperar(5);

        assert LED_REGISTRO_VALIDO_TB = '0'
            report "Historial no inicia vacio"
            severity failure;

        VER_HISTORIAL_TB <= '0';
        esperar(5);

        -- Registrar dos piezas.
        ingresar(1);
        ingresar(2);

        VER_HISTORIAL_TB <= '1';
        esperar(5);

        assert LED_REGISTRO_VALIDO_TB = '1'
            report "No se recupero el primer registro"
            severity failure;

        avanzar;

        assert LED_REGISTRO_VALIDO_TB = '1'
            report "No se recupero el segundo registro"
            severity failure;

        report "OK: RF4_Historial_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF4_Historial_TB_arch;