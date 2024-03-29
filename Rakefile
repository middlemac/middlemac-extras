require 'bundler/gem_tasks'
require 'cucumber/rake/task'
require 'yard'
require 'git'
require File.expand_path('../lib/middlemac-extras/version.rb', __FILE__)


###############################################################################
# :default
#   Define the default task.
###############################################################################
task :default => :test


###############################################################################
# :test
#   Perform Cucumber testing.
###############################################################################
Cucumber::Rake::Task.new(:test, 'Features that must pass') do |task|
  task.cucumber_opts = '--publish-quiet --require features --color --tags "not @wip" --strict --format pretty 2>/dev/null'
end

Cucumber::Rake::Task.new(:testnoisy, 'Features that must pass') do |task|
  task.cucumber_opts = '--publish-quiet --require features --color --tags "not @wip" --strict --format pretty'
end


###############################################################################
# :yard
#   Generate documentation using YARD. Note that there is a `.yardopts` file
#   present that will load the `yard/yard_extensions.rb` file in order to
#   control how output is generated. Output will be to the default `doc`
#   directory using the template-grouped template, as a single page.
###############################################################################
YARD::Rake::YardocTask.new(:yard) do |task|
  task.stats_options = ['--list-undoc']
end


###############################################################################
# :partials
#   Generate documentation partials using YARD. These are used by the
#   documentation project in order to include the API documentation.
###############################################################################
desc 'Make separate documents for documentation_project'
task :partials do

  # Define the @!group to output file relationships.
  sections = [
      { :file => '_yard_helpers.erb',          :group => 'Helpers',  },
      { :file => '_yard_helpers_extended.erb', :group => 'Extended Helpers' },
      { :file => '_yard_config.erb',           :group => 'Extension Configuration' },
  ]
  
  # Define the output directory.
  dest = File.join('documentation_project', 'source', 'partials')

  # Run YARD multiple times, filtering the group that interests us.
  sections.each do |s|
    params = [
      "--query 'o.group == \"#{s[:group]}\" || has_tag?(:author)'",
      "-o #{dest}",
      "-t default",
      "-p #{File.join(File.dirname(__FILE__), 'yard', 'template-partials')}"     
     ]
    command = "yardoc #{params.join(' ')}"
    puts command
    system(command)
    File.rename( File.join(dest, 'index.html'), File.join(dest, s[:file]) )
  end

end


###############################################################################
# :version
#   Displays the current version.
###############################################################################
desc 'Displays the current version'
task :version do
  puts "Current version: #{Middleman::MiddlemacExtras::VERSION}"
end


###############################################################################
# :version_finalize
#   Remove any wip suffix from the version, as we are ready to release.
###############################################################################
desc 'Remove any wip suffix from the version'
task :version_finalize do
  version_old = Middleman::MiddlemacExtras::VERSION
  version_new = version_old.sub('.wip', '')
  update_versions( version_new )
end


###############################################################################
# :version_next_wip
#   Increment the patch level and add a wip suffix. We are ready for work.
###############################################################################
desc 'Increment the patch level and add a wip suffix'
task :version_next_wip do
  version_old = Middleman::MiddlemacExtras::VERSION
  version_new = version_old.sub('.wip', '').split('.')
  version_new.last.succ!
  version_new = version_new.join('.') + '.wip'
  update_versions( version_new )
end


###############################################################################
# :version_set
#   Sets an arbitrary version.
###############################################################################
desc 'Sets all of the files to the version specified. Use rake version_set[value].'
task :version_set, :new_version do |t, args|
  update_versions( args[:new_version] )
end


###############################################################################
# :log
#   Generate the CHANGELOG.md file.
###############################################################################
desc 'Generate the CHANGELOG.md file'
task :log do
  report = ''
  report << "middlemac-extras change log\n"
  report << "===========================\n"

  Git.open( File.expand_path('..', __FILE__) ).log.each_with_index do |l, i|

    version = nil
    if i == 0 && !l.name.start_with?('tags/')
      version = "Version #{Middleman::MiddlemacExtras::VERSION}"
    elsif l.name.end_with?('^0')
      version = "Version #{l.name.match(/tags\/v(.*)\^0/)[1]}"
    end
    
    if version
      report << "\n- #{version} / #{l.date.strftime('%Y-%B-%d')}\n"
      report << "\n"
    end
    
    l.message.each_line.with_index do |line, lineno| 
      if lineno == 0
        report << "  - #{line}"
      else
        report << "    #{line}" unless line.strip == ''
      end
    end
    report << "\n"
  end # Git.open

  file = File.expand_path('../CHANGELOG.md', __FILE__)
  File.write(file, report)
  puts "The changelog has been written."
end


###############################################################################
# :pre_release
#   Prepares the project for release.
###############################################################################
desc "Prepares the project for release"
task :pre_release do

  if `git status -s`.length > 0
    puts "Cannot continue because you have uncommitted changes."
    exit 1
  end

  Rake::Task[:version_finalize].execute
  Rake::Task[:partials].execute
  Rake::Task[:log].execute
  sh "git add -A"
  sh "git commit --amend --no-edit"
end

private


###############################################################################
# update_versions
#   Update the version in various files that depend on the correct version.
###############################################################################
def update_versions( version_new )
  [ {
      :file  => File.expand_path('../lib/middlemac-extras/version.rb', __FILE__),
      :regex => /(?<=VERSION = ')(.*)(?=')/
    },
    {
      :file  => File.expand_path('../documentation_project/Gemfile', __FILE__),
      :regex => /(?<=gem 'middlemac-extras', '~> ).*(?=')/
    },
    {
      :file  => File.expand_path('../documentation_project/config.rb', __FILE__),
      :regex => /(?<=def product_version\n    ').*?(?='\n  end)/m
    },
  ].each do | item |
    
    content = File.read( item[:file] )
    content.gsub!( item[:regex], version_new )
    File.write( item[:file], content )
    puts "#{File.basename( item[:file] )} changed to '#{version_new}'."
  end

  Middleman::MiddlemacExtras::VERSION.replace version_new
end
