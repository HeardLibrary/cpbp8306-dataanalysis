####################################################
# Filter data for Principle Component Analysis (PCA)
####################################################
pca_input <- subset(culture_gdp_pop_vuln_co2_wvs_2020_data, select = c(vulnerability_2020:open_out_groups))
pca_output <- PCA(pca_input, scale.unit = TRUE, ncp = 6, graph = FALSE)

##################################
# Multiple Factor Analysis (MFA)
##################################
#combined_2022_media_demographics_ukraine.mfa <- MFA(input,
#                                                    group = c(1,1,1),
#                                                    name.group = c("var1", "var2", "var3"),
#                                                    type = c("n","c","i"), graph = FALSE)

# Extract and write results for individuals to CSV
pca_output_sum <- facto_summarize(pca_output, element = "ind")

# Extract row results
pca_output_eig <- get_eigenvalue(pca_output)
pca_output_eig
pca_output_ind <- get_pca_ind(pca_output)
pca_output_ind$contrib
pca_output_var <- get_pca_var(pca_output)
pca_output_var$contrib

# Screeplot
scree_plot <- fviz_screeplot(pca_output, addlabels = TRUE)
scree_plot

# Variable biplots
pca_biplot_1_2 <- fviz_pca_var(pca_output, choice="group")
pca_biplot_1_2
pca_biplot_1_2 <- fviz_pca_var(pca_output, col.var = "cos2",
                               gradient.cols = c("black", "orange", "green"),
                               repel = TRUE)
pca_biplot_1_2
pca_biplot_1_3 <- fviz_pca_var(pca_output, axes=c(1,3), choice="group")
pca_biplot_1_3

# Barplots of contributions
pca_dim1_contrib <- fviz_contrib(pca_output, choice="var", axes = 1, top=30)
pca_dim1_contrib
pca_dim2_contrib <- fviz_contrib(pca_output, choice="var", axes = 2, top=30)
pca_dim2_contrib
pca_dim3_contrib <- fviz_contrib(pca_output, choice="var", axes = 3, top=30)
pca_dim3_contrib

# Dimension descriptions
pca_desc <- dimdesc(pca_output, axes = c(1,2,3), proba = 0.05)
pca_desc$Dim.1$quanti
pca_desc$Dim.2$quanti
pca_desc$Dim.3$quanti

# Add dimensions to original data
all_data <- culture_gdp_pop_vuln_co2_wvs_2020_data 
all_data$dim_1 <- pca_output_ind$coord[,1]
all_data$dim_2 <- pca_output_ind$coord[,2]
all_data$dim_3 <- pca_output_ind$coord[,3]

###################################
# Compare dimensions to WVS region
###################################
# Theme
wvs_theme <- theme(plot.title = element_text(face="bold",size=24),
                   legend.position = "bottom",
                   legend.title = element_text(face="bold", size=14),
                   legend.text=element_text(size=12),
                   legend.title.position = "top",
                   axis.title.x = element_text(color="black",size=21,face="bold"),
                   axis.title.y = element_text(color="black",size=21,face="bold"),
                   axis.text.x = element_text(color="black",size=16, angle=0),
                   axis.text.y = element_text(color="black",size=16, angle=0),
                   strip.text.x = element_text(size = 18, color="black",face="bold"),
                   strip.text.y = element_text(size = 18, color="black",face="bold"))
# Individual coordinates plot
## Define factor for grouping
all_data_plot <- all_data
all_data_plot$wvs_region <- factor(all_data$wvs_region, levels = c("latin.america", "orthodox", "confucian", "catholic.europe",
                                                                   "south.asia", "african.islamic", "protestant.europe", "english.speaking",
                                                                   "baltic"),
                              labels = c("Latin America", "Orthodox", "Confucian", "Catholic Europe",
                                         "South Asia", "African Islamic", "Protestant Europe", "English Speaking",
                                         "Baltic"))
## Plot
wvs_ind_plot <- ggplot(all_data_plot, aes(x=dim_1, y=dim_2, color=wvs_region, label=iso_code)) +
                       geom_point(size=3, alpha = 0.5) +
                       geom_text_repel(size=5) +
                       geom_vline(xintercept = 0, linetype = "dotted") + 
                       geom_hline(yintercept = 0, linetype = "dotted") + 
                       scale_x_continuous(breaks = -3:5) +
                       scale_y_continuous(breaks = -3:5) +
                       scale_color_manual(values = c("black", "blue", "red", "violet", "orange", 
                                                     "lightblue", "green", "maroon", "yellow")) +
                       labs(title="WVS individual coordinates", x="Dimension 1", y="Dimension 2", color="WVS region") + 
                       #coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) + # Zoom in to area of plot
                       theme_classic() + wvs_theme + guides(color = guide_legend(nrow = 3))
