describe DowncaseRouteMiddleware do
  let(:app) { stub }
  let(:middleware) { DowncaseRouteMiddleware.new(app) }
  subject(:env) {{ 'PATH_INFO' => path }}   
  
  before do
    app.stub(:call).with(env)
    middleware.call(env)
  end
  
  context 'request to /Petitions/1' do
    let(:path) { '/Petitions/1' }
    it { should include('PATH_INFO' => '/petitions/1') }
  end

  context 'request to /assets/Font.ttf' do
    let(:path) { '/assets/Font.ttf' }
    it { should include('PATH_INFO' => '/assets/Font.ttf') }
  end

end
