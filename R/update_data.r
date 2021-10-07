library("here")

## make sure data directory exists - if not, create
dir.create(here::here("data"), showWarnings = FALSE)

## no timeout for downloading (otherwise 60s which might be too short if the
## files are big)
options(timeout = Inf)

## define spatial resolution
spatial_resolution <- "ltla" ## alternatively: "msoa"

## function to construct url for API
construct_csv_url <- function(query) {
  query_str <- vapply(names(query), function(x) {
    paste(x, query[[x]], sep = "=")
  }, "")
  url <- paste0("https://api.coronavirus.data.gov.uk/v2/data?",
                paste(query_str, collapse = "&"),
                "&format=csv")
}

## construct API query for vaccination data
vaccination_query <- c(
  areaType = spatial_resolution,
  metric = "vaccinationsAgeDemographics"
)

## create url and filename
url <- construct_csv_url(vaccination_query)
filename <- paste0("vaccinations_", spatial_resolution, ".csv")

## download
download.file(url, here::here("data", filename))

## construct API query for case data
cases_query <- c(
  areaType = spatial_resolution,
  metric = "newCasesBySpecimenDateAgeDemographics"
)

## create url and filename
url <- construct_csv_url(cases_query)
filename <- paste0("cases_", spatial_resolution, ".csv")

## download
download.file(url, here::here("data", filename))

