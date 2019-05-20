inhibit_all_warnings!

platform :osx, '10.14'

target 'mintgen' do
  pod 'xcodeproj', '6.7.0'
  pod 'Stencil', '0.13.1'
  
  post_install do |installer|
      swift4 = [
        'xcodeproj'
      ]
      
      installer.pods_project.targets.each do |target|
          if swift4.include? target.name
              target.build_configurations.each do |configuration|
                  configuration.build_settings['SWIFT_VERSION'] = '4.2'
              end
          end
      end
  end
end
