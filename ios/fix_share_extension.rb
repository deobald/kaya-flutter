#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Share Extension group
share_group = project.main_group.groups.find { |g| g.name == 'Share Extension' }

if share_group.nil?
  puts "Share Extension group not found"
  exit 1
end

# Fix file references - remove the doubled path
share_group.files.each do |file|
  if file.path && file.path.start_with?('Share Extension/')
    # Remove the "Share Extension/" prefix since the group already has the path
    new_path = file.path.sub('Share Extension/', '')
    puts "Fixing path: #{file.path} -> #{new_path}"
    file.path = new_path
  end
end

project.save
puts "File paths fixed!"
