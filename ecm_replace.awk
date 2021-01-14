# PURPOSE: Modify baseline EnergyPlus idf file in order to add energy
# conservation measures (ECM).
#
# This is accomplished by using the following two markers:
#
# 1. Replace ECMXX ::
# 2. Delete ECMXX ::
#
# 'XX' is normally a two digit ECM measure number. This allows one to easily have
# several ECMs accounted for in a single file.
#
#
# USAGE:
# awk -f ecm_replace.awk -v ecm=01 file
#
# OPTIONS:
#  inc = Make this anything besides 0 to include all 'previous' measures
#
BEGIN {
    replace_text = "Replace ECM"
    replace_text_length = length(replace_text)
    ecm = ecm + 0
}

{
    match_index = match($0, replace_text "[0-9]*")

    if (match_index) {
        found_ecm = substr($0, RSTART + replace_text_length, RLENGTH - replace_text_length) + 0

        # inc is a passed in variable for 'including' previous ecms.
        # Many programs like to have a stacked savings approach.
        matches_ecm = inc + 0 ? found_ecm <= ecm : found_ecm == ecm

        print (matches_ecm ? substr($0, RSTART + RLENGTH + 4) : $0)
    }
    else {

        match_delete_index = match($0, /Delete ECM[0-9]*/)

        if (match_delete_index) {
            found_ecm = substr($0, RSTART + replace_text_length, RLENGTH - replace_text_length) + 0
            # inc is a passed in variable for 'including' previous ecms.
            # Many programs like to have a stacked savings approach.
            matches_ecm = inc ? found_ecm <= ecm : found_ecm == ecm

            # If it doesn't apply, print the line
            if (!matches_ecm) { print }
        }
        else {
            # If we don't match a delete, then it's just an ordinary line
            # and print it out.
            print
        }
    }
}
