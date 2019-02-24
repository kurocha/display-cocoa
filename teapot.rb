# Teapot v3.0.0 configuration generated at 2019-02-24 12:58:53 +1300

required_version "3.0"

define_project "display-cocoa" do |project|
	project.title = "Display Cocoa"
end

# Build Targets

define_target 'display-cocoa-platform' do |target|
	target.provides 'Display/Cocoa/Platform' do
		append linkflags %W{-framework Metal -framework IOSurface -framework Cocoa -framework QuartzCore -framework IOKit -framework CoreFoundation -framework Foundation}
	end
end

define_target 'display-cocoa-library' do |target|
	target.depends 'Language/C++14'
	
	target.depends 'Display/Cocoa/Platform', public: true
	
	target.depends 'Library/Logger', public: true
	target.depends 'Library/Display', public: true
	
	target.provides 'Library/Display/Cocoa' do
		source_root = target.package.path + 'source'
		
		library_path = build static_library: 'DisplayCocoa', source_files: source_root.glob('Display/Cocoa/**/*.{cpp,mm}')
		
		append linkflags library_path
		append header_search_paths source_root
	end
	
	target.provides :display_native => 'Library/Display/Cocoa'
end

define_target 'display-cocoa-test' do |target|
	target.depends 'Library/Display/Cocoa'
	target.depends 'Library/UnitTest'
	
	target.depends 'Language/C++14'
	
	target.provides 'Test/Display/Cocoa' do |arguments|
		test_root = target.package.path + 'test'
		
		run tests: 'DisplayCocoa', source_files: test_root.glob('Display/Cocoa/**/*.cpp'), arguments: arguments
	end
end

# Configurations

define_configuration 'development' do |configuration|
	configuration[:source] = "https://github.com/kurocha"
	configuration.import "display-cocoa"
	
	# Provides all the build related infrastructure:
	configuration.require 'platforms'
	
	# Provides unit testing infrastructure and generators:
	configuration.require 'unit-test'
	
	# Provides some useful C++ generators:
	configuration.require 'generate-cpp-class'
	
	configuration.require "generate-project"
end

define_configuration "display-cocoa" do |configuration|
	configuration.public!
	
	configuration.require 'display'
end
