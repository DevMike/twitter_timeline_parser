require 'rails_helper'

describe TwitterTimelinePublisher do
  describe '.publish' do
    before do
      allow(Hutch).to receive(:connect)
      allow(Hutch).to receive(:publish)
    end

    subject { described_class.publish(params) }

    let(:params) { { some: 'some' } }

    it 'publishes with respective data' do
      expect(Hutch).to receive(:publish).with("twitter.parsed_timeline_received", params)
      subject
    end
  end
end