require 'rest_client'
require 'open-uri'
class MeetupsSearchJob < ActiveJob::Base
  queue_as :meetups_search_job

  def perform(search_text)
    puts "in job"
    response = request_api(search_text)
    puts "response"
    puts response
    puts "end res"
    result = parse_response(response)
    puts "result"
    puts result
    puts "end result"

    MEETUP_REDIS.set(search_text, result.to_json)
    puts "redis"
    puts MEETUP_REDIS.get(search_text)
    MEETUP_REDIS.expire(search_text, 50.minutes.to_i)
  end

  # expects environment variable named MEETUP_KEY to be set.
  def request_api(search_text)
    response = RestClient::Request.execute(
      method: :get,
      url: "https://api.meetup.com/find/groups",
      headers: {
        content_type: :json,
        accept: :json,
        params: { key: ENV['MEETUP_KEY'], 'photo-host': 'secure', location: 'munich', text: search_text, page: 10 }
      })
    response.body
  end

  def parse_response(response)
    JSON.parse(response).map do |meetup|
      {
        name: meetup['name'] || 'NA',
        location: meetup['localized_location'] || 'NA',
        status: meetup['status'] || 'NA',
        category: meetup.dig('category','name') || 'NA',
        photo: process_photo(meetup.dig('group_photo','thumb_link'))
      }
    end
  end

  def process_photo(url)
    return '/assets/images/default_photo.png' if url.blank?
    IO.copy_stream(open(url), "#{Rails.root.to_s}/public/assets/images/meetup/#{url.split('/').last}")
    "/assets/images/meetup/#{url.split('/').last}"
  end
end