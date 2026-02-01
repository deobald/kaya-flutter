#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Check if Share Extension target already exists
if project.targets.any? { |t| t.name == 'Share Extension' }
  puts "Share Extension target already exists"
  exit 0
end

# Create Share Extension target
share_extension = project.new_target(:app_extension, 'Share Extension', :ios, '13.0')
share_extension.product_name = 'Share Extension'

# Create Share Extension group
share_group = project.main_group.new_group('Share Extension', 'Share Extension')

# Add source files (paths are relative to the group's path)
swift_file = share_group.new_file('ShareViewController.swift')
storyboard_file = share_group.new_file('MainInterface.storyboard')
plist_file = share_group.new_file('Info.plist')
entitlements_file = share_group.new_file('Share Extension.entitlements')

# Add files to target
share_extension.add_file_references([swift_file])
share_extension.add_file_references([storyboard_file])

# Configure build settings for all configurations
share_extension.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = 'Share Extension/Info.plist'
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'ca.deobald.kaya.ShareExtension'
  config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Share Extension/Share Extension.entitlements'
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['DEVELOPMENT_TEAM'] = 'Z8C46829M8'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['CUSTOM_GROUP_ID'] = 'group.ca.deobald.kaya'
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
    '$(inherited)',
    '@executable_path/Frameworks',
    '@executable_path/../../Frameworks'
  ]
end

# Also set CUSTOM_GROUP_ID for Runner target
runner_target = project.targets.find { |t| t.name == 'Runner' }
runner_target.build_configurations.each do |config|
  config.build_settings['CUSTOM_GROUP_ID'] = 'group.ca.deobald.kaya'
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

# Add Share Extension as dependency of Runner
runner_target.add_dependency(share_extension)

# Add embed extension build phase
embed_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
embed_phase.dst_subfolder_spec = '13'  # PlugIns folder
embed_phase.add_file_reference(share_extension.product_reference)

# Move embed phase before "Thin Binary"
thin_binary_index = runner_target.build_phases.find_index { |p| p.display_name == 'Thin Binary' }
if thin_binary_index
  runner_target.build_phases.move(embed_phase, thin_binary_index)
end

project.save

puts "Share Extension target added successfully!"
