# energyplus-scripts

Collection of helpful scripts related to EnergyPlus

## `annual_kwh.awk`

Extract the annual facility electricity (in kWh) use out of the `eplusout.mtr`
file.

```
./annual_kwh.awk eplous.mtr
```

## `ecm_replace.awk`

Apply ECM changes to the baseline file.

```
awk -f ecm_replace.awk -v ecm=01 in.idf
```

## `replace_includes.awk`

Allows for an idf to be split up into several files. Can reference an
external file like:

```
! INCLUDE myfile.idf
```

## `floor-vertex.awk`, `wall-builder.awk`, `window-builder.awk`

Helps build geometry elements from file specifying X-Y coordinates.

