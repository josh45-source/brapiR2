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

calls <- list(
  serverinfo   = function(con) brapi_server_info(con),
  programs     = function(con) brapi_programs(con, pageSize = 10),
  trials       = function(con) brapi_trials(con, pageSize = 10),
  studies      = function(con) brapi_studies(con, pageSize = 10),
  locations    = function(con) brapi_locations(con, pageSize = 10),
  germplasm    = function(con) brapi_germplasm(con, pageSize = 10),
  variables    = function(con) brapi_observation_variables(con, pageSize = 10),
  traits       = function(con) brapi_traits(con, pageSize = 10),
  variant_sets = function(con) brapi_variant_sets(con, pageSize = 10),
  samples      = function(con) brapi_samples(con, pageSize = 10)
)

rows <- list()
for (s in servers) {
  message("\n== ", s$name, " ==")
  con <- brapi_connection(s$url, path = s$path %||% "brapi", page_size = 10L)

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

  for (nm in names(calls)) {
    t0 <- Sys.time()
    r <- try(suppressMessages(calls[[nm]](con)), silent = TRUE)
    secs <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
    ok <- !inherits(r, "try-error")
    rows[[length(rows) + 1L]] <- data.frame(
      server = s$name, call = nm, ok = ok,
      rows = if (ok) nrow(r) else NA_integer_, secs = secs,
      error = if (ok) NA_character_ else trimws(conditionMessage(attr(r, "condition"))),
      stringsAsFactors = FALSE
    )
    message(sprintf("  %-13s %-4s %5s rows %6ss", nm,
                    if (ok) "ok" else "FAIL",
                    if (ok) nrow(r) else "-", secs))
  }
}

survey <- do.call(rbind, rows)
saveRDS(survey, "dev/server-survey.rds")
message("\nWrote dev/server-survey.rds")
print(table(survey$server, survey$ok))
