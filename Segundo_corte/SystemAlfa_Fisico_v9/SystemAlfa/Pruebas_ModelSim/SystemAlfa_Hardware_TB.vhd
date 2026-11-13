library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity SystemAlfa_Hardware_TB is end;
architecture prueba of SystemAlfa_Hardware_TB is
    signal reloj:std_logic:='0';signal terminado:boolean:=false;
    signal presencia:std_logic:='1';signal echo,trig,tcs_out,s0,s1,s2,s3:std_logic:='0';
    signal botones:std_logic_vector(2 downto 0):="111";
    signal sw:std_logic_vector(9 downto 0):=(others=>'0');
    signal leds:std_logic_vector(9 downto 0);
    signal h0,h1,h2,h3,extv,extc:std_logic_vector(6 downto 0);
    signal pwm,in1,in2,servo1,servo2:std_logic;
    signal cats:std_logic_vector(3 downto 0);
    signal muestra:integer range 0 to 3:=1;
    signal ancho_echo:time:=232 us;
    signal responder:boolean:=true;
    function segmento(n:integer) return std_logic_vector is
    begin
        case n is
            when 0=>return "1000000";when 1=>return "1111001";when 2=>return "0100100";
            when 3=>return "0110000";when 4=>return "0011001";when 5=>return "0010010";
            when 6=>return "0000010";when 7=>return "1111000";when 8=>return "0000000";
            when 9=>return "0010000";when others=>return "1111111";
        end case;
    end;
