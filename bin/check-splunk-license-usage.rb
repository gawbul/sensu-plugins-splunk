#! /usr/bin/env ruby
# encoding: UTF-8
#
# check-splunk-license-usage
#
# DESCRIPTION:
#   check the level of splunk license usage
#
# OUTPUT:
#   check status (ok, warning or critical)
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: splunk-sdk-ruby
#
# USAGE:
#   check the level of splunk license usage
#   ./check-splunk-license-usage.rb -h localhost -u admin -p changeme
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

class CheckSplunkLicenseUsage < Sensu::Plugin::Check::CLI
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

  option :pool,
    description: 'License pool to check',
    short: '-l',
    long: '--pool POOL',
    default: 'free',
    required: true

  option :warn,
    description: 'Warning value to alert on',
    :short => '-w',
    long: '--warning WARNING',
    :proc => proc {|a| a.to_i },
    :default => 75

  option :crit,
    description: 'Critical value to alert on',
    :short => '-c',
    :long => '--critical CRITICAL',
    :proc => proc {|a| a.to_i },
    :default => 95

  def check_splunk_license_usage
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

    # retrieve license pool data
    pool = "auto_generated_pool_#{config[:pool]}"
    begin
      response = service.request(:method => :GET,
                                 :resource => ['licenser',
                                               'pools',
                                               "#{pool}"])
    rescue => e
      unknown "Request error: #{e.message}"
    end

    # return critical if response code isn't 200
    critical "#{response.code} #{response.message}" unless response.code.to_i == 200

    # parse atom feed data from response.body
    begin
      atom_data = Splunk::AtomFeed.new(response.body)
    rescue => e
      unknown "AtomFeed error: #{e.message}"
    end
    atom_content = atom_data.entries[0]['content']
    effective_quota = atom_content['effective_quota'].to_i
    used_bytes = atom_content['used_bytes'].to_i
    gigabytes_quota = effective_quota / (1024.0 * 1024.0 * 1024.0)
    gigabytes_used = used_bytes / (1024.0 * 1024.0 * 1024.0)
    percentage_used = (used_bytes.to_f / effective_quota.to_f) * 100.0

    # return values based on percentage_used
    critical "Splunk license usage critical (#{gigabytes_used.round(2)}GB of #{gigabytes_quota.round(2)}GB (#{percentage_used.round(2)}% usage))" unless percentage_used < config[:crit]

    warning "Splunk license usage warning (#{gigabytes_used.round(2)}GB of #{gigabytes_quota.round(2)}GB (#{percentage_used.round(2)}% usage))" unless percentage_used < config[:warn]

    ok "Splunk license usage within limits (#{gigabytes_used.round(2)}GB of #{gigabytes_quota.round(2)}GB (#{percentage_used.round(2)}% usage))"
  end

  def run
    # sanity check input values

    # call splunk license check
    check_splunk_license_usage
  end

end
