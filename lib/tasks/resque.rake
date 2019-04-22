require 'resque/tasks'
namespace :resque do
  desc 'resque'
  task setup: :environment do
    require 'resque'
    ENV['QUEUE'] ||= '*'
  end
end