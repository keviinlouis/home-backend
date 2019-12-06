class ApplicationController < ActionController::API
  before_action :load_user

  def load_user
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      decoded = JsonWebToken.decode(header)
      @user = User.find decoded[:id]
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

    @bill = current_user.bills.find_by_id(bill_id)

    render_not_found if @bill.blank?
  end

  def json_with_errors(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def render_not_found
    render json: {}, status: :not_found
  end

  def current_user
    @user
  end
end
