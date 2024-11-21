# Load libraries
library(pacman)
pacman::p_load(tidyverse,dplyr,plyr,scales,lubridate,readxl,gdata,gplots,
               GGally,ggpubr,sf,geofacet,ggmap,viridis,RColorBrewer,patchwork,ggpmisc,usmap,tigris)

#######################
#    Download data    #
#######################
# Download and load county data
download.file(url="https://static.usafacts.org/public/data/covid-19/covid_confirmed_usafacts.csv", destfile="data/covid_confirmed_usafacts.csv", method = "auto", quiet=TRUE)
covidByCounty <- read.csv("data/covid_confirmed_usafacts.csv")
# Download and load death data
download.file(url="https://static.usafacts.org/public/data/covid-19/covid_deaths_usafacts.csv", destfile="data/covid_deaths_usafacts.csv", method = "auto", quiet=TRUE)
deathsByCounty <- read.csv("data/covid_deaths_usafacts.csv")
# Census population data by county
download.file(url="https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv", destfile="data/population.csv", method = "auto", quiet=TRUE)
population <- read.csv("data/population.csv")
# Download and load FIPS data
countyfips <- us_map("counties")
statefips <- us_map("states")


##################################
#       Get coordinate data      #
##################################
usa <- map_data("usa")
states <- map_data("state")
counties <- map_data("county")
south <- subset(states, region %in% c("tennessee","kentucky","virginia","north carolina",
                                      "georgia","alabama","mississippi","arkansas","missouri"))
south_counties <- subset(counties, region %in% c("tennessee","kentucky","virginia",
                                                 "north carolina","georgia","alabama","mississippi",
                                                 "arkansas","missouri"))

############################################################
#       Combine FIPS data for merger with coordinates      #
############################################################
names(statefips)[names(statefips) == "fips"] <- "statefips"

# Create dataframe with combined state and county FIPS data
usfips <- st_join(countyfips,statefips, by = c("abbr"))
usfips$combined_fips <- with(usfips,paste0(statefips,fips))
usfips <- usfips %>% select(-c(abbr.y,full.y))
names(usfips)[names(usfips) == "abbr.x"] <- "abbr"
names(usfips)[names(usfips) == "full.x"] <- "full"


# Combine state and county into single column and remove spaces and periods
usfips$statecounty <- with(usfips,paste0(tolower(full),
                                         tolower(substring(countyfips$county,1,
                                                           (nchar(as.character(countyfips$county))-7)))))
usfips$statecounty <- str_replace_all(usfips$statecounty," ","")
usfips$statecounty <- str_replace_all(usfips$statecounty,"[.]","")

############################################################
#            Combine coordinate and FIPS data              #
############################################################
# Extract unique elements from south counties data
south_counties$state <- state.abb[match(south_counties$region,tolower(state.name))]
south_counties$stateFIPS <- statefips$statefips[match(south_counties$state,statefips$abbr)]
south_counties$statecounty <- with(south_counties,paste0(region,subregion))
south_counties$statecounty <- str_replace_all(south_counties$statecounty," ","")
south_counties$statecounty <- str_replace_all(south_counties$statecounty,"[.]","")
south_counties$countyFIPS <- usfips$fips[match(south_counties$statecounty,usfips$statecounty)]

############################################################
#               Combine with population data               #
############################################################
population$CTYNAME <- str_replace_all(as.character(population$CTYNAME),"[\xf1]","n")
population$statecounty <- with(population,paste0(STNAME,CTYNAME))
population$statecounty <- substring(population$statecounty,1,nchar(as.character(population$statecounty))-7)
population$statecounty <- tolower(population$statecounty)
population$statecounty <- str_replace_all(population$statecounty," ","")
population$statecounty <- str_replace_all(population$statecounty,"[.]","")
south_counties$population <- population$POPESTIMATE2019[match(south_counties$statecounty,population$statecounty)]
  
############################################################
#       Combine with COVID-19 count and death data         #
############################################################
south_counties$countyFIPS <- as.numeric(south_counties$countyFIPS)
south_counties_covid <- left_join(south_counties, covidByCounty, by = "countyFIPS")
south_counties_death <- left_join(south_counties, deathsByCounty, by = "countyFIPS")

