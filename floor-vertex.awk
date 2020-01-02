# floor-vertex.awk

# USAGE:

# awk -v type=1 -f floor-vertex.awk z-height zone_name file.
BEGIN {
    zheight=ARGV[1]
    ARGV[1] = ""
    zone_name = ARGV[2]
    ARGV[2] = ""

    # Base floor
    if (type == 1 || type == "ground")
    {
        printf("Floor:Detailed,\n")
        printf("    %s Floor,              !- Name\n", zone_name)
        printf("    Concrete Floor,      !- Construction Name\n")
        printf("    %s,                    !- Zone Name\n", zone_name)
        printf("    Ground,                  !- Outside Boundary Condition\n")
        printf("    ,                        !- Outside Boundary Condition Object\n")
        printf("    NoSun,                   !- Sun Exposure\n")
        printf("    NoWind,                  !- Wind Exposure\n")
        printf("    autocalculate,           !- View Factor to Ground\n")
        printf("    autocalculate,           !- Number of Vertices\n")
    } # Assume its a roof
    else if (type == 2 || type == "roof")
    {
        printf("RoofCeiling:Detailed,\n")
        printf("    %s Roof,               !- Name\n", zone_name)
        printf("    Exterior Roof,     !- Construction Name\n")
        printf("    %s,                    !- Zone Name\n", zone_name)
        printf("    Outdoors,                !- Outside Boundary Condition\n")
        printf("    ,                        !- Outside Boundary Condition Object\n")
        printf("    SunExposed,              !- Sun Exposure\n")
        printf("    WindExposed,             !- Wind Exposure\n")
        printf("    autocalculate,           !- View Factor to Ground\n")
        printf("    autocalculate,           !- Number of Vertices\n")
    }
    else if (type == 3 || type == "adiabatic")  # Adiabatic
    {
        printf("Floor:Detailed,\n")
        printf("    %s Floor,               !- Name\n", zone_name)
        printf("    Raised Floor,     !- Construction Name\n")
        printf("    %s,                    !- Zone Name\n", zone_name)
        printf("    Adiabatic,                !- Outside Boundary Condition\n")
        printf("    ,                        !- Outside Boundary Condition Object\n")
        printf("    NoSun,              !- Sun Exposure\n")
        printf("    NoWind,             !- Wind Exposure\n")
        printf("    autocalculate,           !- View Factor to Ground\n")
        printf("    autocalculate,           !- Number of Vertices\n")
    }
    else if (type == 4 || type == "ceiling") {
        printf("RoofCeiling:Detailed,\n")
        printf("    %s Ceiling,               !- Name\n", zone_name)
        printf("    Interior Ceiling,     !- Construction Name\n")
        printf("    %s,                    !- Zone Name\n", zone_name)
        printf("    Adiabatic,                !- Outside Boundary Condition\n")
        printf("    ,                        !- Outside Boundary Condition Object\n")
        printf("    NoSun,              !- Sun Exposure\n")
        printf("    NoWind,             !- Wind Exposure\n")
        printf("    autocalculate,           !- View Factor to Ground\n")
        printf("    autocalculate,           !- Number of Vertices\n")
    }
}

# Check for empty lines (often at the trailing end of the file.)
NF > 0 {
    lines[++n] = $0
}

END {
    # Remove any collinear points.
    for (i = 3; i <= n + 2; i++) {
        split(lines[i-2], firstPoints)
        if ( (i - 1) > n) { split(lines[i - 1 - n], secondPoints) } else { split(lines[i - 1], secondPoints) }
        if (i > n) { split(lines[i - n], thirdPoints) } else { split(lines[i], thirdPoints) }

        x1 = firstPoints[1]
        y1 = firstPoints[2]
        x2 = secondPoints[1]
        y2 = secondPoints[2]
        x3 = thirdPoints[1]
        y3 = thirdPoints[2]

        area = 0.5 * (x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2))

        if (area < 0.0000000001 && area > -0.0000000001) {
            numBad++
            badLines[ (i - 1) > n ? (i - 1 - n) : (i - 1)] = 1
        }
    }

    vertexCount = 1
    for (i = 1; i <= n; i++) {
        if (i in badLines) { continue }

        coords = lines[i]

        split(coords, fields)
        if (vertexCount == (n - numBad)) { terminator = ";" } else { terminator = "," }
        printf("    %0.3f,%0.3f,%.3f%s       !- Vertex %d X,Y,Z {m}\n", fields[1], fields[2], zheight, terminator, vertexCount)
        vertexCount++
    }
    printf("\n\n")

}
