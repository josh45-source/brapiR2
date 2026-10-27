## Guard for the integration tests against https://test-server.brapi.org.
## They run whenever the server answers /serverinfo with a successful JSON
## response, on CI as well as locally, and skip otherwise with the HTTP
## status in the skip message. The server is pinged once per test run.

LIVE_SERVER <- "https://test-server.brapi.org"

live_server <- new.env(parent = emptyenv())

live_server_ping <- function() {
  if (is.null(live_server$ping)) {
    con <- brapi_connection(LIVE_SERVER, timeout = 30)
    live_server$ping <- suppressMessages(brapi_ping(con))
  }
  live_server$ping
}

skip_if_brapi_down <- function(ping = live_server_ping()) {
  if (isTRUE(ping)) {
    return(invisible(TRUE))
  }
  status <- attr(ping, "status")
  reason <- if (is.null(status) || is.na(status)) {
    "no response"
  } else {
    paste("HTTP", status)
  }
  testthat::skip(paste0(
    "BrAPI test server unavailable (", reason, " from /serverinfo)"
  ))
}
