###########################
# Generalized linear model
###########################
glm_input <- subset(all_data, select = -c(iso_code, population_2020, wvs_region))
co2_demographic_glm <- glm(co2_per_capita/max(co2_per_capita) ~ vulnerability_2020 + gdp_capita_2020 + secular + inst_con + open_in_groups + 
                           prosocial + interest_politics + wellbeing + politic_engage + individual_rights + open_out_groups,
                           data = glm_input, family = "gaussian")
summary(co2_demographic_glm)
co2_demographic_glm <- glm(co2_per_capita/max(co2_per_capita) ~ (vulnerability_2020 + gdp_capita_2020)*(secular + inst_con + open_in_groups + 
                             prosocial + interest_politics + wellbeing + politic_engage + individual_rights + open_out_groups),
                           data = glm_input, family = "gaussian")
summary(co2_demographic_glm)
co2_demographic_glm <- glm(co2_per_capita/max(co2_per_capita) ~ (dim_1 + dim_2)*(vulnerability_2020 + gdp_capita_2020 + secular + 
                                                                 inst_con + open_in_groups + prosocial + interest_politics + wellbeing + 
                                                                 politic_engage + individual_rights + open_out_groups),
                           data = glm_input, family = family = "gaussian")
summary(co2_demographic_glm)
