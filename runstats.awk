# This script calculates the CV-RMSE and NMBE for a given EnergyPlus run
# Assumes: column 2 is actual, column 3 is modeled

# Check that values are actually there
$2 !~ /^ *$/ && $3 !~ /^ *$/ {
    actual = $2
    modeled = $3

    sum_actual += actual

    diff = modeled - actual
    sum_diff += diff

    squared_diff = diff * diff
    sum_squared_diff += squared_diff

    num++
}

END {
    mean_squared_diff = sum_squared_diff / num

    RMSE = sqrt(mean_squared_diff)

    mean_actual = sum_actual / num

    CV_RMSE = RMSE / mean_actual * 100

    NMBE = sum_diff / (num * mean_actual) * 100

    print CV_RMSE
    print NMBE
}

