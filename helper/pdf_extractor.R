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
#for (year in years) {
  for (month in months) {
    pdf_subset(#input = paste0(dir_source,"/",year,"/","MSR_",month,"_",year,".pdf"),
                #input = paste0(dir_source,"/",year,"/","MSR_",month,year,"_Final.pdf"),
                input = paste0(dir_source,"/",year,"/","MSR_",month,year,"_Final.pdf"),
               pages = 3:3, output = paste0(dir_save,"/",year,"/","MSR_",month,"_",year,"-3.pdf"))
  }
#}
