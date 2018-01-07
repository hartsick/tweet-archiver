class TweetToCsvParser
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
      tweet.id.to_s,
      tweet.reply? ? tweet.in_reply_to_status_id.to_s : '',
      tweet.reply? ? tweet.in_reply_to_user_id.to_s : '',
      format_timestamp(tweet.created_at),
      tweet.source,
      tweet.text,
      tweet.retweet? ? tweet.retweeted_status.id.to_s : '',
      tweet.retweet? ? tweet.retweeted_status.user.id.to_s : '',
      tweet.retweet? ? format_timestamp(tweet.retweeted_status.created_at) : '',
      tweet.urls? ? tweet.urls.map{|url| url.expanded_url.to_s }.join(',') : []
    )
  end

  def self.format_timestamp(time)
    time.utc.strftime('%Y-%m-%d %H:%M:%S %z')
  end
end
