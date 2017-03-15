#!/bin/sh

################################## fetchTaxonLabels.sh ###################################

###### STEP #1: SETUP AND USER INPUT.
###### Set paths and filetypes as different environmental variables:
	MY_PATH=`pwd -P`				## This script assumes it is being run in a sub-folder
							## of the MissingDataFX master directory specific to the 
							## current analysis. 
## echo "INFO      | $(date) |          Setting working directory to dir: "
## echo "INFO      | $(date) |          $MY_PATH "
	CR=$(printf '\r');
	calc () {
	bc -l <<< "$@" 
}

echo "INFO      | $(date) |          Reading in input NEXUS file(s)... "
###### Read in the NEXUS file(s), by getting filenames matching .nex or .NEX patterns. 
	MY_NEXUS_FILES="$(find . \( -name "*.nex" -o -name "*.NEX" -o -name "*.Nex" \) -type f | sed 's/\.\///g')"


###### STEP #2: MAKE AND RUN SCRIPT TO FETCH TAXON LABELS AND SAVE TO FILE.
		echo "INFO      | $(date) |          Running fetchTaxonLabels script... "
		fetchTaxonLabels () {

		(
			for i in "$MY_NEXUS_FILES"; do
				MY_NEXUS_FILE="$i"
				MY_NEXUS_BASENAME="$(echo "$i" | sed 's/\.\///g; s/\.[A-Za-z]\{3\}$//g')"
				
				NUM_HEADER_LINES="$(grep -n 'matrix\|MATRIX' "$MY_NEXUS_FILE" | sed 's/:.*$//g')"
				sed 1,"$NUM_HEADER_LINES"d "$MY_NEXUS_FILE" > ./"${MY_NEXUS_BASENAME}"_headless.nex
				MY_NUMLINES_END_1ST_BLOCK="$(grep -n "^$" ./"${MY_NEXUS_BASENAME}"_headless.nex | head -n1 | sed 's/\://g; s/\ //g')"
				MY_NUM_TAX="$(calc "$MY_NUMLINES_END_1ST_BLOCK"-1)"
				head -n"$MY_NUM_TAX" ./"${MY_NEXUS_BASENAME}"_headless.nex > ./"${MY_NEXUS_BASENAME}"_headless_seqData.txt

					echo "INFO      | $(date) |          Making a taxonLabels file for taxa in "$i" "
					perl -pe 's/^[\ ]*//g; s/\ +.*$//g' ./"${MY_NEXUS_BASENAME}"_headless_seqData.txt > ./"${MY_NEXUS_BASENAME}"_taxonLabels.txt

				rm ./"${MY_NEXUS_BASENAME}"_headless.nex ./"${MY_NEXUS_BASENAME}"_headless_seqData.txt
			done
		)
}

##--Don't forget to run the function!
fetchTaxonLabels



#
#
#
######################################### END ############################################

exit 0
