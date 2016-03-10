#! /usr/bin/env ruby
# encoding: UTF-8
#
# check-splunk-version
#
# DESCRIPTION:
#   check the Splunk version
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
#   check the Splunk version
#   ./check-splunk-info.rb -h localhost -u admin -p changeme -v 6.2.0
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

class CheckSplunkVersion < Sensu::Plugin::Check::CLI
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

  option :version,
    description: 'Version number to check against',
    short: '-v',
    long: '--version VERSION',
    required: true

  def check_splunk_version
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

    # retrieve Splunk version
    version = service.splunk_version.join('.')

    critical "Version error: #{config[:version]} not equal to running Splunk version #{version}" unless version == config[:version]

    ok "Version #{config[:version]} matches running Splunk version"
  end

  def run
    # sanity check input values

    # call splunk info check
    check_splunk_version
  end

end
