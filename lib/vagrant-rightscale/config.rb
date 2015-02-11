require "vagrant"

module VagrantPlugins
  module RightScale
    class Config < Vagrant.plugin("2", :config)
      # The RightScale account ID
      #
      # @return [String]
      attr_accessor :account_id

      # The RightScale API URL
      #
      # @return [String]
      attr_accessor :api_url

      # The RightScale API version
      #
      # @return [String]
      attr_accessor :api_version

      # The cloud (ID) to launch the server in
      #
      # @return [String]
      attr_accessor :cloud_id

      # The deployment to launch the server in
      #
      # @return [String]
      attr_accessor :deployment

      # The deployment to launch the server in
      #
      # @return [String]
      attr_accessor :deployment_href

      # The RightScale user password
      #
      # @return [String]
      attr_accessor :password

      # The ServerTemplate (ID) to use for the server
      #
      # @return [String]
      attr_accessor :server_name

      # The ServerTemplate (ID) to use for the server
      #
      # @return [String]
      attr_accessor :server_template_id

      # Specifies which address to connect to with ssh
      # Must be one of:
      #  - :public_ip_address
      #  - :dns_name
      #  - :private_ip_address
      # This attribute also accepts an array of symbols
      #
      # @return [Symbol]
      attr_accessor :ssh_host_attribute

      # The RightScale ssh_key_href to create the server with
      #
      # @return [String]
      attr_accessor :ssh_key_id

      # The RightScale user ID (email)
      #
      # @return [String]
      attr_accessor :user_id
      
      def initialize()
        @account_id             = UNSET_VALUE
        @api_url                = UNSET_VALUE
        @api_version            = UNSET_VALUE
        @cloud_id               = UNSET_VALUE
        @deployment             = UNSET_VALUE
        @deployment_href        = UNSET_VALUE
        @password               = UNSET_VALUE
        @server_name            = UNSET_VALUE
        @server_template        = UNSET_VALUE
        @ssh_host_attribute     = UNSET_VALUE
        @ssh_key_id             = UNSET_VALUE
        @user_id                = UNSET_VALUE
      end

      #-------------------------------------------------------------------
      # Internal methods.
      #-------------------------------------------------------------------

      def finalize!
        # Try to get credentials from RS environment variables; they
        # will default to nil if the environment variables are not present.
        @account_id     = ENV['RS_ACCOUNT_ID'] if @account_id   == UNSET_VALUE
        @api_url        = ENV['RS_API_URL'] if @api_url         == UNSET_VALUE
        @api_version    = ENV['RS_API_VERSION'] if @api_version == UNSET_VALUE
        @password       = ENV['RS_PASSWORD'] if @api_url        == UNSET_VALUE
        @user_id        = ENV['RS_USER'] if @api_url            == UNSET_VALUE

        # deployment must be nil, since we can't default that
        @deployment = nil if @deployment == UNSET_VALUE

        # Set the default cloud_id to 1 which should be EC2 us-east-1
        @cloud_id = 1 if @cloud_id == UNSET_VALUE

        # provide a default RightScale server name if unset
        @server_name = 'Vagrant Box' if @server_name == UNSET_VALUE

        # default to nil
        @ssh_host_attribute = nil if @ssh_host_attribute == UNSET_VALUE

        # Mark that we finalized
        @__finalized = true
      end

      def validate(machine)
        errors = _detected_errors
        #errors << I18n.t("vagrant_rightscale.config.account_id_required") if config.account_id.nil?
        #errors << I18n.t("vagrant_rightscale.config.deployment_required") if config.deployment.nil?

        { "RightScale Provider" => errors }
      end
    end
  end
end
