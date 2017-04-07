module Fastlane
  module Actions
    module SharedValues
    end

    class ZipalignAction < Action
      def self.run(params)

       Fastlane::Actions.sh("#{params[:android_build_tools_path]}/zipalign -f -v 4 #{params[:unaligned_apk_path]} #{params[:aligned_apk_path]}", log: false)
       UI.message('Input apk is aligned')

     end
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
      end

      def self.available_options

        apk_path_default = Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "*release.apk")].last

        [
          FastlaneCore::ConfigItem.new(key: :android_build_tools_path,
                                       env_name: "ANDROID_BUILD_TOOLS_PATH",
                                       description: "Path to your android build tools",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :aligned_apk_path,
                                       env_name: "INPUT_APK_PATH",
                                       description: "Path to your APK file that you want to align",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] || apk_path_default,
                                       optional: true),
         FastlaneCore::ConfigItem.new(key: :unaligned_apk_path,
                                      env_name: "OUTPUT_APK_PATH",
                                      description: "Path to your APK file aligned")
        ]
      end

      def self.authors
        ["nomisRev"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
