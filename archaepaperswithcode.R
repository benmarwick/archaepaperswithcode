library(tidyverse)
library(glue)
library(git2r)
library(rtweet)

# Tweet the latest paper added ----------------------------

## Create a temporary directory to hold the repository
path <- file.path(tempfile(pattern="ctv-"), "ctv")
dir.create(path, recursive=TRUE)

## Clone the repository into a temp directory
repo <- clone("https://github.com/benmarwick/ctv-archaeology/", path)

## get contents of current and previous commits
current_commit <- commits(repo)[[1]]
previous_commit <- commits(repo)[[2]]

# get contents of the difference between the two commits
diff_contents <- 
  system(paste("cd ", 
               path, 
               " && git diff ", 
               previous_commit$sha, 
               " ",
               current_commit$sha),
         intern = TRUE)

# extract only the new text
diff_contents_1 <- paste(diff_contents, collapse = " ")
new_text <- stringr::str_extract(diff_contents_1, "(?<=  \\+).+(?=\\+)" )

# shorten the text in the reference 
new_text <- stringr::str_remove_all(new_text, "_" )
new_text <- stringr::str_replace_all(new_text, "Journal of Archaeological Science: Reports", "JAS:R")
new_text <- stringr::str_replace_all(new_text, "Journal of Archaeological Science", "JAS")
new_text <- stringr::str_replace_all(new_text, "Archaeology|Archaeological", "Arch.")
new_text <- stringr::str_replace_all(new_text, "Science|Scientific", "Sci")
new_text <- stringr::str_replace_all(new_text, "Reports", "Rep")
new_text <- stringr::str_replace_all(new_text, " and ", " & ")
new_text <- stringr::str_replace_all(new_text, "Quaternary International", "QI")
new_text <- stringr::str_squish(new_text)

# if the number of characters for authors is >10, then replace with et al.
new_text <- 
ifelse(
  nchar(str_extract(new_text, "\\..*?\\(20")) > 10,
  gsub("\\..*?\\(20", ". et al. (20", new_text),
  new_text
)

# if the number of characters for title is >100, then truncate the title

full_title <- str_extract(new_text, "(?<=\\)\\. ).+(?=http)")
shortened_title <- str_c(str_trunc(str_extract(new_text, "(?<=\\)\\. ).+(?=http)"), 
                                   100), " ")

new_text <- 
  ifelse(
    nchar(full_title) > 100,
    gsub(
      pattern = full_title, 
      replacement = shortened_title,
      x = new_text,
      fixed = TRUE),
    new_text
  )


# compose tweet 1
tweet1 <- paste0("New #archaeology paper with #rstats code! Take a look: \n\n",
                 new_text)

# print the output to help with testing
tweet1

# Tweet current size of the list -------------------------------
ctv <- "https://raw.githubusercontent.com/benmarwick/ctv-archaeology/master/README.md"

archy_ctv_readme <- readLines(ctv)

# get just the articles
archy_ctv_readme_start <- str_which(archy_ctv_readme, " Publications that include R code")
archy_ctv_readme <-
  archy_ctv_readme[archy_ctv_readme_start:(length(archy_ctv_readme) - 3)]

# get all dates of publication
archy_ctv_readme <- str_remove_all(archy_ctv_readme, "[[:punct:]]")
archy_ctv_readme_20XX <- str_extract(archy_ctv_readme, " 20[[:digit:]]{2} ")
archy_ctv_readme_20XX <- str_squish(unlist(archy_ctv_readme_20XX))
archy_ctv_readme_20XX <- as.numeric(archy_ctv_readme_20XX)
archy_ctv_readme_20XX <- archy_ctv_readme_20XX[!is.na(archy_ctv_readme_20XX)]
number_of_reproducible_articles <- length(archy_ctv_readme_20XX)
number_of_reproducible_articles_this_year <- sum(archy_ctv_readme_20XX == as.integer(format(Sys.Date(), "%Y")))
this_year <- as.integer(format(Sys.Date(), "%Y"))

# get a few journal names
# get a few journal names
archy_ctv_readme_journals <- str_which(archy_ctv_readme, glue_collapse(archy_ctv_readme_20XX, "|"))
archy_ctv_readme_journals <- archy_ctv_readme[archy_ctv_readme_journals]

