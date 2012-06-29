Victorykit::Application.config.social_media = YAML.load(ERB.new(File.read(Rails.root.join('config', 'social_media.yml'))).result)[Rails.env].with_indifferent_access
