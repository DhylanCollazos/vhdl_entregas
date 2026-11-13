library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Final_TB is
end entity;

architecture prueba of SystemAlfa_Final_TB is
    signal reloj : std_logic := '0';
    signal reinicio_bajo : std_logic := '0';
    signal presencia, velocidad : std_logic := '1';
    signal color : std_logic_vector(1 downto 0) := "00";
    signal tamano : std_logic := '0';
    signal marcha : std_logic := '1';
    signal menu, siguiente, ver_tiempo, cantidades : std_logic := '0';
    signal ultimo, por_color : std_logic := '0';
    signal led_color : std_logic_vector(1 downto 0);
    signal led_tamano, linea, alarma, limite : std_logic;
    signal ruta : std_logic_vector(3 downto 0);
    signal h0, h1, h2, h3 : std_logic_vector(6 downto 0);
    signal fin : boolean := false;

    type tabla is array(0 to 9) of std_logic_vector(6 downto 0);

    constant patrones : tabla := (
        "1000000", "1111001", "0100100", "0110000", "0011001",
        "0010010", "0000010", "1111000", "0000000", "0010000"
    );

    function digito(s : std_logic_vector(6 downto 0))
        return integer is
    begin
        for i in 0 to 9 loop
            if s = patrones(i) then
                return i;
            end if;
        end loop;
        return -1;
    end function;

    function decimal(c, d, u : std_logic_vector(6 downto 0))
        return integer is
    begin
        if digito(c) < 0 or digito(d) < 0 or digito(u) < 0 then
            return -1;
        end if;
        return 100*digito(c) + 10*digito(d) + digito(u);
    end function;

