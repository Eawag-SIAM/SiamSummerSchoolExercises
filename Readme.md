# Siam Summer School Exercises

Source code of all exercises and solutions of the summer
school.

You should find the exercises here:
https://www.eawag.ch/summerschool/exercises
(redirecting to):
https://eawag-siam.github.io/SiamSummerSchoolExercises/

## Build HTML documents

All `Rmarkdown` files are compiled with
the R to html. this also triggers the Julia and the Python version.


* You need R with the following packages installed:
  - `Rmarkdown`
  - `reticulate` to manage Python
  - `JuliaCall` to communicate with Julia

* Julia installation

* [`pandoc`](https://pandoc.org/)


Run the R script `src/build_html.R` to generate the documents in
`docs/` and all solutions. This means that R and Julia need to be
installed.  Then commit all changes (*including the `html` files in
`docs/`!*) and push it to GitHub. The new html will be deployed
automatically in a few minutes.


## License


[![license](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc-sa/4.0/)

This work is licensed under a [Creative Commons
Attribution-NonCommercial-ShareAlike 4.0 International
License](http://creativecommons.org/licenses/by-nc-sa/4.0/) with the
exception of the fonts under `src/fonts`.
