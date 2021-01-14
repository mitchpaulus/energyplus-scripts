# The purpose of this script is to convert day of simulation ranges to the awk
# code required to sum of the hourly values. Typically use the Validator output
# and Excel to get the 'days of simulation'
{
    printf "    if (dayOfSimulation >= %d && dayOfSimulation < %d) { total_energy[%s] += energy_joules }\n", $1, $2, NR
}