begin

    reloj <= not reloj after 10 ns when not fin else '0';

    DUT : entity work.SystemAlfa_Final
        generic map (
            FRECUENCIA_RELOJ_HZ => 1000,
            CICLOS_FILTRO => 3,
            CICLOS_ATASCO => 10000
        )
        port map (
            RELOJ => reloj,
            REINICIO_BAJO => reinicio_bajo,
            PRESENCIA => presencia,
            CAMBIO_VELOCIDAD => velocidad,
            SELECTOR_COLOR => color,
            SELECTOR_TAMANO => tamano,
            LINEA_MARCHA => marcha,
            VER_HISTORIAL => menu,
            SIGUIENTE_HISTORIAL => siguiente,
            SELECCION_HISTORIAL => ver_tiempo,
            VER_CANTIDADES => cantidades,
            IR_ULTIMO => ultimo,
            CONTAR_POR_COLOR => por_color,
            LED_COLOR => led_color,
            LED_TAMANO => led_tamano,
            LINEA_ACTIVA => linea,
            RUTA_PIEZA => ruta,
            ALARMA => alarma,
            LED_LIMITE => limite,
            VISOR_0 => h0,
            VISOR_1 => h1,
            VISOR_2 => h2,
            VISOR_3 => h3, MARCHA_FISICA => open, EVENTO_VALIDO => open, NIVEL_FISICO => open, CATEGORIA_FISICA => open
        );

    estimulos : process
        variable tiempo_antes : integer;

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(reloj);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure comprobar(n : natural) is
        begin
            -- Esperar la conversion decimal registrada (maximo 22 ciclos).
            esperar(24);
            assert decimal(h2, h1, h0) = n
                report "Valor decimal incorrecto: " & integer'image(n)
                severity failure;
        end procedure;

        procedure pulsar(signal mando : out std_logic) is
        begin
            mando <= '1';
            esperar(15);
            mando <= '0';
            esperar(15);
        end procedure;

        procedure ingresar(c : natural; t : std_logic) is
        begin
            color <= std_logic_vector(to_unsigned(c, 2));
            tamano <= t;
            esperar(15);

            presencia <= '0';
            esperar(20);

            presencia <= '1';
            esperar(20);
        end procedure;

        procedure reset_operativo(ciclos : positive := 5) is
        begin
            reinicio_bajo <= '0';
            esperar(ciclos);

            assert linea = '0' and alarma = '0'
                report "Reset no limpia linea/alarma"
                severity failure;

            reinicio_bajo <= '1';
            esperar(20);
        end procedure;

        procedure comprobar_marcha is
            variable encendido : boolean := false;
            variable apagado : boolean := false;
        begin
            -- Observar varios instantes: el LED parpadea.
            for i in 1 to 1100 loop
                esperar;

                if linea = '1' then
                    encendido := true;
                end if;

                if linea = '0' then
                    apagado := true;
                end if;
            end loop;

            assert encendido and apagado
                report "La cinta no parpadea con SW3 alto"
                severity failure;
        end procedure;

        procedure comprobar_cantidades(extra_rojo : natural := 0) is
        begin
            menu <= '1';
            cantidades <= '1';
            por_color <= '0';
            esperar(20);

            for i in 1 to 6 loop
                assert digito(h3) = i
                    report "Seleccion de categoria incorrecta"
                    severity failure;

                if i = 1 then
                    comprobar(i + extra_rojo);
                else
                    comprobar(i);
                end if;

                pulsar(siguiente);
            end loop;

            por_color <= '1';
            esperar(20);

            comprobar(3 + extra_rojo);
            pulsar(siguiente);
            comprobar(7);
            pulsar(siguiente);
            comprobar(11);

            cantidades <= '0';
            por_color <= '0';
            esperar(20);
        end procedure;

    begin

        reset_operativo;
        comprobar(0);
        comprobar_marcha;

        -- Rechazo con historial vacio: no debe crear el ID 1.
        ingresar(0, '0');
        comprobar(0);

        assert alarma = '1' and ruta = "1000"
            report "No indica el rechazo"
            severity failure;

        menu <= '1';
        esperar(20);

        assert h0 = "1111111" and h1 = "1111111" and
               h2 = "1111111" and h3 = "1111111"
            report "Se guardo una pieza invalida en historial vacio"
            severity failure;

        menu <= '0';
        reset_operativo;

        -- 1+2+3+4+5+6 = 21 piezas validas.
        for categoria in 1 to 6 loop
            for i in 1 to categoria loop
                if categoria mod 2 = 0 then
                    ingresar((categoria+1)/2, '1');
                else
                    ingresar((categoria+1)/2, '0');
                end if;
            end loop;
        end loop;

        comprobar(21);

        assert h3 = patrones(0)
            report "Se esperaba 0021"
            severity failure;

        comprobar_cantidades;

        comprobar(21);
        pulsar(siguiente);
        comprobar(14);
        pulsar(ultimo);
        comprobar(21);

        ver_tiempo <= '1';
        esperar(40);
        tiempo_antes := decimal(h2, h1, h0);

        ver_tiempo <= '0';
        menu <= '0';
        esperar(20);

        -- Ninguno de los dos rechazos ocupa ID ni RAM.
        for t in 0 to 1 loop

            if t = 0 then
                ingresar(0, '0');
            else
                ingresar(0, '1');
            end if;

            comprobar(21);

            assert alarma = '1' and linea = '0'
                report "Rechazo no detiene la cinta"
                severity failure;

            menu <= '1';
            esperar(20);
            comprobar(21);

            assert led_color = "11" and led_tamano = '1'
                report "El rechazo sobrescribio la ultima pieza valida"
                severity failure;

            pulsar(siguiente);
            comprobar(14);

            pulsar(ultimo);
            comprobar(21);

            comprobar_cantidades;

            ver_tiempo <= '1';
            esperar(40);

            assert decimal(h2, h1, h0) = tiempo_antes
                report "El rechazo altero el tiempo guardado"
                severity failure;

            ver_tiempo <= '0';
            menu <= '0';

            reset_operativo;
            comprobar(21);

            -- Debe funcionar sin mover SW3.
            comprobar_marcha;

        end loop;

        -- Reset largo: conservar datos y seguir contando tiempo.
        reset_operativo(2200);
        comprobar(21);
        comprobar_marcha;

        ingresar(1, '0');
        comprobar(22);

        menu <= '1';
        esperar(20);

        -- La siguiente pieza valida recibe ID 22, sin saltos.
        comprobar(22);

        ver_tiempo <= '1';
        esperar(40);

        assert decimal(h2, h1, h0) >= tiempo_antes + 2
            report "Reset borro o detuvo el tiempo"
            severity failure;

        ver_tiempo <= '0';
        comprobar_cantidades(1);

        menu <= '0';
        esperar(20);

        -- SW3 bajo debe mantener la cinta detenida tras reset.
        marcha <= '0';
        esperar(20);
        reset_operativo;

        for i in 1 to 600 loop
            esperar;

            assert linea = '0'
                report "Marcha con SW3 bajo"
                severity failure;
        end loop;

        ingresar(2, '0');
        comprobar(22);

        menu <= '1';
        esperar(20);
        comprobar(22);

        report "OK: SystemAlfa_Final_TB" severity note;

        fin <= true;
        wait;

    end process;

end architecture;
