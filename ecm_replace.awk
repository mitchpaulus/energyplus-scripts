# PURPOSE: Modify baseline EnergyPlus idf file in order to add energy
# conservation measures (ECM).
#
# This is accomplished by using the following two markers:
#
# 1. Replace ECMXX ::
# 2. Delete ECMXX ::
#
# 'XX' is a two digit ECM measure number. This allows one to easily have
# several ECMs accounted for in a single file.
{
    match_index = match($0, "Replace ECM" ecm)

    if (match_index) {
        print substr($0, RSTART + RLENGTH + 4)
    }
    else {
        match_delete_index = match($0, "Delete ECM" ecm)
        if (match_delete_index < 1) { print }
    }
}
