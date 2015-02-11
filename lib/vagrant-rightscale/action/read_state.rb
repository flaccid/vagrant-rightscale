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

module VagrantPlugins
  module RightScale
    module Action
      # This action reads the state of the rightscale server and
      # puts it in the `:server_state` key in the environment.
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::read_state")
        end

        def call(env)
          env[:machine_state_id] = read_state(env)

          @app.call(env)
        end

        def read_state(env)
          # rightscale possible states: operational, inactive

          # vagrant possible states: running, not_created, stopped, stopping, pending

          # Find the server
          results = env[:rightscale].tags.by_tag(
            resource_type: 'servers',
            tags: ["vagrant:box_name=#{env[:machine].box.name}"])

          servers = []
          results.each { |resource| servers.push(resource.raw) }

          @logger.debug "Servers found with tag: #{servers}"

          server_href = servers.first['links'].select { |x| x = 'rel' }.first['href']
          server_id = server_href.split('/').last
          server = env[:rightscale].servers.index({ :id => server_id }).show.raw
          state = server['state']
          
          @logger.debug "selected server: #{server}"
          @logger.debug "rightscale server state: #{state}"

          state = state

          # Return the state
          return state.to_sym
        end
      end
    end
  end
end
