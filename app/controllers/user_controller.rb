class UserController < ApplicationController
  skip_before_action :load_user, only: [:login, :create]

  def login
    user = User.find_by(email: params[:email])

    unless user
      return json_with_errors email: ['Email não encontrado']
    end

    unless user.authenticate params[:password]
      return json_with_errors password: ['Senha incorreta']
    end

    render json: user, generate_token: true
  end

  def me
    render json: current_user
  end

  def index
    query = params[:query] || ''

    # Improve with elastic search
    if query
      users = User.where("name like '%?%' or email like '%?%'", query, query)
    else
      users = User.all
    end

    render json: users
  end

  def create
    user = User.new user_params

    unless user.save
      return json_with_errors user.errors
    end


    render json: user, status: :created, generate_token: true
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
