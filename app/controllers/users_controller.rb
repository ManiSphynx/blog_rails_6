class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update show destroy]
  before_action :require_user, :require_same_user, only: %i[edit update destroy]
  include ApplicationHelper

  def index
    @users = User.paginate(page: params[:page], per_page: 5)
  end

  def show
    @articles = @user.articles.paginate(page: params[:page], per_page: 5)
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash_message("Your account was updated successfully")
      redirect_to @user
    else
      render :edit
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash_message("Welcome to the Alpha Blog #{@user.username}")
      redirect_to articles_path
    else
      render :new
    end
  end

  def destroy
    @user.destroy
    session[:user_id] = nil if @user == current_user
    flash_message("Account and all associated articles successfully deleted")
    redirect_to @user
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def require_same_user
    if current_user != @user && !current_user.admin?
      flash_message("You can only edit your own account", :alert)
      redirect_to user_path(current_user)
    end
  end
end
