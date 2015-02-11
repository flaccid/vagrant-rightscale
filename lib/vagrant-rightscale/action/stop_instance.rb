# Author:: Chris Fordham (<chris@fordham-nagy.id.au>)
# Copyright:: Copyright (c) 2013 Chris Fordham
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'log4r'
require 'json'
require 'vagrant/util/retryable'
require 'vagrant-rightscale/util/timer'

module VagrantPlugins
  module RightScale
    module Action
      # This stops the configured instance.
      class StopInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::run_instance")
        end

        def call(env)
          @logger.debug "TODO: there should be logic in here to stop a server instead of terminate if supported"

          # Find the server
          results = env[:rightscale].tags.by_tag(
            resource_type: 'servers',
            tags: ["vagrant:box_name=#{env[:machine].box.name}"])

          servers = []
          results.each { |resource| servers.push(resource.raw) }

          @logger.debug "Found #{results.count} servers with tag, 'vagrant:box_name=#{env[:machine].box.name}'"
          server_id = servers[0]['links'].first['href'].split('/').last

          @logger.debug "servers found: #{servers}"
          @logger.debug "first server ID: #{server_id}"

          # Check operational state of the server first
          server_state = env[:rightscale].servers(id: server_id).show.raw['state']
          @logger.debug "server state: #{server_state}"

          if server_state == 'inactive'
            @logger.info "RightScale server, #{server_id} is not active."
            env[:ui].info(I18n.t("vagrant_rightscale.not_created"))
          else
            env[:ui].info(I18n.t("vagrant_rightscale.terminating"))
            terminate(env, server_id)
          end

          return server_state.to_sym
        end

        def terminate(env, server_id)
          @logger.info "Terminating server, #{server_id}..."
          env[:rightscale].servers(id: server_id).terminate
        end
      end
    end
  end
end
