class MeetupsSearchJob < ActiveJob::Base
  queue_as :meetups_search_job

  def perform(search_text)
    QueryMeetupService.new(search_text).call
  end
end