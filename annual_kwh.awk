#!/usr/bin/awk -E

# This script attempts to pull out the annual kWh
# from the *out.mtr files.
BEGIN { FS="," }

$1 == id {
    printf("%d\n", $2 / 3600000.0)
}

/Electricity:Facility \[J\] !Annual/ {
    id = $1
}