journals <- c("Journal of Archaeological Method and Theory",
              "J Archaeol Sci",
              "Journal of Anthropological Archaeology",
              "Journal of Archaeological Science",
              "PLOS",
              "Journal of Human Evolution",
              "Asian Perspectives",
              "Scientific Reports",
              "PLoS ONE",
              "The Holocene",
              "Archaeology in Oceania",
              "Quaternary International",
              "Internet Archaeology",
              "Quaternary Science Reviews",
              "Quaternary International",
              "Journal of Archaeological Science: Reports",
              "Open Quaternary",
              "Evolution and Human Behavior",
              "PaleoAnthropology",
              "Archaeological and Anthropological Sciences",
              "Transactions of the Royal Society B Biological Sciences",
              "Proceedings of the Royal Society B Biological Sciences",
              "Lithic Technology",
              "Journal of Lithic Studies",
              "Journal of Quaternary Science",
              "Royal Society Open Science",
              "Humanities and Social Sciences Communications",
              "Journal of Paleolithic Archaeology",
              # "Radiocarbon",
              "Geosciences",
              "Nature Ecology and Evolution",
              "Frontiers in Earth Science",
              "Boreas",
              "Journal of Computer Applications in Archaeology",
              "European Journal of Archeology",
              "Vegetation History and Archaeobotany",
              "African Archaeological Review",
              "Advances in Archaeological Practice",
              "American Antiquity",
              "Palgrave Communications",
              "Nature communications",
              "Proceedings of the National Academy of Sciences",
              "Archaeological Research in Asia",
              "Kiva",
              "Science Advances",
              "Archaeological and Anthropological Sciences",
              "Proceedings of the National Academy of Sciences",
              "Antiquity"
)

journals_paste <-
  paste0(journals, collapse = "|")

top_archy_journals <-
  tibble( citation = archy_ctv_readme_journals,
          year = archy_ctv_readme_20XX) %>%
  mutate(journal_name = str_extract(tolower(citation), tolower(journals_paste))) %>%
  mutate(journal_name = ifelse(journal_name == "j archaeol sci",
                               "journal of archaeological science",
                               ifelse(journal_name == "plos",
                                      "plos one",
                                      journal_name))) %>%
  mutate(journal_name = str_to_title(journal_name)) %>%
  mutate(journal_name = str_replace(journal_name, "And", "and")) %>%
  mutate(journal_name = str_replace(journal_name, "Of", "of")) %>%
  mutate(journal_name = str_replace(journal_name, "In ", "in ")) %>%
  mutate(journal_name = str_replace(journal_name, "Plos", "PLOS")) %>%
  mutate(journal_name = str_replace_na(journal_name, "Other")) %>%
  mutate(year = factor(year)) %>%
  add_count(journal_name) %>%
  mutate(journal_name = str_glue('{journal_name} (n = {n})'))

archaeology_articles_r_reproducible <-
  ggplot(top_archy_journals,
         aes(year,
             fill = journal_name)) +
  geom_bar(position = "stack") +
  scale_fill_viridis_d(name = paste0("Archaeology papers with R code openly available", " (total of ",
                                     nrow(top_archy_journals),
                                     " articles and chapters)"))  +
  xlab("Year of publication") +
  ylab("Number of articles") +
  theme_bw(base_size = 14) +
  theme(
    axis.text.x = element_text(angle = 90,
                               hjust = 1,
                               vjust = 0.5),
    legend.text=element_text(size = 10),
    legend.justification = c(0, 1),
    legend.position = c(0.05, 0.98),
    legend.spacing.y = unit(0.25, 'cm'),
    legend.key.size = unit(0.25, "cm")) +
  guides(fill=guide_legend(ncol=2))

archaeology_articles_r_reproducible

ggsave("papers-per-year.png",
       w = 15,
       h = 9)

# compose tweet 2
tweet2 <- paste0("There are now ", number_of_reproducible_articles, 
                 " #archaeology papers that include #rstats code, with ",
                 number_of_reproducible_articles_this_year, 
                 " published in ", 
                 this_year,
                 ". You can see the full list here: https://github.com/benmarwick/ctv-archaeology#publications-that-include-r-code")

# for testing
tweet2

# Send tweets --------------------------------------------------



# Create Twitter token
auth <- rtweet_bot(
  api_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

auth_as(auth = auth)


rtweet::post_tweet(
  status = tweet2,
  media = "papers-per-year.png",
  media_alt_text = "plot showing the number of archaeology articles that include R code published per year"
)

rtweet::post_tweet(
  status = tweet1
)

