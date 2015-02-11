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
      # This action terminates the server in the given RightScale deployment
      class TerminateServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::terminate_server")
        end

        def call(env)
          @logger.info("Terminating server with tag, \
            'vagrant:box_name=#{env[:machine].box.name}'...")

          # Find the server
          servers = env[:rightscale].tags.by_tag(
            resource_type: 'servers',
            tags: ["vagrant:box_name=#{env[:machine].box.name}"]).index
          @logger.debug "Servers found with tag: #{servers}"

          # Terminate the first server found
          servers.first.terminate

          @app.call(env)
        end
      end
    end
  end
end
