class DowncaseRouteMiddleware

  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] = env['PATH_INFO'].downcase
    @app.call(env)
  end

end
