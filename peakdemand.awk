# PURPOSE: determine the peak demand from an EnergyPlus simulation.
# INPUT: standard eplusout.mtr file


BEGIN { FS=OFS=","
    in_data = 0
    max_consumption = 0
}

/End of Data Dictionary/ {
    in_data = 1
}


/Electricity:Facility \[J\] !Hourly/ {
    report_code = $1
}

in_data && $1 == report_code {
    gsub(/\r/, "")

    if ($2 > max_consumption) {
        max_consumption = $2
    }
}

END {
    print max_consumption / 3600000
}
