# Survey brapiR2 against every reachable BrAPI v2 server.
#
# Runs the same battery of calls against each server and records what
# happened. Writes dev/server-survey.rds and prints a summary. Servers
# needing credentials are skipped unless T3_USERNAME and T3_PASSWORD are
# set in ~/.Renviron.
#
# Run:  Rscript dev/survey-servers.R

devtools::load_all(".")

servers <- list(
  list(name = "BrAPI test server", url = "https://test-server.brapi.org"),
  list(name = "Cassavabase",       url = "https://cassavabase.org"),
  list(name = "Sweetpotatobase",   url = "https://sweetpotatobase.org"),
  list(name = "Coffeabase",        url = "https://coffeabase.org"),
  list(name = "Citrusgreening",    url = "https://citrusgreening.org"),
  list(name = "USDA-GRIN", url = "https://npgsweb.ars-grin.gov",
       path = "gringlobal/brapi"),
  list(name = "T3/Oat Sandbox",
       url = "https://oat-sandbox.triticeaetoolbox.org", auth = TRUE),
  list(name = "T3/Wheat Sandbox",
       url = "https://wheat-sandbox.triticeaetoolbox.org", auth = TRUE)
)

# One request per endpoint, not a full paginated fetch: the survey asks
# whether a server answers, not for all its data. brapi_get() walks every
# page, which on a large production server means thousands of requests.
probe <- function(con, endpoint) {
  resp <- brapi_req(con, endpoint) |>
    httr2::req_url_query(page = 0, pageSize = 5) |>
    httr2::req_perform()
  brapi_stop_for_status(resp, con, endpoint)
  b <- httr2::resp_body_json(resp, simplifyVector = FALSE)
  n <- b$metadata$pagination$totalCount
  if (is.null(n)) length(b$result$data %||% list()) else n
}

endpoints <- c(
  serverinfo = "/serverinfo", programs = "/programs", trials = "/trials",
  studies = "/studies", locations = "/locations", germplasm = "/germplasm",
  variables = "/variables", traits = "/traits",
  variant_sets = "/variantsets", samples = "/samples"
)

rows <- list()
for (s in servers) {
  message("\n== ", s$name, " ==")
  con <- brapi_connection(s$url, path = s$path %||% "brapi",
                          page_size = 10L, timeout = 30)

  if (isTRUE(s$auth)) {
    u <- Sys.getenv("T3_USERNAME"); p <- Sys.getenv("T3_PASSWORD")
    if (!nzchar(u) || !nzchar(p)) {
      message("  skipped: no credentials")
      next
    }
    con <- try(brapi_login(con, u, p), silent = TRUE)
    if (inherits(con, "try-error")) {
      message("  login failed")
      next
    }
  }

  for (nm in names(endpoints)) {
    ep <- endpoints[[nm]]
    t0 <- Sys.time()
    r <- try(suppressMessages(probe(con, ep)), silent = TRUE)
    secs <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
    ok <- !inherits(r, "try-error")
    rows[[length(rows) + 1L]] <- data.frame(
      server = s$name, call = nm, endpoint = ep, ok = ok,
      total = if (ok) as.integer(r) else NA_integer_, secs = secs,
      error = if (ok) NA_character_ else
        trimws(conditionMessage(attr(r, "condition"))),
      stringsAsFactors = FALSE
    )
    message(sprintf("  %-13s %-4s %9s %6ss", nm,
                    if (ok) "ok" else "FAIL",
                    if (ok) format(r, big.mark = ",") else "-", secs))
  }
}

survey <- do.call(rbind, rows)
saveRDS(survey, "dev/server-survey.rds")
message("\nWrote dev/server-survey.rds")
print(table(survey$server, survey$ok))
