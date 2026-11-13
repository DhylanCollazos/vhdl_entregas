create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty
# Entradas asincronas, sincronizadas en sus lectores.
set_false_path -from [get_ports {V183_OUT HCSR04_ECHO TCS_OUT BUTTON[*] SW[*]}]
set_output_delay -clock CLOCK_50 -max 0 [all_outputs]
set_output_delay -clock CLOCK_50 -min 0 [all_outputs]
