# taste-ironworker

## Configure and test the worker locally

1. Configure this project
  - Create a `/config/config.json` & /config/config_queue.rb file
  - Copy and modify contents of `config/example_config.json` to `config/config.json`
  - Copy and modify contents of `config/example_config_queue.rb` to `config/config_queue.rb.json`
2. Test this worker
  - `$ bundle install --standalone`
    - creates a bundle of all needed gems within your repo
  - `$ ruby soa_worker.rb`

## Deploy and run this worker

3. Upload your worker
  - `$ zip -r iron.zip .`
    - creates a zip of all files in this folder
  - `$ iron worker upload --zip iron.zip --name iron iron/images:ruby-2.1 ruby soa_worker.rb`
    - creates a zip of your entire repo
4. Run your worker remotely
  - `$ iron worker queue --payload-file ./config/config.json --wait iron`
    - runs your worker on iron.io
