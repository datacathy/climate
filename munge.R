# munge the GHCN QCA data to get tavg.csv which I can then play with

setwd("~/Documents/DataScience/Projects/Weather/qca/ghcnm.v3.3.0.20170122")
raw <- readLines("ghcnm.tavg.v3.3.0.20170122.qca.dat")

N = length(raw)
for (i in 1:N) {
  s <- raw[i]
  x <- data.frame(ID = substr(s, 1, 11), YEAR = as.integer(substr(s, 12, 15)),
                  JAN = as.double(substr(s, 20, 24))/100.0, DMF01 = substr(s, 25, 25), QCF01 = substr(s, 26, 26), DSF01 = substr(s, 27, 27),
                  FEB = as.double(substr(s, 28, 32))/100.0, DMF02 = substr(s, 33, 33), QCF02 = substr(s, 34, 34), DSF02 = substr(s, 35, 35),
                  MAR = as.double(substr(s, 36, 40))/100.0, DMF03 = substr(s, 41, 41), QCF03 = substr(s, 42, 42), DSF03 = substr(s, 43, 43),
                  APR = as.double(substr(s, 44, 48))/100.0, DMF04 = substr(s, 49, 49), QCF04 = substr(s, 50, 50), DSF04 = substr(s, 51, 51),
                  MAY = as.double(substr(s, 52, 56))/100.0, DMF05 = substr(s, 57, 57), QCF05 = substr(s, 58, 58), DSF05 = substr(s, 59, 59),
                  JUN = as.double(substr(s, 60, 64))/100.0, DMF06 = substr(s, 65, 65), QCF06 = substr(s, 66, 66), DSF06 = substr(s, 67, 67),
                  JUL = as.double(substr(s, 68, 72))/100.0, DMF07 = substr(s, 73, 73), QCF07 = substr(s, 74, 74), DSF07 = substr(s, 75, 75),
                  AUG = as.double(substr(s, 76, 80))/100.0, DMF08 = substr(s, 81, 81), QCF08 = substr(s, 82, 82), DSF08 = substr(s, 83, 83),
                  SEP = as.double(substr(s, 84, 88))/100.0, DMF09 = substr(s, 89, 89), QCF09 = substr(s, 90, 90), DSF09 = substr(s, 91, 91),
                  OCT = as.double(substr(s, 92, 96))/100.0, DMF10 = substr(s, 97, 97), QCF10 = substr(s, 98, 98), DSF10 = substr(s, 99, 99),
                  NOV = as.double(substr(s, 100, 104))/100.0, DMF11 = substr(s, 105, 105), QCF11 = substr(s, 106, 106), DSF11 = substr(s, 107, 107),
                  DEC = as.double(substr(s, 108, 112))/100.0, DMF12 = substr(s, 113, 113), QCF12 = substr(s, 114, 114), DSF12 = substr(s, 115, 115))
  write.table(x, file = "tavg_qca.csv", append = TRUE, quote = FALSE, sep = ",", row.names = FALSE, col.names = FALSE)
  if (i %% 1000 == 0) {
    print(paste('finished', i, 'out of', N))
  }
}

