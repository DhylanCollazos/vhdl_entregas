library ieee;
use ieee.std_logic_1164.all;

-- Testbench del codificador Morse.
-- Cada unidad de tiempo Morse se representa con cuatro ciclos.
-- Con un reloj de 20 ns:
-- Punto = 80 ns.
-- Raya  = 240 ns.
-- Pausa = 80 ns.

entity tb_morse_fsm is
    generic (
        G_TICKS_PRUEBA : positive := 4
    );
end entity tb_morse_fsm;


architecture prueba of tb_morse_fsm is

    constant T_RELOJ : time := 20 ns;

    constant T_UNIDAD : time :=
        G_TICKS_PRUEBA * T_RELOJ;

    signal CLOCK_50 : std_logic := '0';

    signal SW : std_logic_vector(2 downto 0) :=
        "000";

    signal KEY : std_logic_vector(1 downto 0) :=
        "11";

    signal LEDR : std_logic_vector(0 downto 0);

    signal terminado : boolean := false;

begin

    -- Instancia del circuito que se va a probar.
    dut : entity work.morse_fsm
        generic map (
            G_TICKS_05S => G_TICKS_PRUEBA
        )
        port map (
            CLOCK_50 => CLOCK_50,
            SW       => SW,
            KEY      => KEY,
            LEDR     => LEDR
        );


    -- Generacion del reloj.
    reloj : process
    begin

        while not terminado loop

            CLOCK_50 <= '0';
            wait for T_RELOJ / 2;

            CLOCK_50 <= '1';
            wait for T_RELOJ / 2;

        end loop;

        CLOCK_50 <= '0';
        wait;

    end process reloj;


    -- Aplicacion de entradas y comprobacion de resultados.
    estimulos : process

        procedure comprobar_reposo(
            constant tiempo : in time
        ) is
            variable inicio : time;
        begin

            assert LEDR(0) = '0'
                report "El LED no esta apagado en reposo"
                severity failure;

            inicio := now;

            wait on LEDR(0) for tiempo;

            assert LEDR(0) = '0' and now - inicio = tiempo
                report "Se detecto una transmision no solicitada"
                severity failure;

        end procedure;


        procedure iniciar(
            constant seleccion : in std_logic_vector(2 downto 0)
        ) is
        begin

            SW <= seleccion;
            KEY(1) <= '1';

            -- Permite que los interruptores se estabilicen.
            wait for 6 * T_RELOJ;

            KEY(1) <= '0';

            wait until LEDR(0) = '1' for 20 * T_RELOJ;

            assert LEDR(0) = '1'
                report "No inicio la transmision"
                severity failure;

        end procedure;


        procedure comprobar_patron(
            constant patron : in string
        ) is

            variable inicio   : time;
            variable esperado : time;

        begin

            for i in patron'range loop

                inicio := now;

                if patron(i) = '.' then
                    esperado := T_UNIDAD;
                else
                    esperado := 3 * T_UNIDAD;
                end if;

                wait until LEDR(0) = '0'
                    for 3 * T_UNIDAD + 5 * T_RELOJ;

                assert LEDR(0) = '0'
                    report "El pulso no termino: " & patron
                    severity failure;

                assert now - inicio = esperado
                    report
                        "Duracion incorrecta del simbolo " &
                        integer'image(i) &
                        " en " & patron &
                        ". Esperado: " & time'image(esperado) &
                        "; obtenido: " & time'image(now - inicio)
                    severity failure;

                if i /= patron'high then

                    inicio := now;

                    wait until LEDR(0) = '1'
                        for T_UNIDAD + 5 * T_RELOJ;

                    assert LEDR(0) = '1'
                        report "Falta un simbolo en " & patron
                        severity failure;

                    assert now - inicio = T_UNIDAD
                        report "Pausa incorrecta en " & patron
                        severity failure;

                end if;

            end loop;

        end procedure;


        procedure probar_letra(
            constant seleccion : in std_logic_vector(2 downto 0);
            constant nombre    : in string;
            constant patron    : in string
        ) is
        begin

            iniciar(seleccion);

            comprobar_patron(patron);

            -- KEY1 permanece presionado.
            -- La letra no debe repetirse.
            comprobar_reposo(5 * T_UNIDAD + 10 * T_RELOJ);

            KEY(1) <= '1';

            comprobar_reposo(6 * T_RELOJ);

            report
                "OK letra " & nombre & " patron=" & patron
                severity note;

        end procedure;


        procedure reset_fuera_del_flanco is
        begin

            -- Se invoca al empezar o terminar un pulso.
            -- El reset se aplica 5 ns despues, fuera del flanco.
            wait for T_RELOJ / 4;

            KEY(0) <= '0';
            KEY(1) <= '1';

            wait for 1 ns;

            assert LEDR(0) = '0'
                report "Fallo el reset asincrono"
                severity failure;

            wait for 2 * T_RELOJ + 3 ns;

            KEY(0) <= '1';

            comprobar_reposo(6 * T_RELOJ);

        end procedure;

    begin

        -- Reset inicial.
        KEY(0) <= '0';

        wait for 7 ns;

        assert LEDR(0) = '0'
            report "Fallo el reset inicial"
            severity failure;

        wait for 20 ns;

        KEY(0) <= '1';

        comprobar_reposo(6 * T_RELOJ);

        -- Pruebas de las ocho letras.
        probar_letra("000", "A", ".-");
        probar_letra("001", "B", "-...");
        probar_letra("010", "C", "-.-.");
        probar_letra("011", "D", "-..");
        probar_letra("100", "E", ".");
        probar_letra("101", "F", "..-.");
        probar_letra("110", "G", "--.");
        probar_letra("111", "H", "....");

        -- Cambiar SW durante la transmision no debe cambiar
        -- la letra que ya fue seleccionada.
        iniciar("001");

        SW <= "100";
        KEY(1) <= '1';

        comprobar_patron("-...");

        comprobar_reposo(5 * T_UNIDAD + 10 * T_RELOJ);

        report
            "OK seleccion capturada y liberacion de KEY1"
            severity note;

        -- Reset durante una raya.
        iniciar("110");

        reset_fuera_del_flanco;

        report
            "OK reset asincrono durante PULSO"
            severity note;

        -- Reset durante la pausa de A.
        iniciar("000");

        wait until LEDR(0) = '0'
            for T_UNIDAD + 5 * T_RELOJ;

        assert LEDR(0) = '0'
            report "No se alcanzo la pausa de A"
            severity failure;

        reset_fuera_del_flanco;

        report
            "OK reset asincrono durante PAUSA"
            severity note;

        -- Verifica que el circuito funcione despues del reset.
        probar_letra("100", "E despues de reset", ".");

        report
            "PRUEBAS COMPLETADAS SIN ERRORES"
            severity note;

        terminado <= true;

        wait;

    end process estimulos;


    -- Proteccion contra simulaciones que queden bloqueadas.
    vigilancia : process
    begin

        wait until terminado
            for 1000 * T_UNIDAD + 1000 * T_RELOJ;

        assert terminado
            report "Tiempo maximo de simulacion excedido"
            severity failure;

        wait;

    end process vigilancia;

end architecture prueba;