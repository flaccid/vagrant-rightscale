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
      # This action connects to RightScale, verifies credentials work, and
      # puts the RightScale connection object into the `:rightscale_compute` key
      # in the environment.
      class ConnectRightScale
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::action::connect_rightscale")
        end

        def call(env)
          @logger.info("Connecting to RightScale...")

          rightscale_config = YAML.load_file(File.join(ENV['HOME'], '.rightscale', 'right_api_client.yml'))
          env[:rightscale] = RightApi::Client.new(rightscale_config)
          @logger.debug(env[:rightscale])

          @app.call(env)
        end
      end
    end
  end
end
