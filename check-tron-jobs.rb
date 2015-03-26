#!/usr/bin/env ruby
#
# Checks the run status of one or more tron jobs
# ===
#
# DESCRIPTION:
#   This plugin checks the run status of one or more tron jobs
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   all
#
# DEPENDENCIES:
#   sensu-plugin Ruby gem
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'json'
require 'net/http'

class TronJobStatus < Sensu::Plugin::Check::CLI

  option :server,
    :description => 'Tron server',
    :short => '-s SERVER',
    :long => '--server SERVER',
    :default => 'localhost:8089'
  option :jobs,
    :description => 'Jobs to check or ALL',
    :short => '-j JOB,JOB,JOB',
    :long => '--jobs JOB,JOB,JOB...',
    :default => 'ALL'

  def get_job_names
    uri = URI.parse("http://#{config[:server]}/api/jobs")
    response = Net::HTTP.get_response(uri)
    JSON.load(response.body)['jobs'].map{|j| j['name']}
  end

  def get_last_run_state(jobname)
    state="unknown"
    uri = URI.parse("http://#{config[:server]}/api/jobs/#{jobname}")
    response = Net::HTTP.get_response(uri)
    run_data  = JSON.load(response.body)
    if run_data['runs'] && run_data['runs'].any?
      states = run_data['runs'].map{|run| run['state']}
      for state in states
        return state unless %w{running scheduled queued}.include? state
      end
    end
    state
  end

  def run
    if config[:jobs]=='ALL'
      job_names = get_job_names
    else
      job_names = config[:jobs].split(',')
    end
    failures = []
    job_names.each do |name|
      state = get_last_run_state(name)
      failures << name if state == 'failed'
    end
    if failures.any? 
      critical "Tron jobs failing: #{failures.join(" ")}"
    else
      ok "Tron jobs succeeding."
    end
  end
end
