# CPBP 8306 - R environment check.
#
# Run this after Session 1, once you have worked through the install guide.
# It tells you what is working and what is missing. It installs nothing and
# changes nothing.
#
#   In RStudio:  open this file and click Source
#   In a shell:  Rscript handouts/check_setup.R

cat(strrep("=", 66), "\n", sep = "")
cat("CPBP 8306 R environment check\n")
cat(strrep("=", 66), "\n", sep = "")

problems <- character(0)

report <- function(ok, label, detail = "") {
  status <- if (ok) "[  ok   ]" else "[MISSING]"
  cat(status, " ", label, if (nzchar(detail)) paste0("  - ", detail) else "", "\n", sep = "")
}

# ----------------------------------------------------------------- R itself
cat("\nR\n")
v <- getRversion()
if (v >= "4.2.0") {
  report(TRUE, paste("R", v))
} else {
  report(FALSE, paste("R", v), "the course assumes 4.2 or newer")
  problems <- c(problems, "Update R from https://cran.r-project.org/")
}
cat("        library path:", .libPaths()[1], "\n")

# --------------------------------------------------------------- packages
cat("\nR packages\n")

pkgs <- list(
  tidyverse = "dplyr, ggplot2, readr and friends (Sessions 7-10)",
  ggplot2   = "publication graphics (Session 10)",
  dplyr     = "data wrangling (Sessions 7-8)",
  readr     = "reading CSVs (Session 6)",
  tidyr     = "reshaping (Session 8)",
  broom     = "tidy model output (Session 11)"
)

for (p in names(pkgs)) {
  if (requireNamespace(p, quietly = TRUE)) {
    report(TRUE, sprintf("%-12s", p), pkgs[[p]])
  } else {
    report(FALSE, sprintf("%-12s", p), pkgs[[p]])
    problems <- c(problems, sprintf('install.packages("%s")', p))
  }
}

# ------------------------------------------------------------------ summary
cat("\n", strrep("=", 66), "\n", sep = "")
if (length(problems) > 0) {
  cat(length(unique(problems)), "thing(s) to fix:\n\n")
  for (p in unique(problems)) cat("   ", p, "\n")
  cat("\nInstalling the tidyverse covers most of the list in one go:\n")
  cat('   install.packages("tidyverse")\n')
  cat("\nThat one takes a few minutes. Start it and go get coffee.\n")
  cat("Still stuck after ten minutes? Stop, and bring it to study hall -\n")
  cat("Mondays 10:00-11:00, Light Hall 439 - or ask an instructor or the TA.\n")
} else {
  cat("Everything checks out. Nothing to do - see you in class.\n")
}
cat(strrep("=", 66), "\n", sep = "")
