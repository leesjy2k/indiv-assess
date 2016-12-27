class SessionsController < ApplicationController
  def create
    if user = User.authenticate(session_params)
      session[:user_id] = user.id
      redirect_to items_path
    else
      flash[:notice] = "Incorrect email/password combination. You are on a secure website my friend."
      render :new, status: :unprocessable_entity
    end
  end

  def create_from_omniauth
    auth_hash = request.env["omniauth.auth"]

    authentication = Authentication.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"]) || Authentication.create_with_omniauth(auth_hash)
    if authentication.user
      user = authentication.user
      authentication.update_token(auth_hash)
      @next = root_url
      @notice = "Signed in!"
    else
      user = User.create_with_auth_and_hash(authentication,auth_hash)
      @next = edit_user_path(user)
      @notice = "User created - confirm or edit details..."
    end
    session[:user_id] = user.id
    redirect_to @next, :notice => @notice
  end


  def destroy
    session[:user_id] = nil
    redirect_to items_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
