Rake::Task["assets:precompile:nondigest"].enhance do
  Rake::Task["css_splitter:split"].invoke
end