# Variable coordinates plot
## Change row labels to column
var_coord <- rownames_to_column(data.frame(pca_output_var$coord), "var_labels")
## Define factor for grouping
var_coord_plot$var_labels <- factor(var_coord$var_labels, 
                                    levels = c("vulnerability_2020", "population_2020", "gdp_capita_2020", "secular", "inst_con",           
                                               "open_in_groups", "prosocial", "interest_politics", "wellbeing", "politic_engage",    
                                               "individual_rights", "open_out_groups"),
                                    labels = c("Vulnerability", "Population", "GDP per capita", "Secular", "Institutional confidence",           
                                               "Openness in groups", "Prosocial", "Interest in politics", "Wellbeing", "Political engagement",    
                                               "Individual rights", "Openness out groups"))
## Plot
wvs_var_plot <- ggplot(var_coord_plot, aes(x=Dim.1, y=Dim.2, label=var_labels)) +
  geom_point(size=3) +
  geom_text_repel(size=5) +
  geom_vline(xintercept = 0, linetype = "dotted") + 
  geom_hline(yintercept = 0, linetype = "dotted") + 
  scale_x_continuous(breaks = -3:5) +
  scale_y_continuous(breaks = -3:5) +
  labs(title="WVS variable coordinates", x="Dimension 1", y="Dimension 2") + 
  theme_classic() + wvs_theme + guides(color = guide_legend(nrow = 3))
# Combine plots
wvs_ind_var_plot <- wvs_ind_plot | wvs_var_plot
# Save plot
ggsave("output/wvs_ind_var_plot.png", plot = wvs_ind_var_plot, scale = 1, width = 13, height = 8,
       dpi = 300,limitsize = TRUE)

######################################
# Compare dimensions to CO2 per capita
######################################
# Theme
co2_theme <- theme(plot.title = element_text(face="bold",size=24),
                   legend.position = "bottom",
                   legend.title = element_text(face="bold", size=14),
                   legend.text=element_text(size=12),
                   legend.title.position = "top",
                   axis.title.x = element_text(color="black",size=21,face="bold"),
                   axis.title.y = element_text(color="black",size=21,face="bold"),
                   axis.text.x = element_text(color="black",size=16, angle=0),
                   axis.text.y = element_text(color="black",size=16, angle=0),
                   strip.text.x = element_text(size = 18, color="black",face="bold"),
                   strip.text.y = element_text(size = 18, color="black",face="bold"))
# Plots
model1 <- lm(co2_per_capita ~ dim_1, data = all_data_plot)
summary(model)
co2_dim1_plot <- ggplot(all_data_plot, aes(x=dim_1, y=co2_per_capita, color=wvs_region, label = iso_code)) +
  geom_point(size=3) +
  geom_text_repel() +
  geom_smooth(method = "lm", color="red") +
  scale_x_continuous(breaks = -3:5) +
  scale_y_continuous() +
  labs(x="Dimension 1", y="CO2 per capita", color="WVS Region") + 
  theme_classic() + co2_theme + guides(color = guide_legend(nrow = 3)) +
  annotate("text", x = -3, y = 22, size = 5,label = paste("R2 = ", round(summary(model1)$r.squared, 2), "\n", 
                                                         "p = ", round(summary(model1)$coefficients[8], 4)))
model2 <- lm(co2_per_capita ~ dim_2, data = all_data_plot)
summary(model)
co2_dim2_plot <- ggplot(all_data_plot, aes(x=dim_2, y=co2_per_capita, color=wvs_region, label = iso_code)) +
  geom_point(size=3) +
  geom_text_repel() +
  geom_smooth(method = "lm", color="red") +
  scale_x_continuous(breaks = -3:5) +
  scale_y_continuous() +
  labs(x="Dimension 2", y="CO2 per capita", color="WVS Region") + 
  theme_classic() + co2_theme + theme(legend.position = "none") + guides(color = guide_legend(nrow = 3)) +
  annotate("text", x = -2, y = 22, size = 5,label = paste("R2 = ", round(summary(model2)$r.squared, 2), "\n", 
                                                          "p = ", round(summary(model2)$coefficients[8], 4)))
# Combine plots
co2_plot <- co2_dim1_plot | co2_dim2_plot
# Save plot
ggsave("output/co2_plot.png", plot = co2_plot, scale = 1, width = 12, height = 7,
       dpi = 300,limitsize = TRUE)

