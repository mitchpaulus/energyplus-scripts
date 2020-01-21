# This script generates the end use breakdown according to the
# requirements for the P4P program in NJ.
# INPUT: eplusout.mtr file
BEGIN { FS=OFS=","
    in_data = 0
    joules_to_mmbtu = 1 / (1.0550559 * 1000000000)
}

/End of Data Dictionary/ {
    in_data = 1
}

/Cooling:Electricity \[J\] !Annual/ { cooling_report_code = $1 }
in_data && $1 == cooling_report_code {  cooling = $2 * joules_to_mmbtu }

/Heating:Electricity \[J\] !Annual/ { heating_report_code = $1 }
in_data && $1 == heating_report_code {  heating = $2 * joules_to_mmbtu }

/InteriorEquipment:Electricity \[J\] !Annual/ { int_equipment_report_code = $1 }
in_data && $1 == int_equipment_report_code {  int_equipment = $2 * joules_to_mmbtu }

/InteriorLights:Electricity \[J\] !Annual/ { int_lights_report_code = $1 }
in_data && $1 == int_lights_report_code { int_lights = $2 * joules_to_mmbtu }

/Fans:Electricity \[J\] !Annual/ { fans_report_code = $1 }
in_data && $1 == fans_report_code { fans = $2 * joules_to_mmbtu }

END {
    print heating       # Space Heating
    print cooling       # Cooling
    print fans          # Ventilation
    print 0             # Water Heating
    print int_lights    # Lighting
    print 0             # Pumps
    print 0             # Heat Rejection
    print 0             # Supplemental Heat Pump
    print 0             # Exterior Usage
    print int_equipment # Plug and Process Load
    print 0             # Refrigeration
}
