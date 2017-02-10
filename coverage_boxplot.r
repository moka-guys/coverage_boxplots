install.packages("tidyverse")
install.packages("stringr")

library("tidyverse")
library("stringr")

# import coverage data
covtidy <- read_tsv("covtidy.txt")

# check the dataframe,  should return: A tibble: 2,551,722 × 3
covtidy

# examples of plotting box plots for a few genes
covtsubset <- filter(covtidy, Gene=="COL9A2" | Gene=="MATN3" | Gene=="SLC26A2" | Gene=="COL9A1" | Gene=="COMP" | Gene=="COL9A3" | Gene=="CA5BP1")
ggplot(covtsubset, aes(x="", y=above20X)) +
  geom_boxplot(aes(group = Gene)) +
  facet_wrap(~ Gene, ncol = 1)
ggsave("Coverage170210.pdf", width=2, height=20, limitsize=FALSE)

# example of plotting box plots for a range of gene symbols
covtsubset <- filter(covtidy, Gene=="E" | str_detect(Gene, "^E[0-9].*") | str_detect(Gene, "^E[A-N].*") )
ggplot(covtsubset, aes(x="", y=above20X)) +
  geom_boxplot(aes(group = Gene)) +
  facet_wrap(~ Gene, ncol = 6)
ggsave("E1-EN.pdf", width=8, height=100, limitsize=FALSE)
