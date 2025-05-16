# frozen_string_literal: true

class AdminDashboard::UsersController < AdminDashboard::BaseController
  # regenerate this controller with
  # bin/rails generate hot_glue:scaffold User --namespace='admin_dashboard' --gd --nested='family' --smart-layout

  helper :hot_glue
  include HotGlue::ControllerHelper

  
     
  before_action :family
  before_action :load_user, only: %i[show edit update destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol == :turbo_stream }
    def family
    @family ||= Family.find(params[:family_id]) 
  end
  
    
  
  def load_user
    @user = @family.users.find(params[:id])
  end
  
  
  
  def load_all_users
      @users = family.users.page(params[:page])

  end

  def index
    load_all_users
    
  end

  def new
    @user = User.new(family: @family)
    
  end

  def create
    flash[:notice] = +''
    modified_params = modify_date_inputs_on_params(user_params.dup, nil, [])
    modified_params = modified_params.merge(family: @family) 

      
    
    @user = User.new(modified_params)
    
      
    
    if @user.save
      flash[:notice] = "Successfully created #{@user.name}"
      family.reload
      load_all_users
      render :create
    else
      flash[:alert] = "Oops, your user could not be created. #{@hawk_alarm}"
      @action = 'new'
      render :create, status: :unprocessable_entity
    end
  end



  def show
    redirect_to edit_admin_dashboard_family_user_path(family,@user)
  end

  def edit
    @action = 'edit'
    render :edit
  end

  def update
    flash[:notice] = +''
    flash[:alert] = nil
    

    modified_params = modify_date_inputs_on_params(update_user_params.dup, nil, [])
    modified_params = modified_params.merge(family: @family) 
    

    
    
      
      
    if @user.update(modified_params)
      family.reload
      
      
      flash[:notice] << "Saved #{@user.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
      render :update, status: :unprocessable_entity
    else
      flash[:alert] = "User could not be saved. #{@hawk_alarm}"
      @action = 'edit'
      render :update, status: :unprocessable_entity
    end
  end

  def destroy
    
    begin
      @user.destroy
      flash[:notice] = 'User successfully deleted'
    rescue ActiveRecordError => e
      flash[:alert] = 'User could not be deleted'
    end
    family.reload
    load_all_users
  end



  def user_params
    params.require(:user).permit(:email, :name)
  end

  
  def update_user_params
    params.require(:user).permit(:email, :name)
  end
  

  
  def namespace
    'admin_dashboard/'
  end
end


