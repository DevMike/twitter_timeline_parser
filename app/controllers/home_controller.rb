class HomeController < ApplicationController
  def new
  end

  def search
    @notice, @errors = TwitterTimelineService.perform(params.permit!.slice(:email, :start_date, :end_date).to_h)
  end
end
