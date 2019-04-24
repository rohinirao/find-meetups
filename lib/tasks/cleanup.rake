require 'rufus-scheduler'
namespace :meetup do
  desc 'cleans up all the cached data'
  task cleanup: :environment do
    scheduler = Rufus::Scheduler.new
    scheduler.every '15m' do
      CLEANUP_REDIS.keys.each do |key|
        next unless MEETUP_REDIS.get(key).nil?
        FileUtils.rm_rf(CLEANUP_REDIS.smembers(key))
        CLEANUP_REDIS.del(key)
      end
    end
    scheduler.join
  end
end

