#! /usr/bin/env ruby
# encoding: UTF-8
#
# check-splunk-info
#
# DESCRIPTION:
#   check for a match in the Splunk service information
#
# OUTPUT:
#   check status (ok or critical)
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: splunk-sdk-ruby
#
# USAGE:
#   check for a match in the Splunk service information
#   ./check-splunk-info.rb -h localhost -u admin -p changeme -f version -m 6.2.0
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

class CheckSplunkInfo < Sensu::Plugin::Check::CLI
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

  option :field,
    description: 'Info field to retrieve (default: version)',
    short: '-f',
    long: '--field FIELD',
    default: 'version'

  option :match,
    description: 'Pattern to match the field against',
    short: '-m',
    long: '--match MATCH',
    required: true

  def check_splunk_info
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

    # retrieve server info
    info_hash = service.info

    critical "Field error: unknown field '#{config[:field]}'" unless info_hash.key?(config[:field])

    critical "Value error: no match in '#{config[:field]}' for '#{config[:match]}'" unless info_hash[config[:field]] == config[:match]

    ok "Info field '#{config[:field]}' matches '#{config[:match]}'"
  end

  def run
    # sanity check input values

    # call splunk info check
    check_splunk_info
  end

end
