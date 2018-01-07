require 'rspec'
require_relative '../lib/parser.rb'

describe Parser do
  describe '.parse_tweet' do
    context 'for regular tweet' do
      it 'assigns fields from tweet object to row' do
        now = Time.now

        fake_url = double('url')
        allow(fake_url).to receive_message_chain(:expanded_url, :to_s) { 'https://legit.url' }

        tweet = double('tweet',
          id: 1,
          created_at: now,
          source: 'twitter.com',
          text: 'annie loves regular tweets',
          retweet?: false,
          reply?: false,
          urls?: true,
          urls: [ fake_url ]
        )

        row = Parser.parse_tweet(tweet)

        expect(row.to_h).to match(
          tweet_id: 1,
          in_reply_to_status_id: nil,
          in_reply_to_user_id: nil,
          timestamp: now,
          source: 'twitter.com',
          text: 'annie loves regular tweets',
          retweeted_status_id: nil,
          retweeted_status_user_id: nil,
          retweeted_status_timestamp: nil,
          expanded_urls: [ 'https://legit.url' ],
        )
      end
    end

    context 'for retweets' do
      it 'assigns fields from tweet object to row' do
        now = Time.now

        fake_status = double('status', id: 111, created_at: now - 30)
        allow(fake_status).to receive_message_chain(:user, :id) { 666 }

        tweet = double('tweet',
          id: 1,
          created_at: now,
          source: 'twitter.com',
          text: 'annie loves retweets',
          retweet?: true,
          reply?: false,
          urls?: false,
          retweeted_status: fake_status
        )

        row = Parser.parse_tweet(tweet)

        expect(row.to_h).to match(
          tweet_id: 1,
          in_reply_to_status_id: nil,
          in_reply_to_user_id: nil,
          timestamp: now,
          source: 'twitter.com',
          text: 'annie loves retweets',
          retweeted_status_id: 111,
          retweeted_status_user_id: 666,
          retweeted_status_timestamp: now - 30,
          expanded_urls: []
        )
      end

    end

    context 'for replies' do
      it 'assigns fields from tweet object to row' do
        now = Time.now

        tweet = double('tweet',
          id: 1,
          created_at: now - 60,
          source: 'twitter.com',
          text: 'annie hates reply tweets',
          retweet?: false,
          reply?: true,
          in_reply_to_status_id: 111,
          in_reply_to_user_id: 666,
          urls?: false
        )

        row = Parser.parse_tweet(tweet)

        expect(row.to_h).to match(
          tweet_id: 1,
          in_reply_to_status_id: 111,
          in_reply_to_user_id: 666,
          timestamp: now - 60,
          source: 'twitter.com',
          text: 'annie hates reply tweets',
          retweeted_status_id: nil,
          retweeted_status_user_id: nil,
          retweeted_status_timestamp: nil,
          expanded_urls: []
        )
      end
    end
  end

  describe '.parse_tweets' do
    it 'parses tweets and return array of rows' do
      tweets = [
        double('tweet one').as_null_object,
        double('tweet two').as_null_object,
        double('tweet three').as_null_object,
      ]

      rows = Parser.parse_tweets(tweets)
      expect(rows.length).to eq(3)
    end
  end
end