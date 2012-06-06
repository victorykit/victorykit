namespace :css_splitter do
  task :split do
    sh <<eos
    cd bin
    [ -d bless.js ] || git clone https://github.com/paulyoung/bless.js.git
    NODE_PATH=bless.js/lib node bless.js/bin/blessc ../public/assets/application.css ../public/assets/application-ie.css
eos
  end
end
