require 'rails_helper'

describe HomeController do
  describe 'GET /search' do
    before do
      allow(TwitterTimelineService).to receive(:perform).and_return([notice, errors])
    end

    let(:params) { { start_date: '1-06-2020', end_date: '30-01-2020', email: 'test' } }
    let(:notice) { nil }
    let(:errors) { 'something went wrong' }

    it 'initializes respective variables' do
      expect(TwitterTimelineService).to receive(:perform).with(params)
      get :search, xhr: true, params: params
      expect(assigns(:notice)).to eq(notice)
      expect(assigns(:errors)).to eq(errors)
    end
  end
end
