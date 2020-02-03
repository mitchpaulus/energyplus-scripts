BEGIN { FS=OFS="," }

# column 7 is dry bulb temperature. Remove those records
# where the temperature is missing (999.9)
$7 !~ /999.9/ && $1 == "2019" {
    hour = sprintf("%s-%s-%s-%s", $1, $2, $3, $4)

    if (!(hour in usedhours)) {
        print
    }

    usedhours[hour] = 1
}
