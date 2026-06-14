# =============================================================================
# FAMA-FRENCH THREE-FACTOR MODEL — PHASE 1: SINGLE STOCK ANALYSIS
# Author:  Ari Shareef Omar
# Stock:   NVIDIA Corporation (NVDA)
# Period:  January 2015 — Present
# =============================================================================

library(tidyverse)
library(tidyquant)
library(frenchdata)
library(broom)
library(zoo)

# --- Pull NVDA stock data ---
stock_data <- tq_get("NVDA",
                     from = "2015-01-01",
                     to   = Sys.Date(),
                     get  = "stock.prices")

# --- Calculate monthly returns using adjusted price ---
nvda_returns <- stock_data %>%
  tq_transmute(select     = adjusted,
               mutate_fun = periodReturn,
               period     = "monthly",
               col_rename = "nvda_return")

# --- Pull and clean Fama-French factor data ---
ff_factors <- download_french_data("Fama/French 3 Factors")
ff_data    <- ff_factors$subsets$data[[1]]

ff_data_clean <- ff_data %>%
  mutate(date = as.Date(paste0(date, "01"), format = "%Y%m%d"),
         date = ceiling_date(date, "month") - days(1)) %>%
  rename(mkt_rf = `Mkt-RF`,
         smb    = SMB,
         hml    = HML,
         rf     = RF)

# --- Merge on year-month to avoid trading day vs calendar day mismatch ---
ff_data_clean <- ff_data_clean %>%
  mutate(year_month = format(date, "%Y-%m"))

nvda_returns <- nvda_returns %>%
  mutate(year_month = format(date, "%Y-%m"))

nvda_ff <- nvda_returns %>%
  inner_join(ff_data_clean, by = "year_month") %>%
  select(year_month, nvda_return, mkt_rf, smb, hml, rf)

# --- Calculate excess return ---
nvda_ff <- nvda_ff %>%
  mutate(nvda_excess = nvda_return - (rf / 100))

# --- Run Fama-French regression ---
ff_model <- lm(nvda_excess ~ mkt_rf + smb + hml, data = nvda_ff)
summary(ff_model)

tidy(ff_model) %>%
  mutate(true_beta = ifelse(term == "(Intercept)",
                            estimate,
                            estimate * 100))

# --- Actual vs fitted returns ---
nvda_ff <- nvda_ff %>%
  mutate(fitted     = fitted(ff_model),
         year_month = as.Date(paste0(year_month, "-01")))

ggplot(nvda_ff, aes(x = year_month)) +
  geom_line(aes(y = nvda_return, color = "Actual")) +
  geom_line(aes(y = fitted,      color = "Fitted")) +
  labs(title = "NVDA Actual vs Fitted Returns",
       x     = "Date",
       y     = "Monthly Return",
       color = "Legend") +
  theme_minimal()

# --- 12-month rolling alpha ---
rolling_model <- rollapply(
  nvda_ff,
  width     = 12,
  FUN       = function(x) {
    df <- as.data.frame(x)
    df <- df %>% mutate(across(everything(), as.numeric))
    coef(lm(nvda_excess ~ mkt_rf + smb + hml, data = df))[1]
  },
  by.column = FALSE,
  align     = "right"
)

nvda_ff$rolling_alpha <- c(rep(NA, 11), rolling_model)

ggplot(nvda_ff, aes(x = year_month, y = rolling_alpha)) +
  geom_line(color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "NVDA 12-Month Rolling Alpha",
       x     = "Date",
       y     = "Rolling Alpha") +
  theme_minimal()

# --- Factor exposure bar chart ---
tidy(ff_model) %>%
  filter(term != "(Intercept)") %>%
  mutate(true_beta = estimate * 100) %>%
  ggplot(aes(x = term, y = true_beta, fill = true_beta > 0)) +
  geom_col() +
  geom_errorbar(aes(ymin = (estimate - std.error) * 100,
                    ymax = (estimate + std.error) * 100),
                width = 0.2) +
  labs(title = "NVDA Factor Exposures",
       x     = "Factor",
       y     = "Beta",
       fill  = "Positive") +
  theme_minimal()
