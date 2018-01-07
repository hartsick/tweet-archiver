require 'twitter'
require 'dotenv/tasks'
require_relative './lib/tweet_archiver'
require_relative './lib/repositories/s3'

task default: %w[tweet_archivist:archive_through_last_week]

namespace :tweet_archivist do
  task archive_through_last_week: :dotenv do
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end

    archiver = TweetArchiver.new(
      twitter_client,
      Repository::S3.new
    )

    one_week_ago = Time.now - (60 * 60 * 24 * 7)
    archiver.archive_until(one_week_ago)
  end
end
