# Generate the "BrAPI endpoint" roxygen block for each wrapper.
#
# Reads dev/brapi-endpoints.rds (from dev/brapi-spec.R) and
# dev/brapi-function-map.rds, and writes dev/endpoint-blocks.txt for
# pasting into the roxygen above each function. Deliberately does not
# edit R/ itself.

e <- readRDS("dev/brapi-endpoints.rds")
m <- readRDS("dev/brapi-function-map.rds")

REF <- "V2.1"
BASE <- paste0("https://github.com/plantbreeding/BrAPI/blob/", REF, "/")

out <- character(0)
for (i in seq_len(nrow(m))) {
  fn <- m$fn[i]
  p <- m$path[i]
  meth <- if (grepl("^/search/", p)) "POST" else "GET"
  row <- e[e$path == p & e$method == meth, ]
  if (nrow(row) != 1L) {
    out <- c(out, sprintf("## %s -> %s [%d matches]", fn, p, nrow(row)), "")
    next
  }
  url <- paste0(BASE, gsub(" ", "%20", row$file))
  pars <- trimws(strsplit(row$params, ",")[[1]])
  pars <- pars[nzchar(pars)]
  blk <- c(
    sprintf("## %s", fn),
    "#' @section BrAPI endpoint:",
    sprintf("#' `%s %s` - see the", meth, p),
    sprintf("#' [v2.1 specification](%s).", url)
  )
  if (length(pars)) {
    blk <- c(
      blk,
      "#'",
      "#' Query parameters the specification defines, which may be passed",
      "#' through `...`:",
      "#'",
      paste0("#' ", strwrap(
        paste0(paste(sprintf("`%s`", pars), collapse = ", "), "."),
        width = 72
      ))
    )
  }
  out <- c(out, blk, "")
}

writeLines(out, "dev/endpoint-blocks.txt")
message("Wrote dev/endpoint-blocks.txt for ", nrow(m), " functions.")
