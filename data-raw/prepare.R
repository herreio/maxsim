ITEMS <- "https://bsc.herre.xyz/raw/item_k500.RDS"
MODEL <- "https://bsc.herre.xyz/raw/model_k500.RDS"
THETA <- "https://bsc.herre.xyz/raw/theta_k500.RDS"

cat("fetch topic model of scientific publications..\n")
model <- readRDS(gzcon(url(MODEL)))
model <- model$btm_all
usethis::use_data(model, overwrite=TRUE)
rm(model)

cat("\nfetch scientific publications and its topics..\n")
items <- readRDS(gzcon(url(ITEMS)))
items <- items$btm_t500
usethis::use_data(items, overwrite=TRUE)
rm(items)

cat("\nfetch topic distribution of scientific publications..\n")
theta <- readRDS(gzcon(url(THETA)))
theta <- theta$btm_t500
rownames(theta) <- gsub("corpus:", "", rownames(theta), fixed=T)
usethis::use_data(theta, overwrite=TRUE)
rm(theta)
