require 'rubygems/command'
require 'rubygems/local_remote_options'
require 'rubygems/gemcutter_utilities'

class Gem::Commands::PushCommand < Gem::Command
  include Gem::LocalRemoteOptions
  include Gem::GemcutterUtilities

  def description # :nodoc:
    'Push a gem up to RubyGems.org'
  end

  def arguments # :nodoc:
    "GEM       built gem to push up"
  end

  def usage # :nodoc:
    "#{program_name} GEM"
  end

  def initialize
    super 'push', description
    add_proxy_option
    add_key_option
    
    add_option(
      '--host HOST',
      'Push to another gemcutter-compatible host'
    ) do |value, options|
      options[:host] = value
    end
  end

  def execute
    sign_in
    send_gem get_one_gem_name
  end

  def send_gem name
    say "Pushing gem to #{options[:host] || Gem.host}..."

    args = [:post, "api/v1/gems"]

    args << options[:host] if options[:host]

    api_key = options[:key] ? verify_api_key(options[:key]) :
                              Gem.configuration.rubygems_api_key

    response = rubygems_api_request(*args) do |request|
      request.body = Gem.read_binary name
      request.add_field "Content-Length", request.body.size
      request.add_field "Content-Type",   "application/octet-stream"
      request.add_field "Authorization",  api_key
    end

    with_response response
  end

end

