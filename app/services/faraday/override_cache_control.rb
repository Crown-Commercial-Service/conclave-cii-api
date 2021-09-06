class Faraday::OverrideCacheControl < Faraday::Middleware
  def initialize(app, options = {})
    super(app)
    @cache_control = options[:cache_control]
  end

  def call(env)
    response = @app.call(env)
    response.headers['Cache-Control'] = @cache_control
    response
  end
end
