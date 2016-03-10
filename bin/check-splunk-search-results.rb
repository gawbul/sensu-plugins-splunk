#! /usr/bin/env ruby
# encoding: UTF-8
#
# check-splunk-search-results
#
# DESCRIPTION:
#   check for a given pattern in the results of a Splunk search
#
# OUTPUT:
#   check match(ok or critical)
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: splunk-sdk-ruby
#
# USAGE:
#   check the status of the Splunk service
#   ./check-splunk-search-results.rb -h localhost -u admin -p changeme -st index=_internal " error " NOT debug source=*splunkd.log* -sp -im
#
# NOTES:
#  
#
# LICENSE:
#   Steve Moss <gawbul@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'splunk-sdk-ruby'

class CheckSplunkSearchResults < Sensu::Plugin::Check::CLI
  option :hostname,
    description: 'Hostname of the Splunk server to connect to',
    short: '-h',
    long: '--hostname HOSTNAME',
    required: true

  option :port,
    description: 'Port the Splunk server is listening on (default: 8089)',
    short: '-P',
    long: '--port PORT',
    default: 8089,
    required: false

  option :scheme,
    description: 'Scheme of the listening Splunk server (default: https)',
    short: '-s',
    long: '--scheme SCHEME',
    default: :https,
    required: false

  option :username,
    description: 'Username to connect to the Splunk service',
    short: '-u',
    long: '--username USERNAME',
    required: true

  option :password,
    description: 'Password to connect to the Splunk service',
    short: '-p',
    long: '--password PASSWORD',
    required: true

  option :searchterm,
    description: 'Search term to pass to the Splunk service',
    short: '-t',
    long: '--term TERM',
    required: true

  option :searchpattern,
    description: 'Pattern to match in the Splunk search results',
    short: '-m',
    long: '--pattern PATTERN',
    required: true

  option :invertmatch,
    description: 'Cause match to result in CRITICAL instead of OK status',
    short: '-i',
    long: '--invert',
    boolean: true,
    default: false

  def check_splunk_search_results
    # setup connection to Splunk REST service
    begin
      service = Splunk::connect(:host     => config[:hostname],
                                :port     => config[:port],
                                :protocol => config[:scheme],
                                :username => config[:username],
                                :password => config[:password])
    rescue => e
      critical "Connect error: #{e.message}"
    end

    # run search
    
  end

  def run
    # sanity check input values

    # call splunk license check
    check_splunk_search_results
  end

end
