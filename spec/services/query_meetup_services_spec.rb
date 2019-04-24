require 'rails_helper'

RSpec.describe QueryMeetupService do
  describe '#call' do
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
        rest_client_response = double(:rest_client_response, body: response)
        allow_any_instance_of(RestClient::Request).to receive(:execute).and_return(rest_client_response)
      end
      
      it 'caches search results' do
        described_class.new('test').call
        expect(MEETUP_REDIS.get('test')).to eq(result.to_json)
      end
    end
    context 'when no results found' do
      before do
        rest_client_response = double(:rest_client_response, body: response)
        allow_any_instance_of(RestClient::Request).to receive(:execute).and_return(RestClient::Response.new)
        allow_any_instance_of(RestClient::Response).to receive(:body).and_return("[]")
      end
      it 'returns empty' do
        described_class.new('sda').call
        expect(MEETUP_REDIS.get('sda')).to eq("[]")
      end
    end
  end
end
