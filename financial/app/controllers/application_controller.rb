class ApplicationController < ActionController::Base
  before_action :validate_token
  protect_from_forgery with: :null_session

  def validate_token
    auth_response = AuthApi.authenticate(token)

    return render json: {}, status: 401 unless auth_response

    if auth_response.headers['renewtoken']
      response.set_header('renewtoken', auth_response.headers['renewtoken'])
    end

    user = JSON.parse(auth_response.body)

    @user = User.find_or_initialize_by(auth_id: user["id"])

    @user.email = user["email"]
    @user.name = user["name"]

    @user.save
  end

  def load_bill
    bill_id = params[:bill_id]

    @bill = @user.bills.find(bill_id)

  rescue
    render json: {}, status: :not_found
  end

  private

  def token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end
end
