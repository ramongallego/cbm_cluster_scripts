#!/bin/bash
hostname
##

dt=/ngs/microbios/resources/greengenes2/2024.09/
starttime=`date +%s`
wd=/junk/$USER/$starttime

#--create working dir #[[ -d $wd ]] && rm -fr $wd && mkdir -p $wd
if [ -d $wd ]
	then
	rm -fr $wd
fi
mkdir -p $wd
cd $wd

#--copy data to junk/scratch
cp $dt/tree.id.nwk $wd

#--run programs
/ngs/software/R/4.2.1-C7/bin/./R
getwd()
#install.packages("phangorn")
#library(phangorn)
#tree_ASV<-read.tree("tree.asv.nwk")
as<-c(1,1)
save.image()

#--copying results back to data dir
rm -fr tree.asv.nwk
cp $wd/* $dt

#--deleting workdir
rm -fr $wd

