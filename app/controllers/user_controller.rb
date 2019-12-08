class UserController < ApplicationController
  skip_before_action :load_user, only: [:login, :create]

  def login
    user = User.find_by(email: params[:email])

    unless user
      return json_with_errors email: ['Email não encontrado']
    end

    unless user.authenticate(params[:password])
      return json_with_errors password: ['Senha incorreta']
    end

    device_id = params[:device_id]

    if device_id.present?
      device = Device.where(id: device_id, user: user).first
      device_id = device.present? ? device.id : user.device.create.id
    else
      device_id = user.device.create.id
    end

    render json: user, authenticating: true, device_id: device_id
  end

  def me
    render json: current_user
  end

  def device
    device = Device.where(id: params[:device_id], user: current_user).first
    return render json: { errors: 'Aparelho não encontrado' }, status: :not_found if device.blank?
    device.update fcm_token: params[:token]
    render json: device
  end

  def remove_device
    device = Device.where(id: params[:device_id], user: current_user).first

    device.delete if device

    render json: {}
  end

  def index
    query = "%#{params[:query] || ''}%"
    exclude = params[:exclude] || []

    exclude << current_user.id

    users = User.where.not(id: exclude)

    # Improve with elastic search
    if query
      users = users.where("name like ? or email like ?", query, query)
    end

    render json: users
  end

  def create
    user = User.new user_params

    unless user.save
      return json_with_errors user.errors
    end

    device_id = user.device.create.id

    render json: user, status: :created, authenticating: true, device_id: device_id
  end

  def update
    current_user.update user_params

    unless current_user.save
      return json_with_errors current_user.errors
    end

    render json: current_user
  end

  def destroy
    current_user.delete

    render json: current_user
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
