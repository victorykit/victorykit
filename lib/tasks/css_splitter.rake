namespace :css_splitter do
  task :split do
    sh <<eos
    [-d bin] || mkdir bin
    cd bin
    [ -d bless.js ] || git clone https://github.com/paulyoung/bless.js.git
    cd ..
    NODE_PATH=bin/bless.js/lib node bin/bless.js/bin/blessc public/assets/application.css public/assets/application_ie.css
eos
  end
end
