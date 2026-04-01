require 'xcodeproj'
require 'fileutils'

project_path = 'BSAI.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

group = project.main_group.find_subpath('BSAI', true)

# Add known regions
project.root_object.known_regions << "en" << "hi" << "te" << "ta" << "kn"
project.root_object.known_regions.uniq!

variant_group = group.children.find { |c| c.name == 'Localizable.strings' && c.class == Xcodeproj::Project::Object::PBXVariantGroup }

if variant_group.nil?
  variant_group = group.new_variant_group('Localizable.strings')
  target.resources_build_phase.add_file_reference(variant_group, true)
end

['en', 'hi', 'te', 'ta', 'kn'].each do |lang|
  dir_path = "BSAI/#{lang}.lproj"
  FileUtils.mkdir_p(dir_path)
  file_path = "#{dir_path}/Localizable.strings"
  unless File.exist?(file_path)
    File.write(file_path, "/* Localized strings for #{lang} */\n")
  end
  
  unless variant_group.files.any? { |f| f.name == lang }
    ref = variant_group.new_file("#{lang}.lproj/Localizable.strings")
    ref.name = lang
  end
end

project.save
puts "Localization setup complete"
