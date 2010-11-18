require 'rake/testtask'
require 'date'

# Helpers
begin
  def name
    @name ||= Dir['*.gemspec'].first.split('.').first
  end

  def version
    line = File.read("lib/#{name}.rb")[/^\s*VERSION\s*=\s*.*/]
    line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
  end

  def date
    Date.today.to_s
  end

  def rubyforge_project
    name
  end

  def gemspec_file
    "#{name}.gemspec"
  end

  def gem_file
    "#{name}-#{version}.gem"
  end

  def replace_header(head, header_name)
    head.sub!(/(\.#{header_name}\s*= ').*'/) { "#{$1}#{send(header_name)}'"}
  end
end

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
end

desc "Run tests against all supported Ruby versions"
task :compat do
  sh "rvm 1.9.2@audit,ree-1.8.7-2010.01@audit rake test"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Build, tag, push and publish a new release."
task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
  sh "git push origin master"
  sh "git push origin v#{version}"
  sh "gem push pkg/#{name}-#{version}.gem"
end

desc "Build a new gem"
task :build => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

desc "Update the generated gemspec"
task :gemspec => :validate do
  # read spec file and split out manifest section
  spec = File.read(gemspec_file)
  head, manifest, tail = spec.split("  # = MANIFEST =\n")

  # replace name version and date
  replace_header(head, :name)
  replace_header(head, :version)
  replace_header(head, :date)
  #comment this out if your rubyforge_project has a different name
  replace_header(head, :rubyforge_project)

  # determine file list from git ls-files
  files = `git ls-files`.
    split("\n").
    sort.
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg)/ }.
    map { |file| "    #{file}" }.
    join("\n")

  # piece file back together and write
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(gemspec_file, 'w') { |io| io.write(spec) }
  puts "Updated #{gemspec_file}"
end

task :validate do
  libfiles = Dir['lib/*'] - ["lib/#{name}.rb", "lib/#{name}"]
  unless libfiles.empty?
    puts "Directory `lib` should only contain a `#{name}.rb` file and `#{name}` dir."
    exit!
  end
  unless Dir['VERSION*'].empty?
    puts "A `VERSION` file at root level violates Gem best practices."
    exit!
  end
end
