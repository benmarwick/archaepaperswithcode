
library(git2r)

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

# print the output to help with testing
new_text


library(rtweet)

tweetText <- new_text

# Create Twitter token
archaepaperswithcode_token <- rtweet::create_token(
  app = "archaepaperswithcode",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)
rtweet::post_tweet(
  status = tweetText,
  token = archaepaperswithcode_token
)
