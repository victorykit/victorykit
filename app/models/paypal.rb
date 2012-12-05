class Paypal

  def self.verify_payment(params)
    result = nil
    uri = URI(Settings.paypal.uri)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req.set_form_data(params.merge({:cmd => '_notify-validate'}))
      req['host'] = uri.host
      req['content-type'] = 'application/x-www-form-urlencoded'
      result = http.request(req).body
    end
    result == 'VERIFIED'
  end

end
