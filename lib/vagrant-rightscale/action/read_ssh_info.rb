# Author:: Chris Fordham (<chris@fordham-nagy.id.au>)
# Copyright:: Copyright (c) 2013-2014 Chris Fordham
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
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_rightscale::\
            action::read_ssh_info')
        end

        def call(env)
          env[:server_ssh_info] = instance_ssh_info(env)

          @app.call(env)
        end
        
        def instance_ssh_info(env)
          @logger.debug env[:rightscale]

          # for some reason env[:rightscale] is not set  wtf
          rightscale_config = YAML.load_file(File.join(ENV['HOME'], '.rightscale', 'right_api_client.yml'))
          env[:rightscale] = RightApi::Client.new(rightscale_config)

          # Find the server by tag with rightscale
          results = env[:rightscale].tags.by_tag(
            match_all: true,
            resource_type: 'servers',
            tags: ["vagrant:box_name=#{env[:machine].box.name}"]
          )
          servers = []
          results.each { |resource| servers.push(resource.raw) }

          @logger.debug "Servers found with tag: #{servers}"

          # get info for the instance of the first server found
          server_id = servers.first['links'][0]['href'].split('/').last
          server = env[:rightscale].servers.index(:id => server_id)
          current_instance = env[:rightscale].servers(:id => server_id).show.current_instance.show
          public_ip_address = current_instance.raw['public_ip_addresses'][0]

          ssh_host_info = {
            :host => public_ip_address,
            :port => 22,
            :username => 'rightscale',
            :private_key_path => File.join(File.expand_path('~'), '.ssh', 'id_rsa')
          }

          @logger.debug "ssh_info: #{ssh_host_info}"

          return ssh_host_info
        end
      end
    end
  end
end
