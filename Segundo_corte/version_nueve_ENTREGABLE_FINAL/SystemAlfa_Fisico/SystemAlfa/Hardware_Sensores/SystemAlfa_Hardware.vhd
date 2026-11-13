library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Hardware is
    generic (
        PRESENCIA_ACTIVA_BAJO:boolean:=true;
        FRECUENCIA_RELOJ_HZ:positive:=50000000;
        CICLOS_FILTRO:positive:=500000;
        CICLOS_PRESENCIA:positive:=250000;
        CICLOS_TICK:positive:=500000;
        VENTANA_COLOR:positive:=1500000;
        ASENTAR_COLOR:positive:=25000;
        CICLOS_PWM_MOTOR:positive:=5000;
        CICLOS_US_SERVO:positive:=50;
        INTERVALO_HC_US:positive:=61000;
        EXT_DRIVER_INVERSOR:boolean:=true
    );
    port (
        CLOCK_50,V183_OUT,HCSR04_ECHO,TCS_OUT:in std_logic;
        HCSR04_TRIG,TCS_S0,TCS_S1,TCS_S2,TCS_S3:out std_logic;
        BUTTON:in std_logic_vector(2 downto 0);
        SW:in std_logic_vector(9 downto 0);
        LEDG:out std_logic_vector(9 downto 0);
        HEX0,HEX1,HEX2,HEX3:out std_logic_vector(6 downto 0);
        MOTOR_PWM,MOTOR_IN1,MOTOR_IN2,SERVO1,SERVO2:out std_logic;
        LED_CATEGORIAS:out std_logic_vector(3 downto 0);
        HEX_VEL_EXT,HEX_CAT_EXT:out std_logic_vector(6 downto 0)
    );
end;

architecture estructural of SystemAlfa_Hardware is
    signal arranque:std_logic_vector(3 downto 0):="1111";
    signal reset_sesion,reset_boton,reinicio,reset_lectores,tick:std_logic;
    signal switches:std_logic_vector(9 downto 0);
    signal boton0,boton2,subir,bajar,paro_crudo,paro_confirmado:std_logic;
    signal armado,permiso,error_mando,modo_ajuste,cambio_modo:std_logic:='0';
    signal pagina:integer range 0 to 63:=0;
    signal nivel_ajuste:integer range 0 to 3:=0;
    signal nivel_seleccionado:integer range 0 to 3;
    signal pres_1,pres_2:std_logic:='1';
    signal presencia,pulso_pieza:std_logic;
    signal hc_iniciar,tcs_iniciar,hc_fin,hc_val,hc_tam,hc_busy,tcs_fin,tcs_val,tcs_busy:std_logic;
    signal inicio_hc_auto,inicio_tcs_auto,inicio_diag:std_logic;
    signal distancia:std_logic_vector(7 downto 0);
    signal color_tcs:std_logic_vector(1 downto 0);
    signal rojo,verde,azul:std_logic_vector(15 downto 0);
    signal iniciar_medicion,med_lista,med_val,med_tam,med_busy:std_logic;
    signal med_color:std_logic_vector(1 downto 0);
    signal presencia_core,color_tamano_core,marcha_core,evento_core,linea_core,alarma_core,limite_core:std_logic;
    signal color_core,color_led,nivel_core:std_logic_vector(1 downto 0);
    signal categoria_core,categoria_led,categoria_fisica,error_fisico:std_logic_vector(3 downto 0);
    signal tamano_led,marcha_entrada,marcha_control,motor_auto,abrir1,abrir2,ocupado,alarma_fisica:std_logic;
    signal configurado,pos_ok1,pos_ok2,motor_prueba,error_ajuste,motor_habilitado:std_logic;
    signal duty:integer range 0 to 100;
    signal reposo1,desvio1,reposo2,desvio2,pulso1,pulso2:integer range 1000 to 2000;
    signal adelanto1,adelanto2:integer range 5 to 100;
    signal llegada1,llegada2,salida_cinta:integer range 0 to 6000;
    signal etapa:std_logic_vector(3 downto 0);
    signal valor_ajuste,valor_visor:integer range 0 to 65535;
    signal ver_hex,activar_servo1,activar_servo2,alarma_total:std_logic;
    signal c0,c1,c2,c3,a0,a1,a2,a3,seg_vel_ext,seg_cat_ext:std_logic_vector(6 downto 0);
    signal n_vel:std_logic_vector(3 downto 0);
    signal cambio_vel_n,cambio_en_curso:std_logic;
    signal pendientes:integer range 0 to 3:=0;
    signal fase_vel:integer range 0 to 2:=0;
    signal cuenta_vel:integer range 0 to 3:=0;
