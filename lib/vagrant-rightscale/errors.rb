require "vagrant"

module VagrantPlugins
  module RightScale
    module Errors
      class VagrantRightScaleError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_rightscale.errors")
      end

      class RightAPIError < VagrantRightScaleError
        error_key(:right_api_error)
      end

      class InternalAPIError < VagrantRightScaleError
        error_key(:internal_right_api_error)
      end

      class InstanceReadyTimeout < VagrantRightScaleError
        error_key(:instance_ready_timeout)
      end

      class RsyncError < VagrantRightScaleError
        error_key(:rsync_error)
      end

      class MkdirError < VagrantRightScaleError
        error_key(:mkdir_error)
      end
    end
  end
end