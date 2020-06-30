require 'rails_helper'

describe TwitterTimelineService, vcr: true do
  describe '.perform' do
    before do
      allow(TwitterTimelinePublisher).to receive(:publish)
    end

    subject { described_class.perform(params) }

    let(:start_date) { '1-06-2020' }
    let(:end_date) { '30-06-2020' }
    let(:email) { 'zarechenskiy.mihail@gmail.com' }
    let(:params) { { start_date: start_date, end_date: end_date, email: email } }
    let(:errors) { subject[1] }
    let(:notice) { subject[0] }

    context 'invalid params' do
      shared_examples 'handles wrong params' do
        it do
          expect(Twitter::REST::Client).not_to receive(:new)
          expect(TwitterTimelinePublisher).not_to receive(:publish)
          expect(errors.to_s).to match(invalid_attr)
          expect(notice).to be_blank
        end
      end

      context 'start_date' do
        let(:invalid_attr) { 'start_date' }
        let(:start_date) { 'wrong' }

        it_behaves_like 'handles wrong params'
      end

      context 'end_date' do
        let(:invalid_attr) { 'end_date' }
        let(:end_date) { 'wrong' }

        it_behaves_like 'handles wrong params'
      end

      context 'email' do
        let(:invalid_attr) { 'Email' }
        let(:email) { 'wrong' }

        it_behaves_like 'handles wrong params'
      end
    end

    context 'valid params' do
      context 'parsing error' do
        before { allow(described_class).to receive(:client).and_return(nil) }

        it do
          expect(TwitterTimelinePublisher).not_to receive(:publish)
          expect(errors.to_s).to match('Twitter data parsing error')
          expect(notice).to be_blank
        end

        # TODO: add more test cases when parsing was not successful
      end

      context 'tweets parsed successfully' do
        before do
          stub_const('TwitterTimelineService::TWEETS_LIMIT', 3) # default value 100 is excess for testing
        end

        it do
          VCR.use_cassette('TwitterTimelineService', :record => :new_episodes) do
            expect(TwitterTimelinePublisher).to receive(:publish).with(params.merge(data: [
              {:url=>"https://t.co/JRjCcfPMhb",
               :from=>"NASA",
               :description=>"Today is international #AsteroidDay☄️! To mark this @UN day, experts from our #PlanetaryDefense Coordination Office… ",
               :created_at=>"2020-06-30 17:16:16"},
              {:url=>"https://t.co/gOZLaw04I9",
                :from=>"NASA",
                :description=>"Who are our #AsteroidDay #PlanetaryDefense experts?\n\nLindley Johnson, Planetary Defense Officer &amp; Program Executive… ",
                :created_at=>"2020-06-30 17:17:50"},
              {:url=>"https://t.co/4kKerJf0zm",
               :from=>"National Geographic",
               :description=>"The water may be cold but the health benefits keep these daring divers coming back ",
               :created_at=>"2020-06-30 18:06:22"}
            ]))

            expect(errors).to be_blank
            expect(notice).to eq('Tweets were successfully parsed, check your email within a few seconds and it should be there')
          end
        end
      end
    end
  end
end
