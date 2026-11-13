library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF1_Transporte_TB is
end entity RF1_Transporte_TB;

architecture RF1_Transporte_TB_arch of RF1_Transporte_TB is

    component RF1_Transporte is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000
        );
        port (
            RELOJ, REINICIO_BAJO,
            CAMBIO_VELOCIDAD, LINEA_MARCHA : in std_logic;

            VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
            LINEA_ACTIVA    : out std_logic
        );
    end component;

    signal RELOJ_TB            : std_logic := '0';
    signal REINICIO_BAJO_TB    : std_logic := '0';
    signal CAMBIO_VELOCIDAD_TB : std_logic := '1';
    signal LINEA_MARCHA_TB     : std_logic := '1';

    signal VISOR_VELOCIDAD_TB :
        std_logic_vector(6 downto 0);

    signal LINEA_ACTIVA_TB : std_logic;

    signal FIN_TB : boolean := false;

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", "1111001", "0100100", "0110000",
        "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011",
        "1000110", "0100001", "0000110", "0001110"
    );

begin

    -- Reloj de 50 MHz.
    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF1_Transporte
        generic map (
            FRECUENCIA_RELOJ_HZ => 60,
            CICLOS_FILTRO       => 3
        )
        port map (
            RELOJ            => RELOJ_TB,
            REINICIO_BAJO    => REINICIO_BAJO_TB,
            CAMBIO_VELOCIDAD => CAMBIO_VELOCIDAD_TB,
            LINEA_MARCHA     => LINEA_MARCHA_TB,
            VISOR_VELOCIDAD  => VISOR_VELOCIDAD_TB,
            LINEA_ACTIVA     => LINEA_ACTIVA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

    begin

        -- Reinicio.
        esperar(4);
        REINICIO_BAJO_TB <= '1';

        -- Aunque SW3 estaba en 1, no debe arrancar sola.
        for i in 1 to 160 loop
            esperar;

            assert LINEA_ACTIVA_TB = '0'
                report "Arranque automatico tras reset"
                severity failure;
        end loop;

        assert VISOR_VELOCIDAD_TB = PATRONES(0)
            report "Velocidad inicial distinta de cero"
            severity failure;

        -- Rearme: marcha debe pasar por cero.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        LINEA_MARCHA_TB <= '1';

        wait until LINEA_ACTIVA_TB = '1' for 2 us;

        assert LINEA_ACTIVA_TB = '1'
            report "La linea no arranco"
            severity failure;

        -- Probar los cuatro niveles.
        for i in 1 to 4 loop

            CAMBIO_VELOCIDAD_TB <= '0';
            esperar(10);

            assert VISOR_VELOCIDAD_TB = PATRONES(i mod 4)
                report "Nivel de velocidad incorrecto"
                severity failure;

            -- Mantener el boton no debe cambiar otra vez.
            esperar(25);

            assert VISOR_VELOCIDAD_TB = PATRONES(i mod 4)
                report "Una pulsacion produjo varios cambios"
                severity failure;

            CAMBIO_VELOCIDAD_TB <= '1';
            esperar(10);

        end loop;

        -- Parada.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        for i in 1 to 100 loop
            esperar;

            assert LINEA_ACTIVA_TB = '0'
                report "La linea no permanece detenida"
                severity failure;
        end loop;

        report "OK: RF1_Transporte_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF1_Transporte_TB_arch;