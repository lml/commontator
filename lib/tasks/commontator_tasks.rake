namespace :commontator do
  namespace :install do
    desc "Copy initializers from commontator to application"
    task :initializers do
      Dir.glob(File.expand_path('../../../config/initializers/*.rb', __FILE__)) do |file|
        next if File.exists?(File.expand_path(File.basename(file), 'config/initializers'))
        cp file, 'config/initializers', :verbose => false
        print "Copied initializer #{File.basename(file)} from commontator\n"
      end
    end
  end
  
  desc "Copy initializers and migrations from commontator to application"
  task :install do
    Rake::Task["commontator:install:initializers"].invoke
    Rake::Task["commontator:install:migrations"].invoke
  end
end
