task :push => [:pull, :spec] do
  sh "git push"
end

task :pull do
  sh "git pull --rebase"
end