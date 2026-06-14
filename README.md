# Fama-French Three-Factor Model - NVIDIA (NVDA)

This project applies the Fama-French Three-Factor Model to NVIDIA stock
using R. The model estimates how much of NVDA's return is explained by
market, size, and value factors, and how much is genuine alpha.

Built as part of my self-directed learning in quantitative finance.
Tools used: R, tidyquant, frenchdata, ggplot2.

## Key Findings

**Alpha (Intercept: 0.034, p < 0.001)**
NVIDIA generates 3.4% per month in statistically significant alpha, which is excess return that cannot be explained by any of the three standard market factors.
Annualised, this represents approximately 50% per year of unexplained outperformance.

**Market Beta (1.73, p < 0.001)**
Nvidia is highly sensitive to broad market movements. For every 1% the market moves, Nvidia moves by 1.73% in the same direction.
This reflects its status as a high growth technology company where investor sentiment amplifies both gains and losses relative to the market.

**SMB Beta (-0.17, not significant)**
Nvidia shows no statistically meaningful size tilt. Despite it being a mega cap company, its return behaviour does not significantly resemble either small or large cap stocks.
This factor simply does not explain Nvidia's returns.

**HML Beta (-0.95, p < 0.001)**
The data strongly confirms that Nvidia is a growth stock. Investors price it on future earnings potential rather than current book value.
This is consistent with a company whose competitive position in the AI hardware industry commands an enormous market premium. 

**R-squared: 0.42**
Only 42% of Nvidia's monthly returns are explained by the three Fama-French factors.
The remaining 58% is entirely company specific. Driven by product launches, AI infrastructure demand, competitive positioning, and events no standard factor model can anticipate.

**Rolling Alpha Analysis**
Alpha was not constant across the period.
Three distinct regimes emerged: The 2016-2017 gaming and early AI boom, the 2018-2019 crypto bust where alpha turned sharply negative, and the 2023 onwards generative AI revolution. 
The recent decline towards zero alpha suggests Nvidia's extraordinary returns are increasingly being priced into broader market and sector movements.
This is a classical example of alpha decay.

