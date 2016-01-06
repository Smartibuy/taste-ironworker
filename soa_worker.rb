# encoding: UTF-8

require_relative 'bundle/bundler/setup'
require_relative 'config/config_queue.rb'
require 'json'
require 'aws-sdk'
require 'httparty'
# require 'jieba'
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
  collect = {}
  poller.poll(wait_time_seconds:nil, idle_timeout:5) do |msg|

    keyword = msg.body.to_s
    keyword_arr = HTTParty.post('http://workerapi.herokuapp.com/parse_keyword',:body => {"keyword" => keyword}.to_json, :headers => {'Content-Type' => 'application/json'})
    keyword_arr.each do |key|
      if collect[key] != nil
        collect[key] = collect[key] + 1
      else
        collect[key] = 1
      end
    end
  end

  keyword_arr = HTTParty.post('http://smartibuyapidynamo.herokuapp.com/api/v1/save_hot_key_word',:body => {"key_data" => collect.to_json}.to_json, :headers => {'Content-Type' => 'application/json'})

  puts collect
rescue Aws::SQS::Errors::ServiceError => e
  puts "ERROR FROM SQS: #{e}"
end

puts "SOA_worker completed at #{Time.now}"