begin
    -- Inicializacion de sesion, independiente del boton de reset.
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then arranque<=arranque(2 downto 0)&'0'; end if;
    end process;
    reset_sesion<=arranque(3);
    U_RESET:entity work.reinicio_seguro port map(CLOCK_50,BUTTON(1),reset_boton);
    reinicio<=reset_boton or reset_sesion;
    U_TICK:entity work.base_tiempo_fisica generic map(CICLOS_TICK) port map(CLOCK_50,reinicio,tick);
    G_SW:for i in 0 to 9 generate
        U_SW:entity work.filtro_boton generic map(CICLOS_FILTRO)
            port map(CLOCK_50,reinicio,SW(i),open,switches(i));
    end generate;
    boton0<=not BUTTON(0);boton2<=not BUTTON(2);paro_crudo<=not SW(3);
    U_B0:entity work.filtro_boton generic map(CICLOS_FILTRO) port map(CLOCK_50,reinicio,boton0,subir,open);
    U_B2:entity work.filtro_boton generic map(CICLOS_FILTRO) port map(CLOCK_50,reinicio,boton2,bajar,open);
    U_PARO:entity work.filtro_boton generic map(CICLOS_FILTRO) port map(CLOCK_50,reinicio,paro_crudo,open,paro_confirmado);
    -- Rearme exige un cero fisico de SW3. La pagina y el modo se eligen parado.
    process(CLOCK_50,reinicio)
    begin
        if reinicio='1' then
            armado<='0';error_mando<='0';modo_ajuste<='0';pagina<=0;nivel_ajuste<=0;cambio_modo<='0';
        elsif rising_edge(CLOCK_50) then
            cambio_modo<='0';
            if paro_confirmado='1' then
                armado<='1';
                if modo_ajuste/=switches(0) then cambio_modo<='1';end if;
                modo_ajuste<=switches(0);pagina<=to_integer(unsigned(switches(9 downto 4)));
                nivel_ajuste<=to_integer(unsigned(switches(2 downto 1)));
            elsif switches(3)='1' and armado='1' then
                if switches(0)/=modo_ajuste then error_mando<='1';
                elsif modo_ajuste='1' and (to_integer(unsigned(switches(9 downto 4)))/=pagina or
                      to_integer(unsigned(switches(2 downto 1)))/=nivel_ajuste) then error_mando<='1';end if;
            end if;
        end if;
    end process;
    permiso<=armado and switches(3) and SW(3) and BUTTON(1) and not reinicio and not error_mando;
    reset_lectores<=reinicio or cambio_modo;
    -- Presencia electrica real, tambien visible durante la inicializacion del V183.
    process(CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then pres_1<=V183_OUT;pres_2<=pres_1;end if;
    end process;
    presencia<=not pres_2 when PRESENCIA_ACTIVA_BAJO else pres_2;
    U_V183:entity work.entrada_presencia_v183 generic map(CICLOS_PRESENCIA,PRESENCIA_ACTIVA_BAJO)
        port map(CLOCK_50,reset_lectores,V183_OUT,open,pulso_pieza);
    U_HC:entity work.lector_hcsr04
        generic map(FRECUENCIA_RELOJ_HZ=>FRECUENCIA_RELOJ_HZ,USAR_VENTANAS_MM=>true,INTERVALO_MINIMO_US=>INTERVALO_HC_US)
        port map(CLOCK_50,reset_lectores,hc_iniciar,HCSR04_ECHO,HCSR04_TRIG,distancia,hc_tam,hc_fin,hc_val,hc_busy);
    U_TCS:entity work.lector_tcs3200
        generic map(VENTANA_CICLOS=>VENTANA_COLOR,ASENTAMIENTO_CICLOS=>ASENTAR_COLOR,CLASIFICACION_HABILITADA=>true)
        port map(CLOCK_50,reset_lectores,tcs_iniciar,TCS_OUT,TCS_S0,TCS_S1,TCS_S2,TCS_S3,
                 color_tcs,rojo,verde,azul,tcs_fin,tcs_val,tcs_busy);
    inicio_diag<=subir when modo_ajuste='1' and pagina>=8 and pagina<=11 and hc_busy='0' and tcs_busy='0' else '0';
    hc_iniciar<=inicio_diag when modo_ajuste='1' else inicio_hc_auto;
    tcs_iniciar<=inicio_diag when modo_ajuste='1' else inicio_tcs_auto;
    U_MEDIR:entity work.medicion_coordinada
        port map(CLOCK_50,reset_lectores,tick,iniciar_medicion,hc_fin,hc_val,hc_tam,hc_busy,
                 tcs_fin,tcs_val,tcs_busy,color_tcs,inicio_hc_auto,inicio_tcs_auto,med_lista,med_val,med_busy,med_color,med_tam);
    nivel_seleccionado<=nivel_ajuste when modo_ajuste='1' else to_integer(unsigned(nivel_core));
    U_AJUSTE:entity work.ajuste_fisico
        port map(CLOCK_50,reset_sesion,reinicio,tick,modo_ajuste,permiso,subir,bajar,pagina,nivel_seleccionado,
                 duty,reposo1,desvio1,reposo2,desvio2,adelanto1,adelanto2,llegada1,llegada2,salida_cinta,
                 configurado,pos_ok1,pos_ok2,motor_prueba,error_ajuste,etapa,valor_ajuste);
    marcha_entrada<=permiso and not modo_ajuste;
    marcha_control<=marcha_core and marcha_entrada and not cambio_en_curso;
    U_FISICO:entity work.control_clasificacion_fisica
        port map(CLOCK_50,reset_lectores,tick,marcha_control,configurado,pulso_pieza,presencia,
                 med_lista,med_val,med_tam,med_color,evento_core,categoria_core,
                 llegada1,llegada2,salida_cinta,adelanto1,adelanto2,
                 iniciar_medicion,presencia_core,color_core,color_tamano_core,
                 motor_auto,abrir1,abrir2,ocupado,alarma_fisica,categoria_fisica,error_fisico);
    -- Guarda solicitudes de BUTTON2 y las aplica al terminar la pieza.
    process(CLOCK_50,reinicio)
        variable solicitudes:integer range 0 to 3;
    begin
        if reinicio='1' then pendientes<=0;fase_vel<=0;cuenta_vel<=0;
        elsif rising_edge(CLOCK_50) then
            solicitudes:=pendientes;
            if modo_ajuste='1' then solicitudes:=0;fase_vel<=0;cuenta_vel<=0;
            else
                if bajar='1' then solicitudes:=(solicitudes+1) mod 4;end if;
                if fase_vel=0 then
                    if solicitudes>0 and ocupado='0' and presencia='0' then
                        solicitudes:=solicitudes-1;fase_vel<=1;cuenta_vel<=0;
                    end if;
                elsif tick='1' then
                    if cuenta_vel=3 then
                        cuenta_vel<=0;
                        if fase_vel=1 then fase_vel<=2;else fase_vel<=0;end if;
                    else cuenta_vel<=cuenta_vel+1;end if;
                end if;
            end if;
            pendientes<=solicitudes;
        end if;
    end process;
    cambio_vel_n<='0' when fase_vel=1 else '1';
    cambio_en_curso<='1' when fase_vel/=0 else '0';
    U_CORE:entity work.SystemAlfa_Final
        generic map(FRECUENCIA_RELOJ_HZ=>FRECUENCIA_RELOJ_HZ,CICLOS_FILTRO=>CICLOS_FILTRO)
        port map(RELOJ=>CLOCK_50,REINICIO_BAJO=>BUTTON(1),PRESENCIA=>presencia_core,CAMBIO_VELOCIDAD=>cambio_vel_n,
            SELECTOR_COLOR=>color_core,SELECTOR_TAMANO=>color_tamano_core,LINEA_MARCHA=>marcha_entrada,
            VER_HISTORIAL=>SW(4),SIGUIENTE_HISTORIAL=>SW(5),SELECCION_HISTORIAL=>SW(6),VER_CANTIDADES=>SW(7),
            IR_ULTIMO=>SW(8),CONTAR_POR_COLOR=>SW(9),LED_COLOR=>color_led,LED_TAMANO=>tamano_led,
            LINEA_ACTIVA=>linea_core,RUTA_PIEZA=>categoria_led,ALARMA=>alarma_core,LED_LIMITE=>limite_core,
            VISOR_0=>c0,VISOR_1=>c1,VISOR_2=>c2,VISOR_3=>c3,
            MARCHA_FISICA=>marcha_core,EVENTO_VALIDO=>evento_core,NIVEL_FISICO=>nivel_core,CATEGORIA_FISICA=>categoria_core);
    motor_habilitado<=permiso and motor_prueba when modo_ajuste='1' else permiso and motor_auto and not alarma_core and not limite_core;
    U_MOTOR:entity work.control_motor_l298n generic map(CICLOS_PWM_MOTOR)
        port map(CLOCK_50,reinicio,motor_habilitado,duty,MOTOR_PWM,MOTOR_IN1,MOTOR_IN2);
    -- En ajuste solo se mueve el servo elegido, habilitado por SW3.
    process(modo_ajuste,pagina,permiso,pos_ok1,pos_ok2,reposo1,reposo2,desvio1,desvio2,abrir1,abrir2)
    begin
        pulso1<=reposo1;pulso2<=reposo2;activar_servo1<=pos_ok1;activar_servo2<=pos_ok2;
        if modo_ajuste='1' then
            if (pagina=1 or pagina=2) and permiso='1' then
                activar_servo1<='1';if pagina=2 then pulso1<=desvio1;end if;
            elsif (pagina=3 or pagina=4) and permiso='1' then
                activar_servo2<='1';if pagina=4 then pulso2<=desvio2;end if;
            end if;
        else
            if abrir1='1' and permiso='1' then pulso1<=desvio1;end if;
            if abrir2='1' and permiso='1' then pulso2<=desvio2;end if;
        end if;
    end process;
    U_SERVO1:entity work.pwm_servo generic map(CICLOS_US_SERVO) port map(CLOCK_50,reinicio,activar_servo1,pulso1,SERVO1);
    U_SERVO2:entity work.pwm_servo generic map(CICLOS_US_SERVO) port map(CLOCK_50,reinicio,activar_servo2,pulso2,SERVO2);
    process(pagina,valor_ajuste,distancia,rojo,verde,azul)
    begin
        valor_visor<=valor_ajuste;ver_hex<='0';
        case pagina is
            when 8=>valor_visor<=to_integer(unsigned(distancia));
            when 9=>valor_visor<=to_integer(unsigned(rojo));ver_hex<='1';
            when 10=>valor_visor<=to_integer(unsigned(verde));ver_hex<='1';
            when 11=>valor_visor<=to_integer(unsigned(azul));ver_hex<='1';
            when others=>null;
        end case;
    end process;
    U_VISOR:entity work.visor_ajuste port map(CLOCK_50,valor_visor,ver_hex,a0,a1,a2,a3);
    HEX0<=a0 when modo_ajuste='1' else c0; HEX1<=a1 when modo_ajuste='1' else c1;
    HEX2<=a2 when modo_ajuste='1' else c2; HEX3<=a3 when modo_ajuste='1' else c3;
    alarma_total<=alarma_fisica or alarma_core or error_mando;
    process(modo_ajuste,etapa,pagina,configurado,error_ajuste,error_mando,motor_habilitado,
            color_led,tamano_led,categoria_led,alarma_total,alarma_fisica,error_fisico,limite_core,hc_val,tcs_val)
    begin
        LEDG<=(others=>'0'); LEDG(3)<=motor_habilitado;
        if modo_ajuste='1' then
            LEDG(1 downto 0)<=etapa(1 downto 0);LEDG(2)<=hc_val and tcs_val;
            LEDG(7 downto 4)<=std_logic_vector(to_unsigned(pagina mod 16,4));
            LEDG(8)<=error_ajuste or error_mando;LEDG(9)<=configurado;
        else
            LEDG(1 downto 0)<=color_led;LEDG(2)<=tamano_led;LEDG(7 downto 4)<=categoria_led;
            if alarma_fisica='1' then LEDG(7 downto 4)<=error_fisico;end if;
            LEDG(8)<=alarma_total;LEDG(9)<=limite_core or not configurado;
        end if;
    end process;
    G_LED:for i in 0 to 3 generate
        LED_CATEGORIAS(i)<='1' when modo_ajuste='0' and to_integer(unsigned(categoria_fisica))=i+3 and alarma_total='0' else '0';
    end generate;
    n_vel<=std_logic_vector(to_unsigned(nivel_seleccionado,4));
    U_EXT_V:entity work.decodificador_7segmentos port map(n_vel,seg_vel_ext);
    U_EXT_C:entity work.decodificador_7segmentos port map(categoria_fisica,seg_cat_ext);
    -- ULN2803A invierte: GPIO=1 enciende el segmento de anodo comun.
    HEX_VEL_EXT<=not seg_vel_ext when EXT_DRIVER_INVERSOR else seg_vel_ext;
    HEX_CAT_EXT<=not seg_cat_ext when EXT_DRIVER_INVERSOR else seg_cat_ext;
end;
