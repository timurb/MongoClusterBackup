# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'lib/mongo_cluster_backup/version'

spec = Gem::Specification.new do |s|
  s.name = 'MongoClusterBackup'
  s.version = MongoBackup::VERSION
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE']
  s.summary = 'A tool to backup sharded mongo cluster'
  s.description = s.summary
  s.author = 'Timur Batyrshin'
  s.email = 'timur.batyrshin@flathost.ru'
  s.executables = ['mongobackup']
  s.files = %w(LICENSE README.rdoc Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  s.add_dependency('mongo')
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README.rdoc', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.rdoc" # page to start on
  rdoc.title = "MongoClusterBackup Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end
