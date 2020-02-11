#!/usr/bin/awk -E

# PURPOSE: Form fill templates
# USAGE:
# awk templatefile recordsfile
BEGIN {
    FS = "\t"
    # awk program name counts as the first argument.
    if (ARGC < 2) {
        print "2 Arguments required.\n\nUSAGE:\nawk -f file template records"
        exit 1
    }

    template = ARGV[1]
    ARGV[1] = ""

    while (getline < template > 0 ) {
        form[++n] = $0
    }
}

# Each line in the input/records file creates a new template,
# so this serves like another for loop.
{
    # Loop over lines of the template
    for (i = 1; i <= n; i++) {
        temp = form[i]

        # Go backwards, in case there are multiple digit substiuttions.
        # Example, if you did #1 befor #10, you'd be left with the #1
        # substitution with a 0 populated at the end.
        for (j = NF; j >= 1; j--) {

            # Clean commas from substitution (this is for numbers like 1,000)
            gsub(/,/, "", $j)

            gsub("#" j, $j, temp)
        }

        print temp
    }
}
