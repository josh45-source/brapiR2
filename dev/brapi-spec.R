# Derive the BrAPI v2.1 endpoint inventory from the specification.
#
# Pinned to the V2.1 tag of github.com/plantbreeding/BrAPI so the counts
# and parameter lists are reproducible and do not drift with the spec.
#
# Run interactively:  Rscript dev/brapi-spec.R
# Writes:             dev/brapi-endpoints.rds

library(yaml)

`%||%` <- function(x, y) if (is.null(x)) y else x

`%||%` <- function(x, y) if (is.null(x)) y else x

REF <- "V2.1"

message("Listing the specification tree at ", REF, " ...")
tree <- httr2::request(paste0(
  "https://api.github.com/repos/plantbreeding/BrAPI/git/trees/", REF,
  "?recursive=1"
)) |>
  httr2::req_timeout(60) |>
  httr2::req_perform() |>
  httr2::resp_body_json()

stopifnot(!isTRUE(tree$truncated))

paths <- vapply(tree$tree, function(i) i$path, character(1))
files <- grep(
  "^Specification/BrAPI-(Core|Genotyping|Germplasm|Phenotyping)/.*\\.yaml$",
  paths, value = TRUE
)
# Schemas/ holds object definitions, not endpoints.
files <- grep("/Schemas/", files, value = TRUE, invert = TRUE)
message("Found ", length(files), " endpoint files.")

raw_url <- function(p) {
  paste0(
    "https://raw.githubusercontent.com/plantbreeding/BrAPI/", REF, "/",
    utils::URLencode(p)
  )
}

rows <- list()
for (i in seq_along(files)) {
  f <- files[i]
  message(sprintf("[%3d/%3d] %s", i, length(files), basename(f)))
  y <- tryCatch(yaml::read_yaml(raw_url(f)), error = function(e) NULL)
  if (is.null(y) || is.null(y$paths)) next

  module <- sub("^Specification/BrAPI-([A-Za-z]+)/.*$", "\\1", f)
  entity <- sub("^Specification/BrAPI-[A-Za-z]+/([^/]+)/.*$", "\\1", f)

  for (path in names(y$paths)) {
    for (method in names(y$paths[[path]])) {
      op <- y$paths[[path]][[method]]
      pars <- op$parameters
      qp <- character(0)
      if (length(pars)) {
        keep <- vapply(
          pars,
          function(p) identical(p$`in`, "query") && !is.null(p$name),
          logical(1)
        )
        qp <- vapply(pars[keep], function(p) p$name, character(1))
      }
      rows[[length(rows) + 1L]] <- data.frame(
        file       = f,
        module     = module,
        entity     = entity,
        path       = path,
        method     = toupper(method),
        summary    = op$summary %||% NA_character_,
        deprecated = isTRUE(op$deprecated),
        params     = paste(qp, collapse = ","),
        stringsAsFactors = FALSE
      )
    }
  }
}

endpoints <- do.call(rbind, rows)
endpoints <- endpoints[order(endpoints$module, endpoints$path, endpoints$method), ]
rownames(endpoints) <- NULL

saveRDS(endpoints, "dev/brapi-endpoints.rds")
message("\nWrote dev/brapi-endpoints.rds: ", nrow(endpoints), " path/method pairs.")
print(table(endpoints$module, endpoints$method))
