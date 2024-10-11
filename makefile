.Phony: clean all

all: dir figure/change_in_emissions.png data/top_emitters

# Create the output directory if it doesn't exist
dir:
	mkdir -p figure
	mkdir -p data


clean:
	rm -rf figure
	rm -rf data

#data
data/top_emitters: fossil-fuel-co2-emissions-by-nation.csv
	Rscript project.R

#ggplot
figure/change_in_emissions.png: fossil-fuel-co2-emissions-by-nation.csv
	Rscript project.R