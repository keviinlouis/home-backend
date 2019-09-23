class ApplicationController < ActionController::Base
  # before_action :validate_token
  before_action :load_user
  protect_from_forgery with: :null_session

  def load_user
    @user = User.find_by_id user_id

    @user = find_user_by_id if @user.blank?

    render json: {error: 'user_not_founded'}, status: :unauthorized unless @user.present?
  end
  def validate_token
    auth_response = AuthApi.authenticate(token)

    return render json: {}, status: 401 unless auth_response

    if auth_response.headers['renewtoken']
      response.set_header('renewtoken', auth_response.headers['renewtoken'])
    end

    user = JSON.parse(auth_response.body)

    @user = User.find_or_initialize_by(id: user["id"])

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

  def user_id
    request.headers['Authorization']
  end

  def find_user_by_id
    response = AuthApi.find_user_by_id(user_id)

    return unless response.present?

    user = JSON.parse(response.body)
    @user = User.find_or_initialize_by(id: user["id"])

    @user.email = user["email"]
    @user.name = user["name"]

    @user.save

    @user
  end
end
