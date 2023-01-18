## ===================================
## Install and load packages
## 25.09.2021
## ===================================

## check into which directory the packages will be installed
.libPaths() # the first one of the displayed directories is the one for default installation

## if you do not like that directory, or if the directory is not writable, change it with:
## .libPaths("new/libpath/library")
## if the change should be permanent, place the line above in your .Rprofile file (located in your home directory ~)


if ( ! require(mvtnorm) )     { install.packages("mvtnorm");     library(mvtnorm) }
if ( ! require(lpridge) )     { install.packages("lpridge");     library(lpridge) }
if ( ! require(lokern) )      { install.packages("lokern");      library(lokern) }
if ( ! require(sensitivity) ) { install.packages("sensitivity"); library(sensitivity) }
if ( ! require(IDPmisc) )     { install.packages("IDPmisc");     library(IDPmisc) }
if ( ! require(adaptMCMC) )   { install.packages("adaptMCMC");   library(adaptMCMC) }
if ( ! require(mcmcensemble) ) { install.packages("mcmcensemble"); library(mcmcensemble) }
if ( ! require(coda) )        { install.packages("coda");        library(coda) }
if ( ! require(boa) )         { install.packages("boa");         library(boa) }
if ( ! require(EasyABC) )     { install.packages("EasyABC");     library(EasyABC) }
if ( ! require(deSolve) )     { install.packages("deSolve")};    library(deSolve)
if ( ! require(FME) )         { install.packages("FME");         library(FME) }

if ( ! require(remotes) )     { install.packages("remotes");     library(remotes) }
if ( ! require(EawagSchoolTools) ) { install_github("baccione-eawag/EawagSchoolTools"); library(EawagSchoolTools) }

## Manual installation of EawagSchoolTools
## Note that the path of the current working directory should not contain empty spaces for the next step:
## install.packages("EawagSchoolTools_0.9.tar.gz",repos=NULL,type="source")
## library(EawagSchoolTools)
