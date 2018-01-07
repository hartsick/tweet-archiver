require 'rspec'
require_relative '../lib/parser'

describe Parser do
  describe '.parse_tweet' do
    let(:time) { Time.new(2009, 03, 16, 1, 30, 0, '+00:00') }
    context 'for regular tweet' do
      it 'assigns fields from tweet object to row' do
        fake_url = double('url')
        other_fake_url = double('url')
        allow(fake_url).to receive_message_chain(:expanded_url, :to_s) { 'https://legit.url' }
        allow(other_fake_url).to receive_message_chain(:expanded_url, :to_s) { 'http://also.legit' }

        tweet = double('tweet',
          id: 1,
          created_at: time,
          source: 'twitter.com',
          text: 'annie loves regular tweets',
          retweet?: false,
          reply?: false,
          urls?: true,
          urls: [ fake_url, other_fake_url ]
        )

        row = Parser.parse_tweet(tweet)

        expect(row.to_h).to match(
          tweet_id: '1',
          in_reply_to_status_id: '',
          in_reply_to_user_id: '',
          timestamp: '2009-03-16 01:30:00 +0000',
          source: 'twitter.com',
          text: 'annie loves regular tweets',
          retweeted_status_id: '',
          retweeted_status_user_id: '',
          retweeted_status_timestamp: '',
          expanded_urls: 'https://legit.url,http://also.legit',
        )
      end
    end

    context 'for retweets' do
      it 'assigns fields from tweet object to row' do
        other_time = Time.new(2009, 04, 15, 1, 30, 0, '+00:00')

        fake_status = double('status', id: 111, created_at: other_time)
        allow(fake_status).to receive_message_chain(:user, :id) { 666 }

        tweet = double('tweet',
          id: 1,
          created_at: time,
          source: 'twitter.com',
          text: 'annie loves retweets',
          retweet?: true,
          reply?: false,
          urls?: false,
          retweeted_status: fake_status
        )

        row = Parser.parse_tweet(tweet)

        expect(row.to_h).to match(
          tweet_id: '1',
          in_reply_to_status_id: '',
          in_reply_to_user_id: '',
          timestamp: '2009-03-16 01:30:00 +0000',
          source: 'twitter.com',
          text: 'annie loves retweets',
          retweeted_status_id: '111',
          retweeted_status_user_id: '666',
          retweeted_status_timestamp: '2009-04-15 01:30:00 +0000',
          expanded_urls: []
        )
      end

    end

    context 'for replies' do
      it 'assigns fields from tweet object to row' do
        tweet = double('tweet',
          id: 1,
          created_at: time,
          source: 'twitter.com',
          text: 'annie hates reply tweets',
          retweet?: false,
          reply?: true,
          in_reply_to_status_id: '111',
          in_reply_to_user_id: '666',
          urls?: false
        )

        row = Parser.parse_tweet(tweet)

        expect(row.to_h).to match(
          tweet_id: '1',
          in_reply_to_status_id: '111',
          in_reply_to_user_id: '666',
          timestamp: '2009-03-16 01:30:00 +0000',
          source: 'twitter.com',
          text: 'annie hates reply tweets',
          retweeted_status_id: '',
          retweeted_status_user_id: '',
          retweeted_status_timestamp: '',
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