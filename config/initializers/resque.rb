Redis::Namespace.class_eval do
  def clientmethod
    _clientmethod
  end
end

Resque.redis = Redis.new