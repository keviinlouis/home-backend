require 'json'

class FCM
  URL_BASE = 'https://fcm.googleapis.com/fcm'

  def initialize(api_key, client_options = {})
    @api_key = api_key
    @client_options = client_options
  end

  def send_to(fcm_token, notification, data = {}, options = {})
    data.merge(click_action: "FLUTTER_NOTIFICATION_CLICK")

    if fcm_token.class == String
      fcm_token = [fcm_token]
    end

    payload = {
      notification: notification,
      data: data,
      registration_ids: fcm_token,
      priority: "high"
    }

    post('send', payload, options)
  end

  private

  def post(url, data, options = {})
    request(:post, url, data, options)
  end

  def request(method, url, data = {}, headers = {}, options = {})
    response = RestClient::Request.execute(method: method, url: url, payload: data.to_json, headers: headers.merge(headers(options)))

    return response if options[:no_parse]

    JSON.parse response.data
  end

  def headers(options = {})
    {
      'Authorization' => "key=#{@api_key}",
      'Content-Type' => 'application/json'
    }
  end

  def build_url(url)
    "#{URL_BASE}/#{url}"
  end
end
