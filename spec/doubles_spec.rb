# frozen_string_literal: true

module UseCase; end
module Gateway; end

# pre-existing use-case
class UseCase::ReadAllTweets
  def initialize(credentials_gateway:, tweets_gateway:)
    @credentials_gateway = credentials_gateway
    @tweets_gateway = tweets_gateway
  end

  def execute
    credentials = @credentials_gateway.all
    @tweets_gateway.all if credentials
  end
end

class UseCase::SaveTweet
  def initialize(tweets_gateway:)
    @tweets_gateway = tweets_gateway
  end

  def execute(tweet:)
    @tweets_gateway.save(tweet: tweet)
  end
end

class Gateway::Tweets
  def all; end
end

# Dummy, a Stub, a Fake, a True Mock and a Spy,
describe 'example dummy' do
  # we're using a stub here as well for ease
  subject { UseCase::ReadAllTweets.new(credentials_gateway: double(all: nil), tweets_gateway: nil) }

  it 'does not try to send tweets if there are no credentials' do
    expect{ subject.execute }.to_not raise_error
  end
end

describe 'example of stub' do
  subject { UseCase::ReadAllTweets.new(credentials_gateway: double(all: 'hello'), tweets_gateway: tweets_gateway) }

  let(:tweets_gateway) { StubGateway.new(return_value: 'arbitrary return value') }

  it 'returns results from gateway' do
    expect(subject.execute).to eq('arbitrary return value')
  end
end

describe 'example of a fake' do
  subject { UseCase::SaveTweet.new(tweets_gateway: tweets_gateway) }
  
  let(:tweets_gateway) { InMemoryFakeTweets.new }

  it 'view a tweet after it has been saved' do
    my_tweet = 'Hi im a fake tweet!'
    subject.execute(tweet: my_tweet)
    all_tweets = UseCase::ReadAllTweets.new(credentials_gateway: double(all: true), tweets_gateway: tweets_gateway)
    expect(all_tweets.execute).to eq(my_tweet)
  end
end

describe 'example of a spy' do
  subject { UseCase::SaveTweet.new(tweets_gateway: tweets_gateway) }

  let(:tweets_gateway) { TweetSpy.new }

  it 'calls the save method in the gateway' do
    my_tweet = 'Hi im a fake tweet!'
    subject.execute(tweet: my_tweet)
    expect(tweets_gateway.has_received).to eq(true)
  end
end

describe 'example of a true mock' do
  subject { UseCase::SaveTweet.new(tweets_gateway: tweets_gateway) }

  let(:tweets_gateway) { TweetTrueMock.new }

  it 'calls the save method in the gateway' do
    my_tweet = 'Hi im a fake tweet!'
    subject.execute(tweet: my_tweet)
    tweets_gateway.has_received_save(self)
  end
end

class TweetTrueMock
  def initialize
    @received_save = false
  end

  def save(tweet:)
    @received_save = true
  end

  def has_received_save(test_suite)
    test_suite.expect(@received_save).to test_suite.eq(true)
  end
end

class TweetSpy
  def initialize
    @received_save = false
  end

  def save(tweet:)
    @received_save = true
  end

  def has_received
    @received_save
  end
end

class StubGateway
  def initialize(return_value:)
    @return_value = return_value
  end

  def all
    @return_value
  end
end

class InMemoryFakeTweets
  def initialize
    @tweet = ''
  end

  def save(tweet:)
    @tweet = tweet
  end

  def all
    @tweet
  end
end
