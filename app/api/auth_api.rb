class AuthApi
  BASE_URL = ENV['AUTH_URL']

  def self.authenticate(token)
    url = "#{BASE_URL}/validate-token"

    body = {
      token: token
    }

    RestClient.post(url, body)
  rescue RestClient::Exception => exception
    raise exception if exception.http_code >= 500
    false
  end

  def self.find_user_by_id(id)
    url = "#{BASE_URL}/user/#{id}"

    RestClient.get(url)
  rescue RestClient::Exception => exception
    raise exception if exception.http_code >= 500
  end
end