library("readr")
library("readxl")
library("socialmixr")
library("dplyr")
library("tidyr")
library("janitor")
library("ggplot2")

spatial_resolution <- "ltla"

# make sure figure directory exists directory
fig_path <- here::here("figure")
dir.create(fig_path, recursive = TRUE, showWarnings = FALSE)

## get vaccination data and extract ages
vacc_file <- paste0("vaccinations_", spatial_resolution, ".csv")
vacc <- read_csv(here::here("data", vacc_file)) %>%
  clean_names() %>%
  mutate(lower_age_limit = as.integer(sub("[_+].*$", "", age))) %>% ## remove bit after "_" from age column
  select(-age)

cases_file <- paste0("cases_", spatial_resolution, ".csv")
cases <- read_csv(here::here("data", cases_file)) %>%
  clean_names() %>%
  mutate(lower_age_limit = as.integer(sub("[_+].*$", "", age))) %>%
  filter(!is.na(lower_age_limit)) %>%
  select(-age)

## age groups are slightly different between the two files - combine age group 16-17 and 18-25 to 15-25 in vaccination file
vacc <- vacc %>%
  mutate(lower_age_limit = if_else(lower_age_limit < 25, 15L, lower_age_limit))

## First, use totals
tot_cases <- cases %>%
  filter(date == max(date)) %>%
  group_by(area_name) %>%
  summarise(cases = sum(rolling_sum), .groups = "drop")

tot_vacc <- vacc %>%
  filter(date == max(date)) %>%
  group_by(area_name) %>%
  summarise(pop = sum(vaccine_register_population_by_vaccination_date),
            vaccinated = sum(cum_people_vaccinated_complete_by_vaccination_date),
            .groups = "drop")

combined <- tot_cases %>%
  inner_join(tot_vacc, by = "area_name") %>%
  mutate(cases = cases * 100000 / pop, vaccinated = vaccinated / pop)

p <- ggplot(combined, aes(x = cases, y = vaccinated)) +
  geom_point() +
  geom_smooth(alpha = 0.35, method = "lm") +
  ylab("2-dose vaccinated") +
  xlab("7-day case rate / 100k") +
  theme_minimal()

p