colnames(south_counties_covid) <- c(colnames(south_counties_covid[1:12]),
                                  substring(colnames(subset(south_counties_covid,
                                                            select=-c(long,lat,group,order,region,
                                                                      subregion,state,stateFIPS,statecounty,
                                                                      countyFIPS,County.Name,State))),2))

colnames(south_counties_death) <- colnames(south_counties_covid)

############################################################
#          Create base coordinates for ggplots             #
############################################################
south_base <- ggplot(south) + 
  geom_polygon(mapping=aes(x = long, y = lat, group = group), fill = "palegreen", color = "black") + 
  coord_fixed(1.3)
ditch_the_axes <- theme(
  plot.title = element_text(face="bold",color="black",size=24),
  plot.subtitle = element_text(face="bold",color="red",size=20),
  plot.caption = element_text(hjust = 0,face="bold",color="blue",size=16),
  legend.title = element_text(face="bold",size=20),
  legend.text = element_text(face="bold",size=16),
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank())

# Backup dataframes
# Filter counties for calcuations in plots
south_counties_covid2 <- south_counties_covid
south_counties_death2 <- south_counties_death
cases_distinct <- subset(south_counties_covid,select=-c(long,lat,group,order)) %>% distinct()
death_distinct <- subset(south_counties_death,select=-c(long,lat,group,order)) %>% distinct()

########################################
#    ggplot2 loop to create images     #
########################################
#dates <- colnames(subset(south_counties_covid,select=-c(long,lat,group,order,region,
#                                                        subregion,state,stateFIPS,statecounty,
#                                                        countyFIPS,County.Name,State,`1.22.20`:`3.2.20`)))
start <- match("2020.03.03",names(south_counties_covid))
end <- match("2020.09.03",names(south_counties_covid))
dates <- colnames(south_counties_covid)[start:end]

