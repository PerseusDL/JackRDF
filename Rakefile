require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end


FUSEKI_VERSION = "1.0.2"
FUSEKI_DIR = "jena-fuseki-#{FUSEKI_VERSION}"
FUSEKI_TAR = "#{FUSEKI_DIR}-distribution.tar.gz"
FUSEKI_EXE = "fuseki/#{FUSEKI_DIR}/fuseki-server"
FUSEKI_TRIPLES = "/var/www/JackRDF/triples"
FUSEKI_HOST = "http://localhost"
FUSEKI_PORT = "4321"
FUSEKI_DATASTORE = "ds"
FUSEKI_ENDPOINT = "#{FUSEKI_HOST}:#{FUSEKI_PORT}/#{FUSEKI_DATASTORE}"

desc "Run tests"
task :default => :test

namespace :server do
  desc 'Download and install Fuseki'
  task :install do
    `curl -O http://archive.apache.org/dist/jena/binaries/#{FUSEKI_TAR}`
    `mkdir fuseki`
    `tar xzvf #{FUSEKI_TAR} -C fuseki`
    `chmod +x #{FUSEKI_EXE} fuseki/#{FUSEKI_DIR}/s-**`
    `rm #{FUSEKI_TAR}`
  end

  desc "Start the Fuseki test server at port #{FUSEKI_PORT}"
  task :start do
    `mkdir -p #{FUSEKI_TRIPLES}`
    Dir.chdir("fuseki/#{FUSEKI_DIR}") do
      IO.popen("./fuseki-server --update --loc=#{FUSEKI_TRIPLES} --port=#{FUSEKI_PORT} /#{FUSEKI_DATASTORE}") do |f|
        f.each { |l| puts l }
      end
    end
  end
end
