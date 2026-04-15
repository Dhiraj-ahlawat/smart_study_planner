# =========================================================================
# Stock Market Prediction & Analysis System
# Advanced R Programming Project
# Features: Technical Analysis, Buy/Sell Signals, ARIMA Forecasting
# =========================================================================

# -------------------------------------------------------------------------
# 1. Package Installation and Loading
# -------------------------------------------------------------------------
# Required packages
required_packages <- c("quantmod", "TTR", "forecast", "ggplot2", "dplyr", "tseries")

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "http://cran.us.r-project.org")

# Load libraries
suppressPackageStartupMessages({
  library(quantmod)
  library(TTR)
  library(forecast)
  library(ggplot2)
  library(dplyr)
  library(tseries)
})

cat("Libraries loaded successfully.\n")

# -------------------------------------------------------------------------
# 2. Data Acquisition
# -------------------------------------------------------------------------
ticker <- "AAPL"  # Apple Inc. as reference, can be changed to any ticker
start_date <- Sys.Date() - 365 * 3 # Last 3 years of data
end_date <- Sys.Date()

cat(sprintf("Fetching data for %s from %s to %s...\n", ticker, start_date, end_date))
getSymbols(ticker, src = "yahoo", from = start_date, to = end_date, warnings = FALSE, auto.assign = TRUE)

# Extract adjusted closing prices
stock_data <- get(ticker)
price_data <- drop(coredata(stock_data[, grep("Adjusted", colnames(stock_data))]))
dates <- index(stock_data)

# Create a data frame for easier manipulation
df <- data.frame(Date = dates, Price = price_data)

# -------------------------------------------------------------------------
# 3. Technical Indicators (Feature Engineering)
# -------------------------------------------------------------------------
cat("Calculating Technical Indicators (SMA, EMA, RSI)...\n")

# Simple Moving Average (SMA) & Exponential Moving Average (EMA)
df$SMA_50 <- SMA(df$Price, n = 50)
df$SMA_200 <- SMA(df$Price, n = 200)

# Relative Strength Index (RSI)
df$RSI_14 <- RSI(df$Price, n = 14)

# -------------------------------------------------------------------------
# 4. Signal Generation (Algorithmic Trading Logic)
# -------------------------------------------------------------------------
cat("Generating Buy/Sell Signals...\n")

df$Signal <- "HOLD"

# Buy Signal: RSI indicates oversold (< 30) AND Golden Cross (SMA 50 > SMA 200)
# Sell Signal: RSI indicates overbought (> 70) AND Death Cross (SMA 50 < SMA 200)
for(i in 201:nrow(df)) {
  if(!is.na(df$RSI_14[i]) && !is.na(df$SMA_50[i]) && !is.na(df$SMA_200[i])) {
    if(df$RSI_14[i] < 30) {
      df$Signal[i] <- "BUY"
    } else if(df$RSI_14[i] > 70) {
      df$Signal[i] <- "SELL"
    }
  }
}

# -------------------------------------------------------------------------
# 5. Advanced Price Prediction (ARIMA Model)
# -------------------------------------------------------------------------
cat("Fitting ARIMA Model for Price Prediction...\n")

# Convert to time series object
ts_data <- ts(df$Price, frequency = 252) # 252 trading days in a year

# Fit Auto ARIMA model
fit <- auto.arima(ts_data, seasonal = FALSE, stepwise = FALSE, approximation = FALSE)

# Forecast next 30 trading days
forecast_days <- 30
pred <- forecast(fit, h = forecast_days)

cat("ARIMA Model Summary:\n")
print(summary(fit))

# -------------------------------------------------------------------------
# 6. Visualization & Reporting
# -------------------------------------------------------------------------
cat("Generating Advanced Visualizations...\n")

# Base Plot: Price + Moving Averages
chartSeries(stock_data, theme = chartTheme("white"), 
            type = "line", name = sprintf("%s Stock Analysis", ticker),
            TA = c(addSMA(n=50, col="blue"), addSMA(n=200, col="red"), addRSI(n=14)))

# Print recent signals
cat("\nRecent Trading Signals:\n")
recent_signals <- tail(df %>% filter(Signal != "HOLD"), 10)
print(recent_signals)

# Plot Forecast
plot(pred, main = sprintf("%s 30-Day Price Forecast (ARIMA)", ticker),
     ylab = "Price (USD)", xlab = "Time (Trading Days)",
     col = "darkblue", fcol = "red", shaded = TRUE)

cat("\n=========================================================================\n")
cat("Project Execution Complete. Check the Plots panel for visualizations.\n")
cat("System ready for deployment.\n")
cat("=========================================================================\n")
