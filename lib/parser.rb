class Parser
  RowData = Struct.new(
    :tweet_id,
    :in_reply_to_status_id,
    :in_reply_to_user_id,
    :timestamp,
    :source,
    :text,
    :retweeted_status_id,
    :retweeted_status_user_id,
    :retweeted_status_timestamp,
    :expanded_urls
  )

  def self.parse_tweets(tweets)
    tweets.map{ |tweet| parse_tweet(tweet) }
  end

  def self.parse_tweet(tweet)
    RowData.new(
      tweet.id,
      tweet.reply? ? tweet.in_reply_to_status_id : nil,
      tweet.reply? ? tweet.in_reply_to_user_id : nil,
      tweet.created_at,
      tweet.source,
      tweet.text,
      tweet.retweet? ? tweet.retweeted_status.id : nil,
      tweet.retweet? ? tweet.retweeted_status.user.id : nil,
      tweet.retweet? ? tweet.retweeted_status.created_at : nil,
      tweet.urls? ? tweet.urls.map{|url| url.expanded_url.to_s} : []
    )
  end
end
