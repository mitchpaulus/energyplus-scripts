#!/usr/bin/env python3
# USAGE:
# python3 to_vba.py proposed 90 < design.enduse.tsv
import sys

model_type = sys.argv[1]

if model_type != "proposed" and model_type != "baseline":
    raise ValueError(f"Invalid model type '{model_type}'")

rotation = sys.argv[2]

if model_type == "proposed":
    col = 8
elif rotation == "0":
    col = 7
elif rotation == "90":
    col = 8
elif rotation == "180":
    col = 9
elif rotation == "270":
    col = 10
else:
    raise ValueError("Invalid rotation")

data = [line.split("\t") for line in sys.stdin.read().splitlines()][1:]

class Printer:
    def __init__(self, offset) -> None:
        self.total_count = 0
        self.offset = offset
        self.values = []

    def print_vba(self, row, col, value):
        print(f"ActiveWorkbook.Sheets(\"Performance_Outputs_1\").Cells({row + self.offset}, {col}).Value = {value}")
        self.total_count += 1
        self.values.append(value)

# Use `leed_rows v4...xlsm` to get the row numbers and offset
rows = {
  "Interior lighting": 97,
  "Exterior lighting": 99,
  "Space heating": 101,
  "Space cooling": 103,
  "Pumps": 105,
  "Heat rejection": 107,
  "Fans - interior ventilation": 109,
  "Fans - parking garage": 111,
  "Service water heating": 113,
  "Receptacle equipment": 115,
  "IT equipment": 117,
  "Interior lighting - process": 119,
  "Refrigeration equipment": 121,
  "Fans - Kitchen Ventilation": 123,
  "Cooking": 125,
  "Industrial Process": 127,
  "Elevators and escalators": 129,
  "Heat Pump Supplementary": 131,
  "Space Heating (Electricity)": 133,
  "Misc Equipment (Natural Gas)": 135,
  "Auxilary (Natural Gas)": 137,
  "Cooling (Electricity)": 139,
}
proposed_offset = 74

total_non_zero = 0

offset = proposed_offset if model_type == "proposed" else 0
p = Printer(offset)

non_zero_values = []

for row in data:
    if row[0].strip() == "":
        break

    # Last column is Water use, so skip
    for i in range(1, len(row) - 1):
        if float(row[i]) > 0.001:
            non_zero_values.append(row[i].strip())
            total_non_zero += 1

    elec_value = row[1].strip()
    nat_gas_value = row[2].strip()
    district_cooling_value = row[11].strip()

    if row[0] == "Heating":
        p.print_vba(rows["Space heating"], col, nat_gas_value)
        p.print_vba(rows["Space Heating (Electricity)"], col, elec_value)
    elif row[0] == "Cooling":
        p.print_vba(rows["Space cooling"], col, district_cooling_value)
        p.print_vba(rows["Cooling (Electricity)"], col, elec_value)
    elif row[0] == "Interior Lighting":
        p.print_vba(rows["Interior lighting"], col, elec_value)
    elif row[0] == "Exterior Lighting":
        p.print_vba(rows["Exterior lighting"], col, elec_value)
    elif row[0] == "Interior Equipment":
        p.print_vba(rows["Receptacle equipment"], col, elec_value)
    elif row[0] == "Exterior Equipment":
        pass
    elif row[0] == "Fans":
        p.print_vba(rows["Fans - interior ventilation"], col, elec_value)
    elif row[0] == "Pumps":
        p.print_vba(rows["Pumps"], col, elec_value)
    elif row[0] == "Heat Rejection":
        pass
    elif row[0] == "Humidification":
        pass
    elif row[0] == "Heat Recovery":
        pass
    elif row[0] == "Water Systems":
        p.print_vba(rows["Service water heating"], col, nat_gas_value)
    elif row[0] == "Refrigeration":
        pass
    elif row[0] == "Generators":
        pass

# Check that the total number of non-zero values matches the number printed
if total_non_zero != p.total_count:
    print(f"Total non-zero values do not match the number printed. Expected {total_non_zero}, got {p.total_count}", file=sys.stderr)
    # Print the set-difference between the two lists
    print("Difference:", file=sys.stderr)
    for v in set(non_zero_values) - set(p.values):
        print(v, file=sys.stderr)

    sys.exit(1)
