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
require 'vagrant/util/subprocess'
require 'vagrant/util/scoped_hash_override'
require 'vagrant/util/which'

module VagrantPlugins
  module RightScale
    module Action
      # This middleware uses `rsync` to sync the folders over to the
      # rightscale server.
      class SyncFolders
        include Vagrant::Util::ScopedHashOverride

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_rightscale::\
            action::sync_folders")
        end

        def call(env)
          @app.call(env)

          #ssh_info = env[:server_ssh_info]

          unless Vagrant::Util::Which.which('rsync')
            env[:ui].warn(I18n.t('vagrant_rightscale.rsync_not_found_warning', :side => "host"))
            return
          end

          if env[:machine].communicate.execute('which rsync', :error_check => false) != 0
            env[:ui].warn(I18n.t('vagrant_rightscale.rsync_not_found_warning', :side => "guest"))
            return
          end

          env[:machine].config.vm.synced_folders.each do |id, data|
            data = scoped_hash_override(data, :rightscale)

            # Ignore disabled shared folders
            next if data[:disabled]

            hostpath  = File.expand_path(data[:hostpath], env[:root_path])
            guestpath = data[:guestpath]

            # Make sure there is a trailing slash on the host path to
            # avoid creating an additional directory with rsync
            hostpath = "#{hostpath}/" if hostpath !~ /\/$/

            # on windows rsync.exe requires cygdrive-style paths
            if Vagrant::Util::Platform.windows?
              hostpath = hostpath.gsub(/^(\w):/) { "/cygdrive/#{$1}" }
            end

            env[:ui].info(I18n.t("vagrant_rightscale.rsync_folder",
                                :hostpath => hostpath,
                                :guestpath => guestpath))

            # Create the host path if it doesn't exist and option flag is set
            if data[:create]
              begin
                FileUtils::mkdir_p(hostpath)
              rescue => err
                raise Errors::MkdirError,
                  :hostpath => hostpath,
                  :err => err
              end
            end

            # Create the guest path
            env[:machine].communicate.sudo("mkdir -p '#{guestpath}'")
            env[:machine].communicate.sudo(
              "chown #{ssh_info[:username]} '#{guestpath}'"
            )

            # Rsync over to the guest path using the SSH info
            command = [
              "rsync", "--verbose", "--archive", "-z",
              "--exclude", ".vagrant/", "--exclude", "Vagrantfile",
              "-e", "ssh -p #{ssh_info[:port]} -o StrictHostKeyChecking=no -i '#{ssh_info[:private_key_path]}'",
              hostpath,
              "#{ssh_info[:username]}@#{ssh_info[:host]}:#{guestpath}"]

            # we need to fix permissions when using rsync.exe on windows, see
            # http://stackoverflow.com/questions/5798807/rsync-permission-denied-created-directories-have-no-permissions
            if Vagrant::Util::Platform.windows?
              command.insert(1, "--chmod", "ugo=rwX")
            end

            r = Vagrant::Util::Subprocess.execute(*command)
            if r.exit_code != 0
              raise Errors::RsyncError,
                :guestpath => guestpath,
                :hostpath => hostpath,
                :stderr => r.stderr
            end
          end
        end
      end
    end
  end
end
