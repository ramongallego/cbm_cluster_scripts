library(tidyverse)
library(here)
library(eDNAfuns)

arguments <- commandArgs(TRUE)

input_folder <- arguments[1]
dir.create(file.path(input_folder, "demult_files"))


first_demult <- read_info_file(file = file.path(input_folder,"demulti5.txt")) |> 
  select(Seq.id, i5=adap_name)
second_demult<- read_info_file(file = file.path(input_folder,"demult_i7.txt")) |> 
  select(Seq.id, i7=adap_name)
PCR_products <- fastq_reader( file.path(input_folder,"with_BOTH.fq"), keepQ = T) |> 
  separate(header, into = "Seq.id", sep = " ")
metadata <- read_csv( file.path(input_folder,"metadata.csv")) |> 
  select(Sample_Name, i7= I7_Index_ID, i5 = I5_Index_ID )

inner_join(first_demult, second_demult) |> 
  inner_join(metadata) |> 
  inner_join(PCR_products) |> 
  group_by(Sample_Name) |>
  nest() |> 
  mutate(walk2 (Sample_Name, data, ~ fastq_writer(
    df = .y,
    sequence = seq,    
    header = Seq.id, 
    Qscores = Qscores, 
    file.out = file.path(input_folder,"demult_files", paste0("Sample_".x, ".fastq")))
                              ))
