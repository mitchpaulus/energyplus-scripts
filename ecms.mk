# The purpose of this file is to share some common targets that
# many of the EnergyPlus projects are going to share.
#
# Required variables
# scripts: location of this directory
# baseline: name of the baseline idf file (example.idf)
# weather:  name of the weather file (in.epw)
# run:      name of the directory that the model is executed in
#

idf_references=$(shell awk '/INCLUDE/  { print $$NF }' $(baseline))

ecms=$(shell grep -o 'ECM[0-9]\+' $(baseline) | sort -u | cut -c 4-)

make_ecm_files=$(addprefix $(run)/ecm, $(addsuffix $(1), $(ecms)))

annual_kWhs=$(call make_ecm_files,_annual_kWh.txt)
peak_demands=$(call make_ecm_files,_peak_demand.txt)

ecm_targets=$(annual_kWhs) $(peak_demands)

$(run)/in.epw : $(weather)
	cp $< $@

$(run)/$(baseline) : $(baseline) $(idf_references) $(scripts)/replace_includes.awk
	awk -f $(scripts)/replace_includes.awk $< > $@

$(run)/ecm%_$(baseline) : $(run)/$(baseline) $(scripts)/ecm_replace.awk
	awk -f $(scripts)/ecm_replace.awk -v ecm='$(*F)' -v inc=1 $< > $@

$(run)/ecm%out.mtr : $(run)/ecm%_$(baseline) $(run)/in.epw
	cd $(run)/ && ($(exe) -p ecm$(*F) -r $(<F) || (nvim ecm$(*F)out.err && false))

$(run)/%_annual_kWh.txt : $(run)/%out.mtr $(scripts)/annual_kwh.awk
	$(scripts)/annual_kwh.awk $< > $@

$(run)/%_peak_demand.txt : $(run)/%out.mtr $(scripts)/peakdemand.awk
	awk -f $(scripts)/peakdemand.awk $< > $@

