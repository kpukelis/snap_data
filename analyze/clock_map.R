# libraries
library(ggplot2)
library(ggthemes)
library(maps)
library(readxl)
library(dplyr)
library(mapproj)

# load data
clocks <- read_excel(path = "C:/Users/Kelsey/Google Drive/Harvard/research/time_limits/snap_time_limits.xlsx", sheet = "clocks_only")
states <- map_data(map = "state")

# merge
merged <- left_join(clocks, states, by = c("state" = "region"))

# map 
ggplot(data = merged) +
  geom_polygon(aes(x = long,y = lat, group = group, fill = `clock type`), color = "white") +
  coord_map() + theme_map() +
  theme(legend.position = "bottom")
