BEGIN {
    OFS=","
    OFMT="%.1f"
    days_in_month[1] = 31
    days_in_month[2] = 28
    days_in_month[3] = 31
    days_in_month[4] = 30
    days_in_month[5] = 31
    days_in_month[6] = 30
    days_in_month[7] = 31
    days_in_month[8] = 31
    days_in_month[9] = 30
    days_in_month[10] = 31
    days_in_month[11] = 30
    days_in_month[12] = 31

    # Constants from 1.8 ASHRAE Fundamentals SI
    C1 = -5.6745359e3
    C2 =  6.3925247
    C3 = -9.6778430e-3
    C4 =  6.2215701e-7
    C5 =  2.0747825e-9
    C6 = -9.4840240e-13
    C7 =  4.1635019

    C8 = -5.8002206e3
    C9 =  1.3914993
   C10 = -4.8640239e-2
   C11 =  4.1764768e-5
   C12 = -1.4452093e-8
   C13 =  6.5459673
}

{
    noaa_year = substr($0, 16, 4) + 0
    noaa_month = substr($0, 20, 2) + 0
    noaa_day = substr($0, 22, 2) + 0
    noaa_hour = substr($0, 24, 2) + 0
    noaa_minute = substr($0, 26, 2) + 0

    # Shift the hour back by a fixed amount
    new_hour = noaa_hour - 6
    new_day = noaa_day
    new_month = noaa_month
    new_year = noaa_year

    if (new_hour < 0) {
        new_hour += 24

        new_day -= 1

        if (new_day < 1) {

            new_month -= 1

            if (new_month < 1) {
                new_month += 12
                new_year -= 1
            }

            new_day = days_in_month[new_month]
        }
    }

    year = new_year
    month = new_month
    day = new_day
    hour = new_hour + 1  # Plus 1 since EP is 1-24
    minute = noaa_minute + 1 # Plus 1 since EP is 1-60


    data_source_and_uncertainty = "" # Missing Value
    dry_bulb_temperature = substr($0, 88, 5) / 10  # DegC
    dew_point_temperature = substr($0, 94, 5) / 10 # DegC

    # Cacluate Relative Humidity
    dry_bulb_temperature_kelvins = dry_bulb_temperature + 273.15
    dew_point_temperature_kelvins = dew_point_temperature + 273.15

    oa_pw = pws(dew_point_temperature_kelvins)
    oa_pws = pws(dry_bulb_temperature_kelvins)

    relative_humidity = oa_pw / oa_pws * 100.0
    atmospheric_station_pressure = substr($0, 100, 5) * 10
    extraterrestrial_horizontal_radiation = "9999" # Not used in EP, Missing Value
    extraterrestrial_direct_normal_radiation = "9999" # Not used in EP, Missing Value
    horizontal_infrared_radiation_intensity = "9999" # Missing Value
    global_horizontal_radiation = "9999" # Not used in EP, Missing Value
    direct_normal_radiation = "9999" # Missing Value
    diffuse_horizontal_radiation = "9999" # Missing Value
    global_horizontal_illuminance = "999999" # Not used in EP, Missing Value
    direct_normal_illuminance = "999999" # Not used in EP, Missing Value
    diffuse_horizontal_illuminance = "999999" # Not used in EP, Missing Value
    zenith_luminance = "9999" # Not used in EP, Missing Value
    wind_direction = substr($0, 61, 3)
    wind_speed = substr($0, 66, 4) / 10
    total_sky_cover = "99" # Missing Value
    opaque_sky_cover = "99" # Missing Value
    visibility = "9999" # Not used in EP, Missing Value
    ceiling_height = "99999" # Not used in EP, Missing Value
    present_weather_observation = "9" # Missing Value
    present_weather_codes = "999999999" # Missing Value
    precipitable_water = "999" # Not used in EP, Missing Value
    aerosol_optical_depth = "999" # Not used in EP, Missing Value
    snow_depth = "999" # Missing Value
    days_since_last_snowfall = "99" # Not used in EP, Missing Value
    albedo = "0.999" # Not used in EP, Missing Value
    liquid_precipitation_depth = "" # Missing Value
    liquid_precipitation_quantity = "" # Not used in EP, Missing Value


    # Overwrite the data source and uncertainty col.
    data_source_and_uncertainty = "A7A7A0A7?0?0?0?0?0?0?0?0A7A7F0F0?0?0F0F0?0?0"
    print sprintf("%d", year), sprintf("%d", month), sprintf("%d", day), sprintf("%d", hour), sprintf("%d", minute), data_source_and_uncertainty, dry_bulb_temperature, dew_point_temperature, relative_humidity, atmospheric_station_pressure, extraterrestrial_horizontal_radiation, extraterrestrial_direct_normal_radiation, horizontal_infrared_radiation_intensity, global_horizontal_radiation, direct_normal_radiation, diffuse_horizontal_radiation, global_horizontal_illuminance, direct_normal_illuminance, diffuse_horizontal_illuminance, zenith_luminance, wind_direction, wind_speed, total_sky_cover, opaque_sky_cover, visibility, ceiling_height, present_weather_observation, present_weather_codes, precipitable_water, aerosol_optical_depth, snow_depth, days_since_last_snowfall, albedo, liquid_precipitation_depth, liquid_precipitation_quantity
}


# Saturation Pressure equation. T in Kelvin, p returned in Pa.
function pws(T,              p) {
    if (T < 0) {
        p = exp(C1/T + C2 + C3*T + C4*T*T + C5*T*T*T + C6*T*T*T*T + C7*log(T))
    } else {
        p = exp(C8/T + C9 + C10*T + C11*T*T + C12*T*T*T  + C13*log(T))
    }
    return p
}
