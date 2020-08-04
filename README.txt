We analyze the Taiwan 2020 election using polling data.

wrangle-data.R - creates a derived dataset and saves as R project in rda directory

TwElection.R - Uses four steps to find if polling data can correctly guess the actual spread (green-over-blue)

Step 1: Only using polldata after 25/12 95% Confidence Interval.

Step 2: Using aggregating results 95% Confidence Interval.

Step 3: New urn model with each pollster latest result

Step 4: Bayesian Model (without/with general bias)