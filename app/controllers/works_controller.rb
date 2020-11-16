class WorksController < ApplicationController
  before_action :find_nonnil_work, only: [:show, :edit, :update, :destroy, :upvote]
  before_action :require_login, only: [:upvote]

  def index
    @works = Work.all
  end

  def new
    @work = Work.new
  end

  def create
    @work = Work.new(work_params)
    @work.validate_category

    if @work.save
      redirect_to work_path(@work.id)
      return
    else
      flash.now[:error] =  "Error occurred. #{@work.category.capitalize} did not save. "
      @work.errors.each { |attribute, message| flash.now[:error] << "#{attribute.capitalize.to_s.gsub('_', ' ')} #{message}. " }
      flash.now[:error] << "Please try again."

      render :new, status: :bad_request
      return
    end
  end


  def show
  end

  def edit
  end

  def update
    if @work.update(work_params)
      @work.validate_category
      flash[:success] =  "#{@work.category.capitalize} successfully updated. "
      redirect_to work_path(@work.id)
      return
    else
      flash.now[:error] =  "Error occurred. #{@work.category.capitalize} did not save. "
      @work.errors.each do |attribute, message|
        flash.now[:error] << "#{attribute.capitalize.to_s.gsub('_', ' ')} #{message}. "
      end
      flash.now[:error] << "Please try again."

      render :edit, status: :bad_request
      return
    end
  end

  def destroy
    @work.votes.destroy_all
    work_category = @work.category ## copied for success message below
    work_id = @work.id ## copied for success message below

    if @work.destroy
      flash[:success] =  " #{work_category.capitalize} (ID #{work_id}) successfully deleted."
      redirect_to works_path
      return
    else
      flash[:error] =  "Error occurred. #{@work.category.capitalize} did not delete. Please try again."
      redirect_to work_path(@work.id), status: :bad_request
      return
    end
  end

  def upvote
    previous_vote = @work.votes.find { |vote| vote.user_id == current_user.id }
    if previous_vote
      flash[:error] = "Error. Only one vote is allowed per user, per work."
    else
      if @work.add_vote(user: current_user)
        flash[:success] =  "Successfully upvoted!"
      else
        flash[:error] =  "Error occurred. #{@work.title} upvote did not save. "
      end
    end

    redirect_back fallback_location: root_path
    return
  end

  private

  def work_params
    return params.require(:work).permit(:title, :category, :creator, :publication_year, :description)
  end

  def find_nonnil_work
    @work = Work.find_by(id: params[:id])
    if @work.nil?
      flash.now[:error] = "Work not found."
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end
  end
end
