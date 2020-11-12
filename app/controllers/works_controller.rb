class WorksController < ApplicationController
  def index
    @works = Work.all
  end

  def new
    @work = Work.new
  end

  def create
    @work = Work.new(work_params)

    if @work.save
      redirect_to work_path(@work.id)
      return
    else
      flash.now[:error] =  "Error occurred. #{@work.category.capitalize} did not save. Please try again."
      render :new, status: :bad_request
      return
    end
  end


  def show
    @work = Work.find_by(id: params[:id])
    if @work.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end
  end

  def edit
    @work = Work.find_by(id: params[:id])

    if @work.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end
  end

  def update
    @work = Work.find_by(id: params[:id])

    if @work.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    elsif @work.update(work_params)
      redirect_to work_path(@work.id)
      return
    else
      flash.now[:error] =  "Error occurred. #{@work.category.capitalize} did not update. Please try again."
      render :edit, status: :bad_request
      return
    end
  end

  def destroy
    @work = Work.find_by(id: params[:id])

    if @work.nil?
      render file: "#{Rails.root}/public/404.html", status: :not_found
      return
    end
    @work.votes.delete_all #is this necessary? TODO: investigate what happens when a work is deleted and view a user's list of votes

    if @work.destroy
      redirect_to works_path
      return
    else
      flash[:error] =  "Error occurred. #{@work.category.capitalize} did not delete. Please try again."
      redirect_to work_path(@work.id), status: :bad_request
      return
    end
  end

  private

  def work_params
    return params.require(:work).permit(:title, :category, :creator, :publication_year, :description)
  end
end
