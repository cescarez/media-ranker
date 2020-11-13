class UsersController < ApplicationController
  def index
    @users = User.all
  end


  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to user_path(@user.id)
      return
    else
      flash.now[:error] =  "Error occurred. User did not save. Please try again."
      render :new, status: :bad_request
      return
    end
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end
  end

  def login_form
    @user = User.new
  end

  def login
    username = params[:user][:username]
    user = User.find_by(name: username)
    if user
      session[:user_id] = user.id
      flash[:success] = "Successfully logged in as returning user #{username} with ID #{user.id}"
    else
      user = User.create(name: username, join_date: Time.now)
      session[:user_id] = user.id
      flash[:success] = "Successfully logged in as new user #{username} with ID #{user.id}"
    end

    redirect_to root_path
    return
  end

  def logout
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      unless user.nil?
        session[:user_id] = nil
        flash[:success] = "Successfully logged out"
      else
        session[:user_id] = nil
        flash[:error] = ""

      end
    end
  end

  def current
    @current_user = User.find_by(id: session[:user_id])
    unless @current_user
      flash[:error] = "You must be logged in to see this page"
      redirect_to root_path
      return
    end
  end

  # def new
  #   @user = User.new
  # end
  # def edit
  #   @user = User.find_by(id: params[:id])
  #
  #   if @user.nil?
  #     render file: "#{Rails.root}/public/404.html", status: :not_found
  #     return
  #   end
  # end
  #
  # def update
  #   @user = User.find_by(id: params[:id])
  #
  #   if @user.nil?
  #     render file: "#{Rails.root}/public/404.html", status: :not_found
  #     return
  #   elsif @user.update(user_params)
  #     redirect_to user_path(@user.id)
  #     return
  #   else
  #     flash.now[:error] =  "Error occurred. User did not update. Please try again."
  #     render :edit, status: :bad_request
  #     return
  #   end
  # end

  def destroy
    @user = User.find_by(id: params[:id])

    if @user.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end
    @user.votes.delete_all #is this necessary? TODO: investigate what happens when a user is deleted and view a work's list of votes

    if @user.destroy
      redirect_to users_path
      return
    else
      flash[:error] =  "Error occurred. User did not delete. Please try again."
      redirect_to user_path(@user.id), status: :bad_request
      return
    end
  end

  private

  def user_params
    return params.require(:user).permit(:name)
  end
end
