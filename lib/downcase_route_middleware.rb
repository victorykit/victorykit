class DowncaseRouteMiddleware

  def initialize(app)
    @app = app
  end

  def call(env)
    unless env['PATH_INFO'].match(/^\/assets\/.+/)
      env['PATH_INFO'] = env['PATH_INFO'].downcase
    end
    @app.call(env)
  end

end
