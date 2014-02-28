class SessionsController < ApplicationController
  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Logged In"
    else
      render :new
    end
  end

  def destroy
    session['user_id'] = nil
    redirect_to root_url, notice: "Logged Out"
  end
end
