BEGIN { FS=OFS="," }

# Only use the first value of a particular hour.
# Don't print data with dry bulb temperature missing.
$7 != 99.9 {
    hour = sprintf("%s-%s-%s-%s", $1, $2, $3, $4)

    if (!(hour in usedhours)) {
        print
    }

    usedhours[hour] = 1
}
