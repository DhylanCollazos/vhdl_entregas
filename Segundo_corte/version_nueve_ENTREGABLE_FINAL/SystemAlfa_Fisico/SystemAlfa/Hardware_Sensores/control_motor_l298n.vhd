library ieee;
use ieee.std_logic_1164.all;
-- EN se conecta a ENA y ENB; IN1 a IN1/IN3; IN2 a IN2/IN4.
-- Un motor por canal. El PWM controla tension media, no mide RPM.
entity control_motor_l298n is
    generic (CICLOS_PERIODO : positive := 5000); -- 10 kHz con 50 MHz
    port (reloj, reinicio, habilitar : in std_logic;
          porcentaje : in integer range 0 to 100;
          en_pwm, in1, in2 : out std_logic);
end;
architecture rtl of control_motor_l298n is
    signal cuenta : integer range 0 to CICLOS_PERIODO-1 := 0;
    signal limite : integer range 0 to CICLOS_PERIODO := 0;
begin
    assert CICLOS_PERIODO mod 100=0 report "Periodo PWM debe ser multiplo de 100" severity failure;
    process(reloj, reinicio)
    begin
        if reinicio='1' then cuenta<=0; limite<=0;
        elsif rising_edge(reloj) then
            if habilitar='0' then cuenta<=0; limite<=0;
            elsif cuenta=CICLOS_PERIODO-1 then cuenta<=0;
            else cuenta<=cuenta+1; end if;
            if habilitar='1' and cuenta=0 then limite<=porcentaje*(CICLOS_PERIODO/100); end if;
        end if;
    end process;
    en_pwm <= '1' when habilitar='1' and reinicio='0' and cuenta<limite else '0';
    in1 <= habilitar and not reinicio;
    in2 <= '0';
end;
