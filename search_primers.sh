#!/bin/bash
source ~/.bash_profile  || echo ".bashrc could not be sourced"
# # Search for FWD linker
conda activate cutadaptenv
## Put all parameters in a parameters file and source it

which cutadapt

source /home/microbios/Moncho/demult/params.sh

cp "${BARCODES_i7}" "${BARCODES_i5}" "${METADATA}" "${OUTPUT_FOLDER}"/ 

# for threshold in 0.2; do
# change nanopore tabs for whitespaces
# Check if the first line contains a tab character

if head -n 1 "${INPUT_FILE}" | grep -q $'\t'; then
    # If a tab is found, perform the in-place substitution
    sed -i'' -e '/^@/s/\t/ /g' "${INPUT_FILE}"
else
    echo "No tabs found in the header. No substitution needed."
fi


cutadapt -g "FWD="${FWD_PRIMER}";min_overlap=20"  "${INPUT_FILE}" \
  --discard-untrimmed  -j 0 --report=minimal  --rc \
  --info-file "${OUTPUT_FOLDER}"/temp.txt -e 0.2 -o "${OUTPUT_FOLDER}"/with_{name}.fq


awk -F'\t' -v COLNAME=2 -v VALUE="-1" '{if ($COLNAME != VALUE && $3 != "0") {printf ">%s\n%s\n", $1,$5 } }' "${OUTPUT_FOLDER}"/temp.txt \
| cutadapt -g "file:"${BARCODES_i5}";min_overlap=8" -o /dev/null --info-file "${OUTPUT_FOLDER}"/demult_temp.txt -j 0 -
## 
echo "header,i5barcode" > "${OUTPUT_FOLDER}"/demult_i5.txt
awk -F '\t' -v COLNAME=2 -v VALUE='-1' ' OFS="," {if ($COLNAME != VALUE) print($1,$8)}' "${OUTPUT_FOLDER}"/demult_temp.txt >> "${OUTPUT_FOLDER}"/demult_i5.txt

cutadapt -a "REV="${REV_PRIMER_RC}";min_overlap=19"  "${OUTPUT_FOLDER}"/with_FWD.fq \
  --discard-untrimmed  -j 0 --report=minimal \
  --info-file "${OUTPUT_FOLDER}"/temp_rev.txt -e 0.2 -o "${OUTPUT_FOLDER}"/with_BOTH.fq

#

awk -F'\t' -v COLNAME=2 -v VALUE="-1" 'NR>1 {if ($COLNAME != VALUE) {printf ">%s\n%s\n", $1,$7 } }' "${OUTPUT_FOLDER}"/temp.txt \
| cutadapt -g "file:"${BARCODES_i7}";min_overlap=8" -o /dev/null --info-file "${OUTPUT_FOLDER}"/demult_temp2.txt -j 0 -

echo "header,i7barcode" > "${OUTPUT_FOLDER}"/demult_i7.txt

awk -F '\t' -v COLNAME=2 -v VALUE='-1' ' OFS="," {if ($COLNAME != VALUE) print ($1,$8)}' "${OUTPUT_FOLDER}"/demult_temp2.txt >> "${OUTPUT_FOLDER}"/demult_i7.txt


rm  "${OUTPUT_FOLDER}"/lens.txt

for file in "${OUTPUT_FOLDER}"/*.fq; do

seq_lens $file >> "${OUTPUT_FOLDER}"/lens.txt

done
seq_lens "${INPUT_FILE}" >>  "${OUTPUT_FOLDER}"/lens.txt 

## Add the path to cbm/s Rscript vanilla executable

/ngs/software/R/4.2.1-C7/bin/Rscript --vanilla /home/microbios/cbm_cluster_scripts/demult_in_r.R "${OUTPUT_FOLDER}"
