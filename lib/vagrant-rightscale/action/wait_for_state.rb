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

require "log4r"
require "timeout"

module VagrantPlugins
  module RightScale
    module Action
      # This action will wait for a rightscale server to reach a specific state or quit by timeout
      class WaitForState
        # env[:result] will be false in case of timeout.
        # @param [Symbol] state Target machine state.
        # @param [Number] timeout Timeout in seconds.
        def initialize(app, env, state, timeout)
          @app     = app
          @logger  = Log4r::Logger.new("vagrant_rightscale::action::wait_for_state")
          @state   = state
          @timeout = timeout
        end

        def call(env)
          env[:result] = true
          server_state = env[:server].show.state

          if server_state == @state
            @logger.info(I18n.t("vagrant_rightscale.already_status", :status => @state))
          else
            @logger.info "Waiting for server to transition to #{@state} status..."
            @logger.info "Timeout is #{@timeout} seconds."
            begin
              Timeout::timeout(@timeout) {
                while server_state != @state.to_s
                  server_state = env[:server].show.state
                  @logger.debug "@state=#{@state} server_state=#{server_state}"
                  sleep 2
                end
                @logger.info "Server is now in #{@state} state."
              }
            rescue Timeout::Error
              @logger.error "Server did not reach #{@state} within #{@timeout} seconds!"
            end
          end

          @app.call(env)
        end
      end
    end
  end
end