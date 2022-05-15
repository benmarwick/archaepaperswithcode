#---------------------------------------------------------------------
# This script is run periodically, once per month, and posts a tweet
# that shares a paper relevant to reproducible research. The papers
# come from https://www.zotero.org/groups/4690054/reproducible_research_for_archaeologists
#--------------------------------------------------------------------

library(RefManageR)
library(tidyverse)

number_of_papers <- 100 # we need something, this is arbitrary

zotero_group_items <- 
ReadZotero(group = "4690054", 
           .params = list(limit = number_of_papers))

actual_number_of_papers <- length(zotero_group_items)

# get a random paper
the_selected_paper <- zotero_group_items[sample(actual_number_of_papers, 1)]

# get only minimal reference
the_selected_paper_tidy <- 
  capture.output(
  print(the_selected_paper,
      .opts = list(
        style = "text",
        bib.style = "authoryear",
        no.print.fields = c("isbn", 
                            "issn", 
                            "note", 
                            "pages",
                            "doi", 
                            "language", 
                            "lastvisited", 
                            "urldate"))
))

# tidy the reference to remove some details
the_selected_paper_tidy <- paste0(the_selected_paper_tidy, collapse = " ")
the_selected_paper_tidy <- str_remove(the_selected_paper_tidy, 
                                      "In\\: ")
the_selected_paper_tidy <- str_remove(the_selected_paper_tidy, 
                                      "\\<URL\\: ")
the_selected_paper_tidy <- str_remove(the_selected_paper_tidy, 
                                      "\\>\\.")
the_selected_paper_tidy <- str_remove(the_selected_paper_tidy, 
                                      "pp\\. ")
the_selected_paper_tidy <- str_remove_all(the_selected_paper_tidy, 
                                      "_")
the_selected_paper_tidy <- str_replace_all(the_selected_paper_tidy, 
                                      "and", "&")
the_selected_paper_tidy

# Compose the tweet
stock_phrases <- 
  c("Looking for guidance on how to do reproducible research? Check this out: ",
    "Here's an interesting read on reproducible research! ",
    "Check out this inspiring paper on reproducible research: ",
    "This paper has some great tips on doing reproducible research: ",
    "Useful information for making research reproducible in this paper: ")

tweet_text <- paste0(stock_phrases[sample(length(stock_phrases), 1)],
                     the_selected_paper_tidy)

# for testing
tweet_text
nchar(tweet_text)

# Send tweets --------------------------------------------------

library(rtweet)

# Create Twitter token
archaepaperswithcode_token <- rtweet::create_token(
  app = "archaepaperswithcode",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

rtweet::post_tweet(
  status = tweet_text,
  token = archaepaperswithcode_token
)

