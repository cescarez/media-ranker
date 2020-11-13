class UsersController < ApplicationController
  def index
    @users = User.all
  end

  # def new
  #   @user = User.new
  # end

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
