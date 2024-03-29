# Siam Summer School Exercises

Source code of all exercises and solutions of the summer
school.

You should find the exercises here:
https://www.eawag.ch/summerschool/exercises
(redirecting to):
https://eawag-siam.github.io/SiamSummerSchoolExercises/

## Build html's

The `Rmarkdown` files  are compiles with
the R packages `rmarkdown`. Additionally `pandoc` may need to be
installed manually.

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
