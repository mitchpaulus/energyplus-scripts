# Purpose: Help build wall objects for EnergyPlus

# USAGE:
#   awk -f wall-builder.awk lowZ highZ zonename coordinate_file

# ASSUMPTIONS:
# Coordinate file should complete a cycle, that is, the first and last line should be the same.

BEGIN {
    lowZ = ARGV[1]
    ARGV[1] = ""
    highZ = ARGV[2]
    ARGV[2] = ""
    zone_name = ARGV[3]
    ARGV[3] = ""

    vertex_num = 1
}

# Just check that we don't try to process an empty line
NF > 1 {
    # Just store variables on the first line
    if (NR == 1) {
        prevX = $1
        prevY = $2
        prevExtInt = $3
    }
    else {
        currX = $1
        currY = $2

        if (prevExtInt ~ /[Ee]/) {  # Exterior Wall
            printf("Wall:Detailed,\n")
            printf("     %s Wall %d,    !- Name\n", zone_name, vertex_num)
            printf("     First Floor Wall,     !- Construction Name\n")
            printf("     %s,     !- Zone Name\n", zone_name)
            printf("     Outdoors,          !- Outside Boundary Condition\n")
            printf("     ,                  !- Outside Boundary Condition Object\n")
            printf("     SunExposed,        !- Sun Exposure\n")
            printf("     WindExposed,       !- Wind Exposure\n")
            printf("     autocalculate,     !- View Factor to Ground\n")
            printf("     autocalculate,     !- Number of Vertices\n")
        }
        else # Interior Wall
        {
            printf("Wall:Detailed,\n")
            printf("     %s Wall %d,    !- Name\n", zone_name, vertex_num)
            printf("     Interior Wall,     !- Construction Name\n")
            printf("     %s,     !- Zone Name\n", zone_name)
            printf("     Adiabatic,         !- Outside Boundary Condition\n")
            printf("     ,                  !- Outside Boundary Condition Object\n")
            printf("     NoSun,             !- Sun Exposure\n")
            printf("     NoWind,            !- Wind Exposure\n")
            printf("     autocalculate,     !- View Factor to Ground\n")
            printf("     autocalculate,     !- Number of Vertices\n")
        }

        # Assuming we are starting in the upper left hand corner, counter-clockwise
        printf("     %.3f,%.3f,%.3f, !- Vertex 1 X,Y,Z {m}\n", prevX, prevY, highZ)
        printf("     %.3f,%.3f,%.3f, !- Vertex 2 X,Y,Z {m}\n", prevX, prevY, lowZ)
        printf("     %.3f,%.3f,%.3f, !- Vertex 3 X,Y,Z {m}\n", currX, currY, lowZ)
        printf("     %.3f,%.3f,%.3f; !- Vertex 4 X,Y,Z {m}\n", currX, currY, highZ)

        printf("\n\n")

        prevX = currX
        prevY = currY
        prevExtInt = $3

        vertex_num++
    }
}
