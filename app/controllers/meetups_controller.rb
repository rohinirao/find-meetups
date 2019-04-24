class MeetupsController < ApplicationController
  def index; end

  # searches for meetups based on the search text in the cache. If not found schedules 
  # a job to make an API call to fetch meetups.
  def search
    cached_search || MeetupsSearchJob.perform_later(params[:search_text].downcase.strip)
  end

  # end point for polling search results from cache.
  def search_result
    meetups = MEETUP_REDIS.get(params[:search_text].downcase.strip)
    if meetups.nil?
      @result = :not_ready
    else
      @result = JSON.parse(meetups)
      @result = :no_result if @result.blank?
    end
  end

  private

  def cached_search
    MEETUP_REDIS.get(params[:search_text].downcase.strip)
  end

end
