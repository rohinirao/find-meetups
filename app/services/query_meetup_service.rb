require 'rest_client'
require 'open-uri'
class QueryMeetupService
  def initialize(search_text)
    @search_text = search_text
  end

  def call
    response = request_api
    result = parse_response(response)
    set_cache(result)
  end

  private

  # expects environment variable named MEETUP_KEY to be set.
  def request_api
    response = RestClient::Request.execute(
      method: :get,
      url: "https://api.meetup.com/find/groups",
      headers: {
        content_type: :json,
        accept: :json,
        params: { key: ENV['MEETUP_KEY'], 'photo-host': 'secure', location: 'munich', text: @search_text, page: 10 }
      })
    response.body
  end

  def parse_response(response)
    JSON.parse(response).map do |meetup|
      {
        name: meetup['name'] || 'NA',
        location: meetup['localized_location'] || 'NA',
        status: meetup['status'] || 'NA',
        category: meetup.dig('category', 'name') || 'NA',
        photo: process_photo(meetup.dig('group_photo', 'thumb_link'))
      }
    end
  end

  def process_photo(url)
    return '/assets/images/default_photo.png' if url.blank?
    IO.copy_stream(open(url), "#{Rails.root.to_s}/public/assets/images/meetup/#{url.split('/').last}")
    "/assets/images/meetup/#{url.split('/').last}"
  end

  # cache search results in redis with an expiration of 5 minutes. using multi to have all the commands
  # executed in a transaction.
  def set_cache(result)
    MEETUP_REDIS.multi do
      MEETUP_REDIS.setex(@search_text, 5.minutes.to_i, result.to_json)
      photos_urls = result.map{ |data| "#{Rails.root.to_s}/public#{data[:photo]}" }
      CLEANUP_REDIS.sadd(@search_text, photos_urls) unless photos_urls.empty?
    end
  end
end