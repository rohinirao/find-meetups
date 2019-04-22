require 'rails_helper'
RSpec.describe MeetupsSearchJob, type: :job do
  before { ActiveJob::Base.queue_adapter = :test } 

  describe 'queued' do
    it 'as meetups_search_job' do
      expect { described_class.perform_later('test') }.to have_enqueued_job.on_queue('meetups_test_meetups_search_job')
    end
  end

  describe '#perform' do
    response = [
      { "name":"Ministry of Testing Munich","status":"active","localized_location":"München, Germany",
        "group_photo":{"id":464897443,"thumb_link":"#{Rails.root.to_s}/spec/files/images/test_photo.png"},
        "category":{"id":34,"name":"Tech","shortname":"tech","sort_name":"Tech"}
      },
      { "name":"Agile Testing @Munich","status":"active","localized_location":"München, Germany",
        "group_photo":{"id":464897443,"thumb_link":""},
        "category":{"id":34,"name":"Tech","shortname":"tech","sort_name":"Tech"}
      }
    ].to_json
    result = [
            {"name":"Ministry of Testing Munich","location":"München, Germany","status":"active","category":"Tech","photo":"/assets/images/meetup/test_photo.png"},
            {"name":"Agile Testing @Munich","location":"München, Germany","status":"active","category":"Tech","photo":"/assets/images/default_photo.png"}
          ]
    context 'with valid search text' do
      before do
        allow_any_instance_of(MeetupsSearchJob).to receive(:request_api).and_return(response)
      end
      it 'performs job' do
        expect(described_class.perform_now('test')).to eq(true)
      end
      it 'assigns redis data' do
        described_class.perform_now('test')
        expect(MEETUP_REDIS.get('test')).to eq(result.to_json)
      end
    end
    context 'when no results found' do
      it 'returns empty' do
        allow_any_instance_of(MeetupsSearchJob).to receive(:request_api).and_return("[]")
        described_class.perform_now('sda')
        expect(MEETUP_REDIS.get('sda')).to eq("[]")
      end
    end
  end
end
