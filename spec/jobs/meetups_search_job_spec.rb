require 'rails_helper'
RSpec.describe MeetupsSearchJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :test } 

  describe 'queued' do
    it 'as meetups_search_job' do
      expect { described_class.perform_later('test') }.to have_enqueued_job.on_queue('meetups_test_meetups_search_job')
    end
  end
end
