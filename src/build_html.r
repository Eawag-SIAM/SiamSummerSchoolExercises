## -------------------------------------------------------
##
## Build html for all excerises from *rmd files
##
## January 17, 2023 -- Andreas Scheidegger
## andreas.scheidegger@eawag.ch
## -------------------------------------------------------


## libraries needed 
library(rmarkdown)
library(knitr)

library(JuliaCall)  # needed for Julia

## --- settings
out.dir <- "docs"
src.dir <- "src"

## --- compile all exercises
exercises <- c("exercise_0", "exercise_1", "exercise_2")[1:3]

exercises <- c("index", exercises)
for(exer in exercises){
    source.file <- paste0(gsub("\\./", "", exer), ".Rmd")
    source <- file.path(src.dir, exer, source.file)
    print(paste("Comile:", source))
    
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
