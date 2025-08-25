##############################
# Quick exploratory analysis
##############################
introduce(culture_gdp_pop_vuln_co2_wvs_2020_data)
plot_intro(culture_gdp_pop_vuln_co2_wvs_2020_data)
plot_missing(culture_gdp_pop_vuln_co2_wvs_2020_data)
plot_bar(culture_gdp_pop_vuln_co2_wvs_2020_data, with = "co2_per_capita")
plot_histogram(culture_gdp_pop_vuln_co2_wvs_2020_data)
plot_density(culture_gdp_pop_vuln_co2_wvs_2020_data)
plot_correlation(culture_gdp_pop_vuln_co2_wvs_2020_data)
# Generate report
#create_report(culture_gdp_pop_vuln_co2_wvs_2020_data)

###########################
# Generalized linear model
###########################
# Family
#gaussian: Assumes the response variable follows a normal (Gaussian) distribution. The default link function is the identity link.
#binomial: Assumes the response variable is binary (0 or 1, success or failure). The default link function is the logit link.
#poisson: Assumes the response variable is a count variable. The default link function is the log link.
#gamma: Assumes the response variable is positive and continuous with a skewed distribution. The default link function is the inverse link.
#inverse.gaussian: Assumes the response variable is positive and continuous with a distribution similar to the Gaussian distribution but with a long right tail. The default link function is the inverse squared link.
#quasi: Allows for flexible modeling of the mean-variance relationship when the distribution is not known.

# Shorten name of data variable
all_data <- culture_gdp_pop_vuln_co2_wvs_2020_data 
glm_input <- subset(all_data, select = -c(iso_code, population_2020, wvs_region))
# Model 1
co2_demographic_glm1 <- glm(co2_per_capita/max(co2_per_capita) ~ (vulnerability_2020 + gdp_capita_2020)*(secular + inst_con + open_in_groups + 
                             prosocial + interest_politics + wellbeing + politic_engage + individual_rights + open_out_groups),
                           data = glm_input, family = "gaussian")
summary(co2_demographic_glm1)

# Diagnostic plots for model 1
## Residuals vs fitted
plot(co2_demographic_glm1, which = 1) # What is wrong with this plot?
## QQ plots
plot(co2_demographic_glm1, which = 2)
## Scale-location
plot(co2_demographic_glm1, which = 3)
## Cook's distance
plot(co2_demographic_glm1, which = 4)
## Breusch-Pagan test
bptest(co2_demographic_glm1)

# Model 2
co2_demographic_glm2 <- glm(log(co2_per_capita) ~ (vulnerability_2020 + log(gdp_capita_2020))*(secular + inst_con + open_in_groups + 
                                                                                                           prosocial + interest_politics + wellbeing + politic_engage + individual_rights + open_out_groups),
                            data = glm_input, family = "gaussian")
summary(co2_demographic_glm2)

# Diagnostic plots for model 2
## Residuals vs fitted
plot(co2_demographic_glm2, which = 1) # What is wrong with this plot?
## QQ plots
plot(co2_demographic_glm2, which = 2)
## Scale-location
plot(co2_demographic_glm2, which = 3)
## Cook's distance
plot(co2_demographic_glm2, which = 4)
## Breusch-Pagan test
bptest(co2_demographic_glm2)
