class ApplicationController < ActionController::API
  before_action :load_user

  def not_found
    render json: { error: 'not_found' }
  end

  def load_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      decoded = JsonWebToken.decode(header)
      @user = User.find_by_id decoded[:id]
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::ExpiredSignature => e
      render json: { errors: e }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e }, status: :unauthorized
    end
  end

  def load_bill
    bill_id = params[:bill_id]

    @bill = @user.bills.find(bill_id)

  rescue
    render json: {}, status: :not_found
  end

  def json_with_errors(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def current_user
    @user
  end
end
