require 'rubygems'

desc "Run the puppet linter"
task :lint do
  sh "openvox-lint manifests/"
end

desc "Validate manifests, templates, and ruby files"
task :validate do
  sh "puppet parser validate manifests/"
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end
