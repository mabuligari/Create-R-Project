#!/bin/sh

opt_project_name=simple
opt_project_suffix="r-proj"
opt_author_name=""
opt_author_email=""
opt_license="GPL"

### functions #####################
function fnct_project_dirname()
{
  prj_name=$1
  prj_suff=$2

  if [ -n "$prj_suff" ]; then
    echo "${prj_name}-${prj_suff}"
  else
    echo "${prj_name}"
  fi
}

### 

function fnct_author_name()
{
  author_name=$1

  if [ -n "${opt_author_name}" ]; then
    echo "${opt_author_name}"
  else 
    echo "__AUTHOR_NAME__"
  fi 
}

###

function fnct_author_email()
{
  author_name=$1

  if [ -n "${opt_author_email}" ]; then
    echo "${opt_author_email}"
  else 
    echo "__AUTHOR_EMAIL__"
  fi 
}

### 

function fnct_script_header()
{
  fileName=$1

  echo "###########################################################
# Filename    : ${fileName}
#-----------------------------------------------------------
# Project     : ${opt_project_name}
# Author(s)   : ${AuthorName} <${AuthorEmail}>
# Date        : $(date -I) (ISO 8601/YYYY-MM-DD)
#-----------------------------------------------------------
# License     : ${opt_license}
#-----------------------------------------------------------
" 
}

#######################################
### main                            ###
#######################################

AuthorName=$(fnct_author_name $opt_author_name)
AuthorEmail=$(fnct_author_email $opt_author_email)

### create project directory ### 
project_dirname=$(fnct_project_dirname $opt_project_name $opt_project_suffix) 

if [ ! -d "$project_dirname" ]; then
  mkdir "$project_dirname/" || \
    { echo "Error: Can't create '$project_dirname/' " >&2; exit 1; } 
else
   echo "Error: Directory '$project_dirname/' already exists. " >&2; exit 1; 
fi

### create sub directorie ### 
sub_dirnames="R data doc figs output"

for subdirname in ${sub_dirnames}; do
  subdir="${project_dirname}/${subdirname}"
  mkdir "${subdir}/"
  # add an empty '.gitignore' file to subdir.
  # Workaround for git with empty directories. 
  touch "${subdir}/.gitignore"
done

### 

echo "$(fnct_script_header ${project_dirname}/R/functions.R)
# Description: only function definitions - no code that actually runs
############################################################
" > ${project_dirname}/R/functions.R

### 

echo "$(fnct_script_header ${project_dirname}/R/utilities.R)
# Description: only utility function definitions - no code that actually runs
############################################################
" > ${project_dirname}/R/utilities.R

### 

echo "#!/usr/bin/Rscript
$(fnct_script_header ${project_dirname}/${opt_project_name}-main.R)
# Description : executable (main) R-script of project '${opt_project_name}'
#            This script ...
#
############################################################

# library(foreign)
# library(some_package)
# library(some_other_package)

source("R/functions.R")
source("R/utilities.R")

### stata ###
# dta.data.path <- ./data/__DATA_PATH__
# dta.file.name <- __DATA_NAME__.dta
# dta.file.path <- file.path(dta.data.path, dta.file.name)
# my.data.df    <- read.dta(dta.file.path, convert.factors=FALSE)

### spss ###
# spss.data.path <- ./data/__DATA_PATH__
# spss.file.name <- __DATA_NAME__.sav
# spss.file.path <- file.path(spss.data.path, spss.file.name)
# my.data.df     <- read.spss( spss.file.path,
#                              to.data.frame = TRUE, 
#                              use.value.labels = FALSE
#                            )

### sas ###
# sas.data.path <- ./data/..
## ? foreign::read.ssd
## ? foreign::read.xport
 
### 

my.data.df <- iris # default: R std. dataset 'iris'

###################
summary(my.data.df)


" > ${project_dirname}/${opt_project_name}-main.R

###########################################################

echo "
=================================================
== Project : ${opt_project_name}
== Author  : ${AuthorName} <${AuthorEmail}>
== Date    : $(date -I) (ISO 8601/YYYY-MM-DD)
== What/Abstract: 
   This project ....

=== Directory Structure: ===

${project_dirname}/
  |__ README.txt
  |__ ${opt_project_name}-main.R
        |__ functions.R
        |__ utilities.R
  |__ R/
  |__ data/
  |__ doc/
  |__ figs/
  |__ output/

* The ${project_dirname} directory contains this R project.
* The README.txt file (this) is the description of the project directory
  structure.
* The ${opt_project_name}-main.R is the main/executable R file ...
  TODO: add more text for "what is ${opt_project_name}-main.R..."
* The R directory contains various files with function definitions
  (but only function definitions - no code that actually runs).
* The data directory contains data used in the analysis. This is treated
  as read only; in paricular the R files are never allowed to write to
  the files in here. Depending on the project, these might be csv files,
  a database, and the directory itself may have subdirectories.

* The doc directory contains the paper. I work in LaTeX which is nice
  because it can pick up figures directly made by R. Markdown can do the
  same and is starting to get traction among biologists. With Word you’ll
  have to paste them in yourself as the figures update.

* The figs directory contains the figures. This directory only contains
  generated files; that is, I should always be able to delete the contents
  and regenerate them.

* The output directory contains simuation output, processed datasets,
  logs, or other processed things.

=== NOTES ===

* The base directory stucture based on the article 
  http://nicercode.github.io/blog/2013-04-05-projects/ by Vince Buffalo 
  (accessed: 2013-06-07)

" > ${project_dirname}/README.txt


############################
## show project structure
find "$project_dirname"
