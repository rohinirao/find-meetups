require 'rufus-scheduler'
namespace :meetup do
  desc 'cleans up all the cached data'
  task cleanup: :environment do
    scheduler = Rufus::Scheduler.new
    scheduler.every '3h' do
      MEETUP_REDIS.flushall
      FileUtils.rm_rf(Dir["#{Rails.root.to_s}/public/assets/images/meetup/*"])
    end
  end
end

