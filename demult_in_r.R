library(tidyverse)
library(here)
library(eDNAfuns)

arguments <- commandArgs(TRUE)

input_folder <- arguments[1]
dir.create(file.path(input_folder, "demult_files"))


first_demult <- read_csv(file = file.path(input_folder,"demult_i5.txt")) 
second_demult<- read_csv(file = file.path(input_folder,"demult_i7.txt")) 

PCR_products <- fastq_reader( file.path(input_folder,"with_BOTH.fq"), keepQ = T) 

metadata <- read_csv( file.path(input_folder,"metadata.csv")) |> 
  select(Sample_Name, i7barcode= I7_Index_ID, i5barcode = I5_Index_ID )

inner_join(first_demult, second_demult) |> 
  inner_join(metadata) |> 
  inner_join(PCR_products) |> 
  group_by(Sample_Name) |>
  nest() |> 
  mutate(print = walk2 (Sample_Name, data, ~ eDNAfuns::fastq_writer(
    df = .y,
    sequence = seq,    
    header = header, 
    Qscores = Qscores, 
    file.out = file.path(input_folder,"demult_files", paste0("Sample_",.x, ".fastq")))
                              ))
