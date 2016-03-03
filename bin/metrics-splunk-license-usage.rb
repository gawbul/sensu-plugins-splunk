#! /usr/bin/env ruby
# encoding: UTF-8
#
# metrics-splunk-license-usage
#
# DESCRIPTION:
#   return splunk license usage metrics
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   All
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: splunk-sdk-ruby
#
# USAGE:
#   splunk license usage metrics
#   ./metrics-splunk-license-usage.rb -h localhost -u admin -p changeme -s localhost.splunk
#
# NOTES:
#   
#
# LICENSE:
#   Steve Moss <gawbul@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/metric/cli'
require 'splunk-sdk-ruby'

class MetricsSplunkLicenseUsage < Sensu::Plugin::Metric::CLI::Graphite
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

  option :protocol,
    description: 'Protocol of the listening Splunk server (default: https)',
    short: '-r',
    long: '--protocol PROTOCOL',
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

  option :scheme,
    description: 'Metric naming scheme, text to prepend to metric',
    short: '-s SCHEME',
    long: '--scheme SCHEME',
    required: true

  def run
    # sanity check input values


    # setup connection to Splunk REST service
    service = Splunk::connect(:host     => config[:hostname],
                              :port     => config[:port],
                              :protocol => config[:protocol],
                              :username => config[:username],
                              :password => config[:password])

    # retrieve license pool data
    begin
      response = service.request(:method => :GET,
                                 :resource => ['licenser',
                                               'pools'])
    rescue => e
      unknown "Request error: #{e.message}"
    end

    # return critical if response code isn't 200
    critical "#{response.code} #{response.message}" unless response.code.to_i == 200

    # parse atom feed data from response.body
    atom_data = Splunk::AtomFeed.new(response.body)
    atom_data.entries.each do |entry|
      atom_content = entry['content']

      # calculate metric values
      description = atom_content['description']
      effective_quota = atom_content['effective_quota'].to_i
      gigabytes_quota = effective_quota / (1024.0 * 1024.0 * 1024.0)
      used_bytes = atom_content['used_bytes'].to_i
      gigabytes_used = used_bytes / (1024.0 * 1024.0 * 1024.0)
      percentage_used = (used_bytes.to_f / effective_quota.to_f) * 100.0

      # output metrics
      output "#{config[:scheme]}.#{description}.effective_quota", effective_quota
      output "#{config[:scheme]}.#{description}.gigabytes_quota", gigabytes_quota
      output "#{config[:scheme]}.#{description}.used_bytes", used_bytes
      output "#{config[:scheme]}.#{description}.gigabytes_used", gigabytes_used
      output "#{config[:scheme]}.#{description}.percentage_used", percentage_used

      if atom_content['slaves_usage_bytes'].is_a?(Hash)
        atom_content['slaves_usage_bytes'].each do |slave,slave_used_bytes|
          output "#{config[:scheme]}.#{description}.slave.#{slave}.used_bytes", slave_used_bytes
        end
      end
    end

    ok
  end
end
