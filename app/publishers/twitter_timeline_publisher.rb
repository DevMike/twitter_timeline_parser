class TwitterTimelinePublisher
  def self.publish(params)
    Hutch.connect
    Hutch.publish('twitter.parsed_timeline_received', params)
  end
end
