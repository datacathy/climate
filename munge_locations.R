# munge the GHCN QCA data to get tavg.csv which I can then play with

setwd("~/Documents/DataScience/Projects/Weather/qca/ghcnm.v3.3.0.20170122")
raw <- readLines("ghcnm.tavg.v3.3.0.20170122.qca.inv")

N = length(raw)
for (i in 1:N) {
  s <- raw[i]
  x <- data.frame(ID = substr(s, 1, 11), LAT = as.double(substr(s, 13, 20)), LNG = as.double(substr(s, 22, 30)),
                  STNELEV = as.double(substr(s, 32, 37)), NAME = substr(s, 39, 68), GRELEV = as.integer(substr(s, 70, 73)),
                  POPCLS = substr(s, 74, 74), POPSIZ = as.integer(substr(s, 75, 79)), TOPO = substr(s, 80, 81),
                  STVEG = substr(s, 82, 83), STLOC = substr(s, 84, 85), OCNDIS = as.integer(substr(s, 86, 87)), 
                  AIRSTN = substr(s, 88, 88), TOWNDIS = as.integer(substr(s, 89, 90)), GRVEG = substr(s, 91, 106),
                  POPCSS = substr(s, 107, 107))
  write.table(x, file = "locations.csv", append = TRUE, sep = ",", row.names = FALSE, col.names = FALSE)
  if (i %% 100 == 0) {
    print(paste('finished', i, 'out of', N))
  }
}

