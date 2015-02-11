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

require 'right_api_client'
require 'log4r'

module VagrantPlugins
  module RightScale
    module Action
      # This action creates the server in the given RightScale deployment
      class CreateServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::create_server")
        end

        def call(env)
          cloud_id = env[:machine].provider_config.cloud_id
          deployment_href = env[:machine].provider_config.deployment_href
          server_name = env[:machine].provider_config.server_name
          server_template_id = env[:machine].provider_config.server_template_id
          ssh_key_href = "/api/clouds/#{cloud_id}/ssh_keys/#{env[:machine].provider_config.ssh_key_id}"
          tag = "vagrant:box_name=#{env[:machine].box.name}"

          @logger.info "Checking if server already exists..."
          # Find the server
          results = env[:rightscale].tags.by_tag(
            resource_type: 'servers',
            tags: ["vagrant:box_name=#{env[:machine].box.name}"]).index
          servers = []
          results.each { |result| servers.push result.raw }

          @logger.debug "server count: #{servers.count}"
          @logger.debug "Servers found with tag: #{servers}"

          #results.each { |result| puts result}

          if servers.count == 0
            @logger.info('Creating server...')

            # create a hash of the params for server creation with rightscale
            server = {}
            server['name'] = server_name
            server['deployment_href'] = deployment_href
            server['instance'] = {
              'cloud_href' => "/api/clouds/#{cloud_id}",
              'server_template_href' => "/api/server_templates/#{server_template_id}"
            }
            #server['instance']['ssh_key_href'] = ssh_key_href      # todo

            env[:server] = env[:rightscale].servers.create({ :server => server })

            @logger.info "Adding RightScale tag, '#{tag}' to resource #{env[:server].href}."
            env[:rightscale].tags.multi_add(:resource_hrefs => [env[:server].href], :tags => [tag])
          else
            server_id = servers.first['links'][0]['href'].split('/').last
            @logger.debug "Existing server found, #{server_id}."
            env[:server] = env[:rightscale].servers.index(id: server_id)
          end

          @app.call(env)
        end
      end
    end
  end
end
