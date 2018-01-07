require 'rspec'
require_relative '../lib/parser.rb'
require_relative '../lib/tweet_archiver.rb'

describe TweetArchiver do
  let(:now) { Time.now }
  let(:one_day) { 60 * 60 * 24 }
  let(:yesterday) { now - one_day }
  let(:two_days_ago) { now - (2 * one_day) }

  describe '#archive_until' do
    let(:fake_data_store) { double('data store') }
    let(:fake_client) { instance_double('Twitter::REST::Client') }
    let(:fake_tweets) do
      [
        instance_double('Twitter::Tweet', id: 1, created_at: now),
        instance_double('Twitter::Tweet', id: 2, created_at: yesterday + 60),
        instance_double('Twitter::Tweet', id: 3, created_at: yesterday - 60),
        instance_double('Twitter::Tweet', id: 4, created_at: two_days_ago),
      ]
    end
    let(:fake_rows) do
      [
        double('row one'),
        double('row two')
      ]
    end

    before do
      allow(fake_client).to receive_message_chain(:user, :id) { 111111 }
      expect(fake_client).to receive(:user_timeline).with(111111, count: 200) {
        fake_tweets
      }
    end

    it 'archives tweets up until given date' do
      expect(Parser).to receive(:parse_tweets).with(fake_tweets.last(2)) { fake_rows }
      expect(fake_data_store).to receive(:update).with(fake_rows)
      expect(fake_client).not_to receive(:destroy_status)

      TweetArchiver.new(
        fake_client,
        fake_data_store
      ).archive_until(yesterday)
    end

    context 'with_delete is true' do
      context 'archiving successful' do
        it 'deletes tweets after archiving' do
          expect(Parser).to receive(:parse_tweets).with(fake_tweets.last(2)) { fake_rows }
          expect(fake_data_store).to receive(:update).with(fake_rows)
          expect(fake_client).to receive(:destroy_status).with(fake_tweets.last(2))

          TweetArchiver.new(
            fake_client,
            fake_data_store
          ).archive_until(yesterday, with_delete: true)
        end
      end
    end
  end
end
