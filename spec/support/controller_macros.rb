module ControllerMacros
  def create_user_and_headers
    before(:all) do
      @current_user = @user || create(:user)
      @headers = { authorization: "Bearer #{@current_user.token}" }
    end
  end
end
