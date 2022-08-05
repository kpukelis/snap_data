library(pdftools)

# ohio
dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/ohio/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/ohio/pdfs_short"

#page_range <- 7:9
page_range <- 6:7
year <- 2022

months <- c(
   "January",
    "February",
    "March",
  "April",
  "May","June",
  "July","August","September",
  "October",
  "November",
  "December")


#for (year in years) {
for (month in months) {
  pdf_subset(input = paste0(dir_source,"/",year,"/Caseload Summary Report ",month," ",year,".pdf"),
             pages = page_range, 
             output = paste0(dir_save,"/",year,"/Caseload Summary Report ",month," ",year,".pdf")
  )
}
#}


# newjersey
dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newjersey/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newjersey/pdfs_short"

page_range <- 12:12
year <- 2021
year_short <- 21
months <- c(
 # "jan",
#  "feb",
#  "mar",
  #"apr",
#"may","jun",
#"jul","aug","sep",
#"oct",
#"nov",
"dec")


#for (year in years) {
for (month in months) {
  pdf_subset(input = paste0(dir_source,"/",year,"/cps_",month,year_short,".pdf"),
             pages = page_range, 
             output = paste0(dir_save,"/",year,"/cps_",month,year_short,".pdf_short.pdf"),
  )
}
#}


# arizona
dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/arizona/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/arizona/pdfs_short"

page_range <- 6:6
year <- 2022
months <- c(
  "01",
  "02",
  "03",
"04")
#"05","06",
#"07","08","09",
#"10",
#"11","12")


#for (year in years) {
for (month in months) {
  pdf_subset(input = paste0(dir_source,"/",year,"/dbme-statistical_bulletin-",month,"-",year,".pdf"),
             pages = page_range, 
             output = paste0(dir_save,"/",year,"/dbme_statistical_bulletin-",month,"-",year,".pdf"),
  )
}
#}




# missouri
dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/missouri/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/missouri/pdfs_short"

year <- 2022
year_short <- 22
months <- c(
  "01","02","03","04")
  #"04","05","06",
  #"07","08","09",
  #"10","11","12")
#page_range <- 151:159
#page_range <- 147:155
page_range <- 21:27


#for (year in years) {
for (month in months) {
  pdf_subset(input = paste0(dir_source,"/",year,"/",month,year_short,"-family-support-mohealthnet-report.pdf"),
             pages = page_range, 
             output = paste0(dir_save,"/",year,"/",month,year_short,"-family-support-mohealthnet-report.pdf"))
}
#}

# new mexico - race 

dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newmexico/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newmexico/pdfs_short_race"

years <- 2015:2017
#year <- 2018
months <- c(
  "January",
  "February","March","April","May","June","July",
  "August","September","October","November","December")
months <- c(
"01",
"02","03",
"04","05","06",
"07",
"08","09",
"10","11","12")
page_range <- 4:4

#month <- "January"
for (year in years) {
for (month in months) {
  pdf_subset(#input = paste0(dir_source,"/",year,"/","MSR_",month,"_",year,".pdf"),
    #input = paste0(dir_source,"/",year,"/","MSR_",month,year,"_Final.pdf"),
    input = paste0(dir_source,"/",year,"/","MSR_",month,"_",year,".pdf"),
    pages = page_range, output = paste0(dir_save,"/",year,"/","MSR_",month,"_",year,".pdf"))
}
}

# new mexico

dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newmexico/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newmexico/pdfs_short"

years <- 2013:2018
year <- 2018
months <- c(
            #"January",
            #"February","March","April","May","June","July",
            "August","September","October","November","December")

#month <- "January"
for (year in years) {
  for (month in months) {
    pdf_subset(#input = paste0(dir_source,"/",year,"/","MSR_",month,"_",year,".pdf"),
                #input = paste0(dir_source,"/",year,"/","MSR_",month,year,"_Final.pdf"),
                input = paste0(dir_source,"/",year,"/","MSR_",month,year,"_Final.pdf"),
               pages = 3:3, output = paste0(dir_save,"/",year,"/","MSR_",month,"_",year,"-3.pdf"))
  }
}

# new mexico - apps

dir_source <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newmexico/pdfs"
dir_save <- "G:/My Drive/Harvard/research/time_limits/data/state_data/newmexico/pdfs_short_apps"

years <- 2019:2022
#year <- 2018
months <- c(
  "January",
  "February","March","April","May","June","July",
  "August","September",
  "October",
  "November","December")
#months <- c(
  #"01","02","03")
#"04","05","06",
#"06","07",
#"08","09",
#"10","11","12")

page_range <- 5:5
page_range <- c(23,25,27,34,35) # for 2018m10-2022m5+
#page_range <- c(21,23,25,31,32) # for 2017m11-2018m9
# 2017m4-2017m10 is complicated, do it manually
page_range <- 20:20 # for 2016m7-2017m3
page_range <- 21:21 # for 2014m8-2016m6
page_range <- 23:23 # for 2014m2-2014m7
page_range <- 43:43 # for 2013m1-2013m6



for (year in years) {
for (month in months) {
  pdf_subset(#input = paste0(dir_source,"/",year,"/","MSR_",month,"_",year,".pdf"),
    #input = paste0(dir_source,"/",year,"/","MSR_",month,year,"_Final.pdf"),
    input = paste0(dir_source,"/",year,"/","MSR_",month,"_",year,".pdf"),
    pages = page_range, output = paste0(dir_save,"/",year,"/","MSR_",month,"_",year,"_apps.pdf"))
}
}
