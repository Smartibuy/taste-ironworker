require_relative 'bundle/bundler/setup'
require_relative 'config/config_queue.rb'
require 'json'
require 'aws-sdk'
require 'httparty'

require 'uri'

puts "Starting SOA_worker at #{Time.now}"

puts "Setting up AWS connection"
config = JSON.parse(File.read('config/config.json'))
ENV.update config
sqs = Aws::SQS::Client.new
q_url = QUEUE_URL

puts "Polling SQS for messages"
poller = Aws::SQS::QueuePoller.new(q_url)
begin
  poller.poll(wait_time_seconds:nil, idle_timeout:5) do |msg|
    puts "MESSAGE: #{JSON.parse(msg.body)}"
    req = JSON.parse(msg.body)
    results = HTTParty.get URI.escape(req[0]['url'])
    puts "RESULTS: #{results}\n\n"
  end
rescue Aws::SQS::Errors::ServiceError => e
  puts "ERROR FROM SQS: #{e}"
end

puts "SOA_worker completed at #{Time.now}"
