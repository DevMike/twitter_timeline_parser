class TwitterTimelineService
  TWEETS_LIMIT=100

  def self.client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_SECRET"]
    end
  end

  def self.perform(...)
    self.new(...).process
  end

  def initialize(params)
    @errors = []
    @params = params
    @start_date = parse_date(:start_date, :at_beginning_of_day)
    @end_date = parse_date(:end_date, :at_end_of_day)
  end

  def process
    validate_email
    return result if @errors.any?

    begin
      tweets = parsed_tweets
    rescue => ex
      @errors << "Twitter data parsing error: #{ex.message}"
    end
    return result if @errors.any?

    TwitterTimelinePublisher.publish(@params.merge(data: tweets.sort_by{|tw| tw[:created_at] }))
    @notice = 'Tweets were successfully parsed, check your email within a few seconds and it should be there'
    result
  end

  private

  def parse_date(date_name, day_time)
    begin
      Date.parse(@params[date_name]).public_send(day_time)
    rescue => ex
      @errors << "Can't parse #{date_name}: #{ex.message}; date must have following format: '%day-%month-%year'"
    end
  end

  def validate_email
    @errors << 'Email is invalid' unless @params[:email] =~ URI::MailTo::EMAIL_REGEXP
  end

  def parsed_tweets
    self.class.client.home_timeline(count: TWEETS_LIMIT, include_entities: true).
      select {|t| t.created_at.between?(@start_date, @end_date) && t.uris.any? }.
      map{ |tweet| tweet_to_hash(tweet) }.
      reject(&:blank?)
  end

  def tweet_to_hash(tweet)
    url = tweet.uris.first.uri.to_s
    {
      url: url,
      from: tweet.user.name,
      description: tweet.text.gsub(url, ''),
      created_at: tweet.created_at.strftime("%F %T")
    }
  end

  def result
    [@notice, @errors]
  end
end
