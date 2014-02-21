require 'aws-sdk'
require 'yaml'

config_file = 'config/aws.yaml'

if File.exists? config_file
  config = YAML.load(File.read(config_file))
  AWS.config(config)
end