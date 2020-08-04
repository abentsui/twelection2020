#To load data of 2020 TW polling
load("rda/polldata.rda")

#Results in 2020 election
g <- 0.5713
b <- 0.3861
o <- 0.0426

d <- g - b


#Geom point graph group by pollster_en
polldata %>% ggplot(aes(pollster, spread)) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggsave("figs/pointPlot.png")


#Step 1: 95% Confidence Interval for each (Let's take the last week data after 25/12)
polldata %>%
  filter(enddate >= "2020-12-25") %>%
  mutate(p_hat = (spread+1)/2, se = 2*sqrt(p_hat*(1-p_hat)/samplesize)) %>%
  mutate(lower = spread + qnorm(0.025)*se, upper = spread + qnorm(0.975)*se) %>%
  mutate(hit = d >= lower & d <= upper) %>%
  select(pollster, startdate, enddate, spread, se, lower, upper, hit)


#Step 2: 95 Confidence Interval for aggregating results
d_hat <- polldata %>%
  filter(enddate >= "2020-12-25") %>%
  summarize(n = sum(samplesize), avg = sum(spread*samplesize)/sum(samplesize)) %>%
  .$avg
d_hat

p_hat <- (d_hat + 1)/2
se <- 2*sqrt(p_hat*(1-p_hat)/sum(polldata$samplesize))
se

ci <- d_hat + c(qnorm(0.025), qnorm(0.975))*se
ci


#Histogram of spread
polldata %>%
  filter(enddate >= "2020-12-25") %>%
  ggplot(aes(spread)) + geom_histogram(binwidth = 0.04, color = "black")


#Step 3: New urn model with pollster with three or more pollings
one_poll_per_pollster <- polldata %>%
  group_by(pollster) %>%
  filter(n() >= 3) %>%
  filter(enddate == max(enddate)) %>%
  ungroup(pollster)

one_poll_per_pollster %>%
  summarize(avg = mean(spread), se = sd(spread)/sqrt(length(spread))) %>%
  mutate(lower = avg + qnorm(0.025)*se, upper = avg + qnorm(0.975)*se)


#New urn model with t-distribution
#Check to see if normal
params <- one_poll_per_pollster %>%
  summarize(mean = mean(spread), sd = sd(spread))
one_poll_per_pollster %>%
  ggplot(aes(sample = spread)) +
  stat_qq(dparams = params)

#Use of t-distribution
one_poll_per_pollster %>%
  summarize(avg = mean(spread), se = sd(spread)/sqrt(length(spread)),
            moe = qt(0.975, length(spread) - 1)) %>%
  mutate(lower = avg - moe, upper = avg + moe)


#Step 4: Bayesian model (no general bias, prior mu = 0.0619, tau = 0.1628)
mu <- 0.0619
tau <- 0.1628
d_hat <- 0.288
sigma <- 0.0237
B <- sigma^2/(sigma^2 + tau^2)
posterior_mean <- mu*B + d_hat*(1-B)
posterior_se <- sqrt(1/(1/sigma^2 + 1/tau^2))

posterior_mean
posterior_se
posterior_mean + c(qnorm(0.025), qnorm(0.975))*posterior_se


#Step 5: Bayesian model (sd of general bias = 0.067)
mu <- 0.0619
tau <- 0.1628
bias_sd <- 0.067
d_hat <- 0.288
sigma <- sqrt(0.0237^2 + bias_sd^2)
B <- sigma^2/(sigma^2 + tau^2)
posterior_mean <- mu*B + d_hat*(1-B)
posterior_se <- sqrt(1/(1/sigma^2 + 1/tau^2))

posterior_mean
posterior_se
posterior_mean + c(qnorm(0.025), qnorm(0.975))*posterior_se




