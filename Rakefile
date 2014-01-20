require 'bundler'
Bundler.setup(:default)

require 'open3'
require 'ansi/code'

OPENRESTY_VERSION = "1.2.4.11"
OPENRESTY_NAME    = "ngx_openresty-#{OPENRESTY_VERSION}"
OPENRESTY_TARBALL = "#{OPENRESTY_NAME}.tar.gz"

DEBUG = 0
INFO  = 1
ERROR = 2
NONE  = 3

LOG_LEVEL = ENV['LOG_LEVEL'] || INFO

ROOT = File.expand_path(File.dirname(__FILE__))

def r(cmd, log_level = LOG_LEVEL)
  puts ANSI.on_blue { ANSI.bold { cmd } }
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    stdout.each { |line| print ANSI.green { line } if log_level <= DEBUG }
    stderr.each { |line| print ANSI.red { line }   if log_level <= ERROR }
    exit_status = wait_thr.value
  end
end

namespace :openresty do
  desc "Remove ngx_openresty files from vendor and tmp"
  task :clobber do
    r "rm -rf #{ROOT}/tmp/ngx_*"
    r "rm -rf #{ROOT}/vendor/ngx_*"
  end

  desc "Download ngx_openresty tarball and install it into ./vendor"
  task :install, [:force] do |t, args|
    if forced = (args[:force] || "") =~ /^f/
      Rake::Task["openresty:clobber"].invoke
    else
      if File.exists?("#{ROOT}/vendor/#{OPENRESTY_NAME}/nginx/sbin/nginx") && r("#{ROOT}/vendor/#{OPENRESTY_NAME}/nginx/sbin/nginx -V", NONE).success?
        puts ANSI.yellow { "openresty is already installed: rake openresty:install[force] to reinstall" }
        exit
      end
    end

    FileUtils.mkdir_p("tmp")
    FileUtils.cd("tmp")
    r("wget http://agentzh.org/misc/nginx/#{OPENRESTY_TARBALL}", NONE) unless File.exists?(OPENRESTY_TARBALL)
    r("tar xzvf #{OPENRESTY_TARBALL}") unless Dir.exists?(OPENRESTY_NAME)

    FileUtils.cd(OPENRESTY_NAME)
    r "./configure --prefix=#{ROOT}/vendor/#{OPENRESTY_NAME} --with-luajit --with-http_ssl_module --with-http_gzip_static_module"
    r "make && make install"

    puts ANSI.reverse { ANSI.green { "#{OPENRESTY_NAME} installed to ./vendor/#{OPENRESTY_NAME}. Cool beans." } }
  end
end

namespace :statsd do
  desc "Remove statsd files from vendor"
  task :clobber do
    r "rm -rf #{ROOT}/vendor/stat*"
    r "rm -rf #{ROOT}/tmp/stat*"
  end

  task :install, [:force] do |t, args|
    if forced = (args[:force] || "") =~ /^f/
      Rake::Task["statsd:clobber"].invoke
    else
      if File.exists?("#{ROOT}/vendor/statsd-master/bin/statsd")
        puts ANSI.yellow { "statsd is already installed: rake statsd:install[force] to reinstall" }
        exit
      end
    end

    FileUtils.mkdir_p("tmp")
    FileUtils.cd("tmp")
    r("wget -O statsd.zip https://github.com/etsy/statsd/archive/master.zip", NONE) unless File.exists?("statsd.zip")
    r("unzip -d #{ROOT}/vendor statsd.zip") unless Dir.exists?("#{ROOT}/vendor/statsd-master")

    FileUtils.cd("#{ROOT}/vendor/statsd-master")
    r("npm install --local", ERROR)

    puts ANSI.reverse { ANSI.green { "statsd-master installed to ./vendor/statsd-master. Cool beans." } }
  end
end
