unless Rails.env.production?
  task :push => [:pull, 'jslint', :spec, "spec:smoke"] do
    sh "git push"
  end

  task :pull do
    sh "git pull --rebase"
  end
end
