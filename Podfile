# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Uber Clone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  post_install do |installer|
    
    #    if target.name == 'BoringSSL-GRPC'
    #      target.source_build_phase.files.each do |file|
    #        if file.settings && file.settings['COMPILER_FLAGS']
    #          flags = file.settings['COMPILER_FLAGS'].split
    #          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
    #          file.settings['COMPILER_FLAGS'] = flags.join(' ')
    #        end
    #      end
    #    end
    
    installer.pods_project.targets.each do |target|
      
      if target.name == 'BoringSSL-GRPC'
            target.source_build_phase.files.each do |file|
              if file.settings && file.settings['COMPILER_FLAGS']
                flags = file.settings['COMPILER_FLAGS'].split
                flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
                file.settings['COMPILER_FLAGS'] = flags.join(' ')
              end
            end
          end
      
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
      end
    end
  end
  
  # Pods for Uber Clone
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseCore'
  pod 'GeoFire', '>= 1.1'
  
end
