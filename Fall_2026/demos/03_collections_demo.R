# Session 3 - Collections and Indexing. R side.
#
# Run this ALONGSIDE demos/03_collections_demo.py, one section at a time,
# with both consoles visible. The whole point of this session is the
# side-by-side comparison, so do not run them separately.
#
#   source("demos/03_collections_demo.R")

rule <- function(title) {
  cat("\n", strrep("=", 62), "\n", title, "\n", strrep("=", 62), "\n", sep = "")
}

# ------------------------------------------------- slide 5: build a vector
rule("Vectors: c() means combine")

bp <- c(117, 122, 141, 130, 118)
print(bp)
cat("length:", length(bp), "\n")

# ---------------------------------------------- slide 6: silent coercion
rule("R coerces silently - no warning, no error")

mixed <- c(1, 2, "three")
print(mixed)
cat("class:", class(mixed), "  <- everything became text\n")
cat("\nThis is what happens when one row of your age column says 'unknown'.\n")

# ------------------------------------------------ slides 7-9: indexing
rule("Indexing: R counts from 1")

cat("bp[1]  ->", bp[1], "   (first)\n")
cat("bp[2]  ->", bp[2], "   (second)\n")
cat("bp[-1] -> ", paste(bp[-1], collapse = " "), "\n", sep = "")
cat("          ^ DROPS the first element. In Python this means 'the last one'.\n")

cat("\nbp[2:4] ->", paste(bp[2:4], collapse = " "), "  (stop is INCLUSIVE)\n")
cat("bp[c(1,3,5)] ->", paste(bp[c(1, 3, 5)], collapse = " "), "  (cherry-pick)\n")
cat("bp[0]  -> ", paste(bp[0], collapse = " "), "(empty - not an error!)\n", sep = "")

# ------------------------------------------ slide 11: the boolean mask
rule("Boolean indexing - the idiom that runs the whole semester")

cat("Step 1, the mask:      ")
print(bp > 130)

cat("Step 2, use the mask:  ")
print(bp[bp > 130])

cat("Step 3, count it:      ")
print(sum(bp > 130))

cat("\nRead bp[bp > 130] as: 'the elements of bp, where bp is over 130'.\n")
cat("dplyr::filter() is this. df[df.age > 65] is this. Learn it here.\n")

# ------------------------------------------------ slide 12: named lists
rule("Named lists - lookup by name, not position")

patient <- list(id = "P042", age = 61, systolic = 141, treated = TRUE)

cat("patient$age        ->", patient$age, "\n")
patient$age <- 62
cat("after update       ->", patient$age, "\n")
patient$dx <- "HTN"
cat("names(patient)     ->", paste(names(patient), collapse = " "), "\n")