begin
    reloj<=not reloj after 500 ns when not terminado else '0';
    U:entity work.SystemAlfa_Hardware
        generic map(FRECUENCIA_RELOJ_HZ=>1000000,CICLOS_FILTRO=>3,CICLOS_PRESENCIA=>3,CICLOS_TICK=>1000,
                    VENTANA_COLOR=>3000,ASENTAR_COLOR=>50,CICLOS_PWM_MOTOR=>100,CICLOS_US_SERVO=>1,INTERVALO_HC_US=>6100)
        port map(reloj,presencia,echo,tcs_out,trig,s0,s1,s2,s3,botones,sw,leds,h0,h1,h2,h3,
                 pwm,in1,in2,servo1,servo2,cats,extv,extc);
    -- Modelo electrico HC: eco proporcional a distancia, independiente del VHDL.
    process
    begin
        wait until falling_edge(trig);
        if responder then wait for 100 us;echo<='1';wait for ancho_echo;echo<='0';end if;
    end process;
    -- Emite los conteos aproximados de calibracion en ventanas de 3 ms.
    process
        variable pulsos:positive;variable filtro:std_logic_vector(1 downto 0);
    begin
        filtro:=s2&s3;
        case muestra is
            when 1=>case filtro is when "00"=>pulsos:=64;when "11"=>pulsos:=29;when others=>pulsos:=39;end case;
            when 2=>case filtro is when "00"=>pulsos:=35;when "11"=>pulsos:=55;when others=>pulsos:=44;end case;
            when 3=>case filtro is when "00"=>pulsos:=29;when "11"=>pulsos:=33;when others=>pulsos:=58;end case;
            when others=>case filtro is when "00"=>pulsos:=121;when "11"=>pulsos:=101;when others=>pulsos:=105;end case;
        end case;
        tcs_out<='0';wait for 1500 us/pulsos;tcs_out<='1';wait for 1500 us/pulsos;
    end process;
    process
        procedure pulsar(n:integer) is
        begin botones(n)<='0';wait for 25 us;botones(n)<='1';wait for 25 us;end;
        procedure pagina(p:integer;v:integer:=0) is
        begin
            sw(3)<='0';wait for 60 us;
            sw(0)<='1';sw(9 downto 4)<=std_logic_vector(to_unsigned(p,6));
            sw(2 downto 1)<=std_logic_vector(to_unsigned(v,2));wait for 60 us;
        end;
        procedure numero(n:integer) is
        begin
            assert h0=segmento(n mod 10) and h1=segmento((n/10) mod 10) and h2=segmento((n/100) mod 10)
                report "Total inesperado, esperado " & integer'image(n) severity failure;
        end;
        procedure reiniciar is
        begin
            botones(1)<='0';wait for 40 us;
            assert pwm='0' and in1='0' report "Motor activo durante reset" severity failure;
            botones(1)<='1';wait for 100 us;
            assert in1='0' report "Rearranque sin rearme SW3" severity failure;
            sw(3)<='0';wait for 100 us;sw(3)<='1';wait for 100 us;
        end;
        procedure pieza(c:integer;t:time;esperado:integer) is
        begin
            muestra<=c;ancho_echo<=t;presencia<='0';wait for 30 us;
            assert in1='0' report "No se detuvo para medir" severity failure;
            wait until in1='1' for 400 ms;
            assert in1='1' and leds(8)='0' report "No reanudo pieza valida" severity failure;
            numero(esperado);presencia<='1';wait for 260 ms;
            assert in1='1' and leds(8)='0' report "No termino recorrido" severity failure;
        end;
        variable inicio:time;
    begin
        wait for 100 us;
        sw(3)<='1';wait for 200 us;
        assert in1='0' and leds(9)='1' report "Arranca sin calibracion" severity failure;
        -- Posiciones de reposo 1500 us y desvio 1700 us, confirmadas por usuario.
        for p in 1 to 4 loop
            pagina(p);
            if p=1 or p=3 then pulsar(0);pulsar(2);
            else for j in 1 to 8 loop pulsar(0);end loop;end if;
        end loop;
        for v in 0 to 3 loop
            pagina(0,v);for j in 1 to 10+v loop pulsar(0);end loop;
            pagina(7,v);sw(3)<='1';wait for 60 us;pulsar(0);
            assert in1='1' report "No inicia cronometro" severity failure;
            wait for 80 ms;pulsar(0);wait for 40 ms;pulsar(0);wait for 80 ms;pulsar(0);
            wait for 100 us;
            assert in1='0' and leds(9)='1' report "No guarda calibracion" severity failure;
        end loop;
        -- Regreso al automatico, conservando configuracion en los cuatro niveles.
        sw(3)<='0';wait for 100 us;sw<=(others=>'0');wait for 100 us;sw(3)<='1';wait for 100 us;
        assert in1='1' and leds(9)='0' report "Automatico no preparado" severity failure;
        -- 21 validas: las seis combinaciones, no solo un color.
        for i in 1 to 21 loop
            if i mod 2=0 then pieza(((i-1)/2) mod 3+1,139 us,i);
            else pieza(((i-1)/2) mod 3+1,232 us,i);end if;
        end loop;
        assert h3=segmento(0) and h2=segmento(0) and h1=segmento(2) and h0=segmento(1)
            report "21 no se muestra como 0021" severity failure;
        -- Rechazo blanco: no consume total ni ID.
        muestra<=0;presencia<='0';wait for 200 ms;
        assert leds(8)='1' and in1='0' report "Falta rechazo/paro" severity failure;
        numero(21);presencia<='1';reiniciar;numero(21);
        sw(4)<='1';wait for 100 us;numero(21);
        assert h3="1111111" report "Historial debe apagar HEX3" severity failure;
        sw(4)<='0';wait for 100 us;
        -- Verde pendiente no se oculta: esta prueba solo comprueba muestras sinteticas.
        pieza(1,232 us,22);
        -- Servo 1 se abre una sola vez y no sigue el menu.
        muestra<=1;ancho_echo<=232 us;presencia<='0';wait until in1='0';wait until in1='1' for 400 ms;
        numero(23);presencia<='1';wait for 85 ms;
        wait until rising_edge(servo1);inicio:=now;wait until falling_edge(servo1);
        assert now-inicio=1700 us report "Servo1 no alcanza ancho de desvio" severity failure;
        wait until rising_edge(servo2);inicio:=now;wait until falling_edge(servo2);
        assert now-inicio=1500 us report "Servo2 se mueve para categoria1" severity failure;
        wait for 200 ms;sw(4)<='1';wait for 100 us;
        wait until rising_edge(servo1);inicio:=now;wait until falling_edge(servo1);
        assert now-inicio=1500 us report "Consulta de historial mueve servo" severity failure;
        sw(4)<='0';wait for 100 us;
        -- Cambio de velocidad durante captura queda pendiente, no cancela pieza.
        muestra<=1;ancho_echo<=139 us;presencia<='0';wait for 2 ms;pulsar(2);
        wait until in1='1' for 400 ms;assert leds(8)='0' report "Cambio pendiente cancela pieza" severity failure;
        assert h3=segmento(0) report "Velocidad cambio durante pieza" severity failure;
        numero(24);presencia<='1';wait for 125 ms;
        wait until rising_edge(servo2);inicio:=now;wait until falling_edge(servo2);
        assert now-inicio=1700 us report "Servo2 no abre para categoria2" severity failure;
        wait until rising_edge(servo1);inicio:=now;wait until falling_edge(servo1);
        assert now-inicio=1500 us report "Servo1 se mueve para categoria2" severity failure;
        wait for 260 ms;
        assert h3=segmento(1) report "Cambio pendiente no aplicado" severity failure;
        -- Reset con SW3 arriba debe exigir el paso por 0; la sesion permanece.
        reiniciar;numero(24);assert h3=segmento(0) report "Reset no devuelve nivel0" severity failure;
        -- Nueva pieza durante transporte: incidencia sin segundo conteo.
        muestra<=3;ancho_echo<=232 us;presencia<='0';wait until in1='0';wait until in1='1' for 400 ms;
        numero(25);presencia<='1';wait for 2 ms;presencia<='0';wait for 100 us;
        assert in1='0' and leds(8)='1' report "No detecta segunda pieza" severity failure;
        numero(25);presencia<='1';reiniciar;
        -- Distancia dudosa 3 cm: reintenta y rechaza.
        ancho_echo<=174 us;presencia<='0';wait for 200 ms;
        assert leds(8)='1' and in1='0' report "Zona dudosa aceptada" severity failure;
        numero(25);presencia<='1';reiniciar;
        -- Sin eco tampoco genera una pieza grande por distancia cero.
        responder<=false;presencia<='0';wait for 200 ms;
        assert leds(8)='1' and in1='0' report "Sin eco no detiene" severity failure;
        numero(25);presencia<='1';responder<=true;reiniciar;
        -- Retirar pieza antes de terminar la medicion cancela captura.
        presencia<='0';wait for 5 ms;presencia<='1';wait for 100 us;
        assert leds(8)='1' and in1='0' report "Retiro prematuro no detectado" severity failure;
        numero(25);
        presencia<='1';reiniciar;
        -- Cambiar el porcentaje invalida solo los tiempos de ese nivel.
        pagina(0,0);pulsar(0);
        sw(3)<='0';wait for 100 us;sw<=(others=>'0');wait for 100 us;sw(3)<='1';wait for 100 us;
        assert in1='0' and leds(9)='1' report "Usa tiempos viejos despues de cambiar PWM" severity failure;
        numero(25);
        report "OK: integracion completa, 6 categorias, 0021, rechazo/ID, PWM/servos, rearme, calibracion, consultas, incidencias" severity note;
        terminado<=true;wait;
    end process;
    process
    begin wait for 20 sec;assert terminado report "Timeout del testbench de integracion" severity failure;wait;end process;
end;
