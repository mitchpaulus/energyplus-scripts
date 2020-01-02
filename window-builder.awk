# This script builds simple 'Window' instances based on the same
# coordinates that go into the walls.
# USAGE:
# awk -f window-builder.awk wall_height zone_name ratio coordinate_file
# awk -f window-builder.awk 10 Core 0.5 file

# ASSUMPTIONS
#  1. coordinate_file has to complete a cycle. That means the first and last line should be the same.
#  2. Ratio should be 0-1

BEGIN {
    wall_height = ARGV[1]
    ARGV[1] = ""

    zone_name = toupper(substr(ARGV[2], 1, 1)) substr(ARGV[2], 2)
    ARGV[2] = ""

    window_to_wall_ratio = ARGV[3]
    ARGV[3] = ""

    # We can immediately calculate the new height
    #new_height = window_to_wall_ratio * window_to_wall_ratio * wall_height
    new_height = sqrt(wall_height * wall_height * window_to_wall_ratio)

    startY = (wall_height - new_height) / 2

    vertex_num = 1
}


NF > 1 {
    if (NR == 1) {
        prevX = $1
        prevY = $2
        prevExtInt = $3
    }
    else {
        currX = $1
        currY = $2

        if (prevExtInt ~ /[Ee]/) {  # Exterior Wall
            width = sqrt((currX - prevX)*(currX - prevX) + (currY - prevY)*(currY - prevY))

            aspect_ratio = width / wall_height

            new_width = new_height * aspect_ratio

            startX = (width - new_width) / 2

            printf("Window,\n")
            printf("     %s Window %d,    !- Name\n", zone_name, vertex_num)
            printf("     Exterior Window,     !- Construction Name\n")
            printf("     %s Wall %d,     !- Building Surface Name\n", zone_name, vertex_num)
            printf("     ,     !- Frame and Divider Name\n")
            printf("     1,     !- Multiplier\n")
            printf("     %.1f,     !- Starting X Coordinate {m}\n", startX)
            printf("     %.1f,     !- Starting Y Coordinate {m}\n", startY)
            printf("     %.1f,     !- Length {m}\n", new_width)
            printf("     %.1f;     !- Height {m}\n", new_height)
            printf("\n\n")
        }

        prevX = currX
        prevY = currY
        prevExtInt = $3

        vertex_num++
    }
}
