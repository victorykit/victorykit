Rake::Task["assets:precompile"].enhance do
  Rake::Task["css_splitter:split"].invoke
end
