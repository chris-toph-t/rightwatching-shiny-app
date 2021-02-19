
chronik <- data.frame(date=character(), descr_text=character(), place=character(), sources=character(),  stringsAsFactors=FALSE)

chronik <- read.csv("dummydata/dummydata.csv")


chronik %>%
  mutate(date = as.Date(lubridate::dmy(date))) %>%
  mutate(month = as.Date(cut.Date(date, breaks = "month"))) %>%
  mutate(year = as.Date(cut.Date(date, breaks = "year"))) %>%
  mutate(week = as.Date(cut.Date(date, breaks = "week"))) -> chronik





