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
      # This action launches the server in the given RightScale deployment
      class LaunchServer
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::launch_server")
        end

        def call(env)
          if env[:server].show.raw['state'] == 'inactive'
            @logger.info 'Launching server...'
            env[:ui].info(I18n.t('vagrant_rightscale.launching'))
            env[:server].launch
          else
            @logger.info 'Server not inactive, skipping launch.'
            env[:ui].info(I18n.t('vagrant_rightscale.already_status'))
          end

          @app.call(env)
        end
      end
    end
  end
end
