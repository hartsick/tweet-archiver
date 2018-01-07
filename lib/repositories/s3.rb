require 'aws-sdk-s3'
require 'csv'
require 'pry'

module Repository
  class S3
    TWEET_CSV = 'tweet_archive/tweets.csv'

    def initialize
      @s3 = Aws::S3::Resource.new(region: ENV['AWS_BUCKET_REGION'])
    end

    attr_accessor :s3, :obj, :temp_file

    def update(tweets)
      get_tweets_csv
      add_new_tweets_to_csv(tweets)
      upload_updated_csv
    end

    private

    def get_tweets_csv
      @temp_file = Tempfile.new
      @obj = s3.bucket(ENV['AWS_BUCKET_NAME']).object(TWEET_CSV)
      obj.get(response_target: temp_file.path)
    end

    def add_new_tweets_to_csv(tweets)
      tweets_to_archive = tweets.reject{|tweet| archived_tweet_ids.include?(tweet.tweet_id) }

      CSV.open(temp_file.path, 'a') do |csv|
        tweets_to_archive.each do |tweet|
          csv << tweet.to_a
        end
      end
    end

    def upload_updated_csv
      obj.upload_file(temp_file.path)
    end

    def archived_tweet_ids
      @archived_tweet_ids ||= [].tap do |tweet_ids|
        CSV.foreach(temp_file.path) {|row| tweet_ids << row[0] }
      end
    end
  end
end
