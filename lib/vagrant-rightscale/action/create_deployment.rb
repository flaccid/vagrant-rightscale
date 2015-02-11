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
      # This action creates the deployment in RightScale if it does not already exist
      class CreateDeployment
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::create_deployment")
        end

        def call(env)
          deployment_name = env[:machine].provider_config.deployment

          if deployment_name == 'Default'
            @logger.debug('Skipping creation of immutable default deployment.')
          else
            deployment = {
              :name => deployment_name
            }
            @logger.info("Checking if deployment '#{deployment_name}' exists...")
            
            deployments = []
            filter = []
            filter.push("name==#{deployment_name}")
            env[:rightscale].deployments.index(:filter => filter).each { |deployment|
              deployments.push(deployment.raw)
            }
    
            if deployments.count > 0
              @logger.info("Deployment '#{deployment_name}' exists.")
              env[:machine].provider_config.deployment_href = deployments[0]['links'][0]['href'].chomp("/#{deployments[0]['links'][0]['href'].split('/').last}")
            else
              @logger.info("Deployment '#{deployment_name}' does not exist.")
              @logger.info("Creating deployment...")
              new_deployment = env[:rightscale].deployments.create({ :deployment => deployment })
              env[:machine].provider_config.deployment_href = new_deployment.href
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
