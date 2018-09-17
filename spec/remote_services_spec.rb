require 'webmock/rspec'
require 'httparty'

class Gateway::Tweets
  def all
    response = HTTParty.get('http://api.twitter.com/tweets/get')
    JSON.parse(response.body, symbolize_names: true)[:tweets]
  end
end

describe Gateway::Tweets do
  before do
    stub_request(:get, "http://api.twitter.com/tweets/get")
      .to_return(body: tweets.to_json)
  end

  context 'given an account with no tweets' do
    let(:tweets) {{ tweets: [] }}

    it 'returns no tweets' do
      expect(subject.all.count).to eq(0)
    end
  end

  context 'given an account with three tweets' do
    let(:tweets) {{ tweets: ['hi', 'hello','bye' ] }}

    it 'returns three tweets' do
      expect(subject.all.count).to eq(3)
    end
  end
end