class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.page(params[:page]).per Settings.USER_LIST_PER_PAGE
  end

  def show
    @microposts = @user.microposts.page(params[:page]).per Settings.POST_PAGE
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "checkout_email_message"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "users.edit.update_message_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "users.index.delete_message_success"
    else
      flash[:danger] = t "users.index.delete_message_error"
    end
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:danger] = t "user_not_found"
    redirect_to root_url
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
