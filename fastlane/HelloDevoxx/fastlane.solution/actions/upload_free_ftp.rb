require 'net/ftp'

module Fastlane
  module Actions
    module SharedValues
    end

    class UploadFreeFtpAction < Action
      def self.run(params)
        random = ""; 8.times{random << (65 + rand(25)).chr}
        UI.message "we upload #{params[:binary]}"
        ftp = Net::FTP.new('ec2-54-93-156-69.eu-central-1.compute.amazonaws.com')
        ftp.login 'bob', 'devoxx'
        ftp.putbinaryfile params[:binary], "#{random}.jar"
        ftp.close
        UI.message "done"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        "You can use this action to do cool things..."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binary,
                                       env_name: "FL_UPLOAD_FREE_FTP_BINARY",
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: true) # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["github.com/sylvek"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
