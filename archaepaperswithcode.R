library(httr)
library(rtweet)
library(jsonlite)



tweetText <- paste(number, label, 'made by', maker, uri, 'Acquired', acquistion[, c('value')], sep=' ')
temp_file <- tempfile()

# Create Twitter token
archaepaperswithcode_bot_token <- rtweet::create_token(
  app = "archaepaperswithcode",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)
rtweet::post_tweet(
  status = tweetText,
  media = temp_file,
  token = archaepaperswithcode_bot_token
)
