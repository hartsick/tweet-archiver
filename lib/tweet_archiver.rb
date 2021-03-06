require 'twitter'
require_relative './tweet_to_csv_parser'

class TweetArchiver
  def initialize(twitter, repository)
    @twitter = twitter
    @repository = repository
  end

  attr_reader :twitter, :repository

  def archive_until(date, with_delete: false)
    retrieved_tweets = twitter.user_timeline(twitter.user.id, count: 200)
    in_range_tweets = retrieved_tweets.select{ |t| t.created_at < date }

    rows = TweetToCsvParser.parse_tweets(in_range_tweets)
    repository.update(rows)

    if with_delete
      twitter.destroy_status(in_range_tweets)
    end
  end
end
