## -------------------------------------------------------
##
## Build html for all exercises from *rmd files
##
## January 17, 2023 -- Andreas Scheidegger
## andreas.scheidegger@eawag.ch
## -------------------------------------------------------


## libraries needed 
library(rmarkdown)
library(knitr)

library(JuliaCall)  # needed for Julia
julia_setup("C:/Users/nascimth/AppData/Local/Programs/Julia-1.10.3/bin")
## --- settings
out.dir <- "../docs"
src.dir <- "."

## --- compile all exercises
exercises <- c("exercise_0", "exercise_1", "exercise_2",
               "exercise_3", "exercise_4", "exercise_5")[3]

exercises <- c(exercises, "index")
for(exer in exercises){
    source.file <- paste0(gsub("\\./", "", exer), ".Rmd")
    source <- file.path(src.dir, exer, source.file)
    print(paste("Compile:", source))
    
    ## compile without solutions
    rmarkdown::render(source,
                      output_file = gsub("\\.Rmd", ".html", source.file),
                      output_dir = out.dir,
                      params = list(showsolutions=FALSE))
    
    ## compile with solutions
    if(exer != "index"){
        rmarkdown::render(source,
                          output_file = gsub("\\.Rmd", "_solution.html", source.file),
                          output_dir = out.dir,
                          params = list(showsolutions=TRUE))
    }
}


## --- zip all data files for easy download

files2zip <- dir('../data', pattern="csv$", full.names = TRUE)
zip(zipfile = 'data/exercise_data.zip', files = files2zip)