for (date in dates) {
##############################
#   Totals covid cases/deaths   #
##############################
  num <- match(date,names(south_counties_covid2))
  per <- match(date,dates);print(paste(ceiling((per/length(dates))*100),"% complete",sep=""))
  
#  south_counties_covid2[num][south_counties_covid2[num]==0]  <- 0.5
  south_counties_covid_plot <- south_base + theme_bw() + ditch_the_axes + 
    geom_polygon(south_counties_covid2,mapping=aes(x = long, y = lat, group = group, 
                                                 fill = unlist(south_counties_covid2[num])/population*1000), 
                 color = "white") +
    scale_fill_gradient2(limits = c(0,20),breaks= c(0,10,20),midpoint=10,na.value="white", low="white",mid="orange",high="red", space ="Lab") + 
    geom_polygon(south,mapping=aes(x = long, y = lat, group = group),color = "black", fill = NA) +
    labs(title=paste("Total corona cases"),subtitle=paste(date), x="", y="",color="",
         caption=paste("Alabama= ",floor(sum(na.omit(subset(cases_distinct,region=="alabama")[num-4])))," | ",
                       "Arkansas= ",floor(sum(na.omit(subset(cases_distinct,region=="arkansas")[num-4])))," | ",
                       "Georgia= ",floor(sum(na.omit(subset(cases_distinct,region=="georgia")[num-4])))," | ",
                       "Kentucky= ",floor(sum(na.omit(subset(cases_distinct,region=="kentucky")[num-4])))," | ",
                       "Missouri= ",floor(sum(na.omit(subset(cases_distinct,region=="missouri")[num-4]))),"
  ",
                       "Mississippi= ",floor(sum(na.omit(subset(cases_distinct,region=="mississippi")[num-4])))," | ",
                       "North Carolina= ",floor(sum(na.omit(subset(cases_distinct,region=="north carolina")[num-4])))," | ",
                       "Tennessee= ",floor(sum(na.omit(subset(cases_distinct,region=="tennessee")[num-4])))," | ",
                       "Virginia= ",floor(sum(na.omit(subset(cases_distinct,region=="virginia")[num-4])))," | ",
                       "Total cases= ", floor(sum(na.omit(cases_distinct[num-4])))),
         fill=paste("cases per
1000 people"))
  
#  south_counties_death2[num][south_counties_death2[num]==0]  <- 0.5
  south_counties_death_plot <- south_base + theme_bw() + ditch_the_axes + 
    geom_polygon(south_counties_death2,mapping=aes(x = long, y = lat, group = group, 
                                                 fill = unlist(south_counties_death2[num])/population*1000), 
                 color = "white") +
    scale_fill_gradient2(limits = c(0,2),breaks= c(0,1,2),midpoint=1,na.value="white", low="white",mid="orange",high="red", space ="Lab") + 
    geom_polygon(south,mapping=aes(x = long, y = lat, group = group),color = "black", fill = NA) +
    labs(title=paste("Total corona deaths"),subtitle=paste(date),x="", y="",color="",
         caption=paste("Alabama= ",floor(sum(na.omit(subset(death_distinct,region=="alabama")[num-4])))," | ",
                       "Arkansas= ",floor(sum(na.omit(subset(death_distinct,region=="arkansas")[num-4])))," | ",
                       "Georgia= ",floor(sum(na.omit(subset(death_distinct,region=="georgia")[num-4])))," | ",
                       "Kentucky= ",floor(sum(na.omit(subset(cases_distinct,region=="kentucky")[num-4])))," | ",
                       "Missouri= ",floor(sum(na.omit(subset(death_distinct,region=="missouri")[num-4]))),"
  ",
                       "Mississippi= ",floor(sum(na.omit(subset(death_distinct,region=="mississippi")[num-4])))," | ",
                       "North Carolina= ",floor(sum(na.omit(subset(death_distinct,region=="north carolina")[num-4])))," | ",
                       "Tennessee= ",floor(sum(na.omit(subset(death_distinct,region=="tennessee")[num-4])))," | ",
                       "Virginia= ",floor(sum(na.omit(subset(death_distinct,region=="virginia")[num-4])))," | ",
                       "Total cases= ", floor(sum(na.omit(death_distinct[num-4])))),
         fill=paste("deaths per
1000 people"))
  
##############################
#   New covid cases/deaths   #
##############################
#  south_counties_covid2[num][south_counties_covid2[num]==0]  <- 0.5
  new_covid_plot <- south_base + theme_bw() + ditch_the_axes + 
    geom_polygon(south_counties_covid2,mapping=aes(x = long, y = lat, group = group, 
                                                   fill = (unlist(south_counties_covid2[num])-unlist(south_counties_covid2[num-1]))), 
                 color = "white") +
    scale_fill_gradient2(limits = c(0,100),breaks= c(0,50,100),midpoint=50,na.value="white", low="white",mid="orange",high="red", space ="Lab") + 
    geom_polygon(south,mapping=aes(x = long, y = lat, group = group),color = "black", fill = NA) +
    labs(title=paste("New corona cases"),subtitle=paste(date),x="", y="",color="",
         caption=paste("Alabama= ",(floor(sum(na.omit(subset(cases_distinct,region=="alabama")[num-4]))-sum(na.omit(subset(cases_distinct,region=="alabama")[num-5]))))," | ",
                       "Arkansas= ",(floor(sum(na.omit(subset(cases_distinct,region=="arkansas")[num-4]))-sum(na.omit(subset(cases_distinct,region=="arkansas")[num-5]))))," | ",
                       "Georgia= ",(floor(sum(na.omit(subset(cases_distinct,region=="georgia")[num-4]))-sum(na.omit(subset(cases_distinct,region=="georgia")[num-5]))))," | ",
                       "Kentucky= ",(floor(sum(na.omit(subset(cases_distinct,region=="kentucky")[num-4]))-sum(na.omit(subset(cases_distinct,region=="kentucky")[num-5]))))," | ",
                       "Missouri= ",(floor(sum(na.omit(subset(cases_distinct,region=="missouri")[num-4]))-sum(na.omit(subset(cases_distinct,region=="missouri")[num-5])))),"
  ",
                       "Mississippi= ",(floor(sum(na.omit(subset(cases_distinct,region=="mississippi")[num-4]))-sum(na.omit(subset(cases_distinct,region=="mississippi")[num-5]))))," | ",
                       "North Carolina= ",(floor(sum(na.omit(subset(cases_distinct,region=="north carolina")[num-4]))-sum(na.omit(subset(cases_distinct,region=="north carolina")[num-5]))))," | ",
                       "Tennessee= ",(floor(sum(na.omit(subset(cases_distinct,region=="tennessee")[num-4]))- sum(na.omit(subset(cases_distinct,region=="tennessee")[num-5]))))," | ",
                       "Virginia= ",(floor(sum(na.omit(subset(cases_distinct,region=="virginia")[num-4]))-sum(na.omit(subset(cases_distinct,region=="virginia")[num-5]))))," | ",
                       "Total cases= ", (floor(sum(na.omit(cases_distinct[num-4]))-sum(na.omit(cases_distinct[num-5]))))),
         fill="new cases")
  
#  south_counties_death2[num][south_counties_death2[num]==0]  <- 0.5
  new_death_plot <- south_base + theme_bw() + ditch_the_axes + 
    geom_polygon(south_counties_death2,mapping=aes(x = long, y = lat, group = group, 
                                                   fill = (unlist(south_counties_death2[num])-unlist(south_counties_death2[num-1]))), 
                 color = "white") +
    scale_fill_gradient2(limits = c(0,10),breaks= c(0,5,10),midpoint=5,na.value="white", low="white",mid="orange",high="red", space ="Lab") + 
    geom_polygon(south,mapping=aes(x = long, y = lat, group = group),color = "black", fill = NA) +
    labs(title=paste("New corona deaths"),subtitle=paste(date),x="", y="",color="",
         caption=paste("Alabama= ",(floor(sum(na.omit(subset(death_distinct,region=="alabama")[num-4]))- sum(na.omit(subset(death_distinct,region=="alabama")[num-5]))))," | ",
                       "Arkansas= ",(floor(sum(na.omit(subset(death_distinct,region=="arkansas")[num-4]))-sum(na.omit(subset(death_distinct,region=="arkansas")[num-5]))))," | ",
                       "Georgia= ",(floor(sum(na.omit(subset(death_distinct,region=="georgia")[num-4]))-sum(na.omit(subset(death_distinct,region=="georgia")[num-5]))))," | ",
                       "Kentucky= ",(floor(sum(na.omit(subset(death_distinct,region=="kentucky")[num-4]))-sum(na.omit(subset(death_distinct,region=="kentucky")[num-5]))))," | ",
                       "Missouri= ",(floor(sum(na.omit(subset(death_distinct,region=="missouri")[num-4]))-sum(na.omit(subset(death_distinct,region=="missouri")[num-5])))),"
  ",
                       "Mississippi= ",(floor(sum(na.omit(subset(death_distinct,region=="mississippi")[num-4]))-sum(na.omit(subset(death_distinct,region=="mississippi")[num-5]))))," | ",
                       "North Carolina= ",(floor(sum(na.omit(subset(death_distinct,region=="north carolina")[num-4]))-sum(na.omit(subset(death_distinct,region=="north carolina")[num-5]))))," | ",
                       "Tennessee= ",(floor(sum(na.omit(subset(death_distinct,region=="tennessee")[num-4]))-sum(na.omit(subset(death_distinct,region=="tennessee")[num-5]))))," | ",
                       "Virginia= ",(floor(sum(na.omit(subset(death_distinct,region=="virginia")[num-4]))-sum(na.omit(subset(death_distinct,region=="virginia")[num-5]))))," | ",
                       "Total deaths= ", (floor(sum(na.omit(death_distinct[num-4]))-sum(na.omit(death_distinct[num-5]))))),
         fill="new deaths")
  
  covid_count_deaths <- ((south_counties_covid_plot | new_covid_plot ) / (south_counties_death_plot | new_death_plot))
 
# Create number for labeling files
  print_num <- ifelse(nchar(per)==1, paste("00",per,sep=""),
                      ifelse(nchar(per)==2,paste("0",per,sep=""),
                             ifelse(nchar(per)==3,paste(per),NA)))
  
# Export to PNG
  ggexport(plotlist = list(covid_count_deaths),
           filename = paste("plots/gif_pop/count_deaths_",print_num,".png",sep=""),height=1400,width=2000)
}

system("convert -delay 20 plots/gif_pop/*.png plots/south_covid_pop.gif")
