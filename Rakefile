require 'bundler/gem_helper'

namespace :gem do
  Bundler::GemHelper.install_tasks
end

task :test do
  result = sh 'whoami'

  if result
    puts 'Success!'
  else
    puts 'Failure!'
    exit 1
  end
end
