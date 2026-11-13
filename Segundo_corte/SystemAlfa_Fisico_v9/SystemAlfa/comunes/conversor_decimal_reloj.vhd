library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Misma conversion 000..999, con diez pasos registrados para cumplir 50 MHz.
entity conversor_decimal_reloj is
    port(reloj:in std_logic;numero_binario:in std_logic_vector(9 downto 0);
         centenas,decenas,unidades:out std_logic_vector(3 downto 0));
end;
architecture rtl of conversor_decimal_reloj is
    signal binario:unsigned(9 downto 0):=(others=>'0');
    signal bcd:unsigned(11 downto 0):=(others=>'0');
    signal resultado:std_logic_vector(11 downto 0):=(others=>'0');
    signal paso:integer range 0 to 10:=0;
begin
    process(reloj)
        variable ajuste:unsigned(11 downto 0);
    begin
        if rising_edge(reloj) then
            if paso=0 then
                if unsigned(numero_binario)>999 then binario<=to_unsigned(999,10);
                else binario<=unsigned(numero_binario);end if;
                bcd<=(others=>'0');paso<=1;
            else
                ajuste:=bcd;
                for i in 0 to 2 loop
                    if ajuste(i*4+3 downto i*4)>=5 then ajuste(i*4+3 downto i*4):=ajuste(i*4+3 downto i*4)+3;end if;
                end loop;
                ajuste:=ajuste(10 downto 0)&binario(9);bcd<=ajuste;binario<=binario(8 downto 0)&'0';
                if paso=10 then resultado<=std_logic_vector(ajuste);paso<=0;else paso<=paso+1;end if;
            end if;
        end if;
    end process;
    centenas<=resultado(11 downto 8);decenas<=resultado(7 downto 4);unidades<=resultado(3 downto 0);
end;
