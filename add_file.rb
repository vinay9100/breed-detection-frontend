require 'xcodeproj'
project_path = 'BSAI.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
group = project.main_group.find_subpath('BSAI', true)
file_reference = group.new_file('BPARegistrationView.swift')
target.source_build_phase.add_file_reference(file_reference)
project.save
