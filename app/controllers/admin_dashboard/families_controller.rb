# frozen_string_literal: true

class AdminDashboard::FamiliesController < AdminDashboard::BaseController
  # regenerate this controller with
  # bin/rails generate hot_glue:scaffold Family --plural='families' --namespace='admin_dashboard' --gd --downnest='users' --smart-layout

  helper :hot_glue
  include HotGlue::ControllerHelper

  
  before_action :load_family, only: %i[show edit update destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol == :turbo_stream }
  
  def load_family
    @family = Family.find(params[:id])
  end
  
  
  
  def load_all_families
      @families = Family.page(params[:page])

  end

  def index
    load_all_families
    
  end

  def new
    @family = Family.new
    
  end

  def create
    flash[:notice] = +''
    modified_params = modify_date_inputs_on_params(family_params.dup, nil, [])

      
    
    @family = Family.new(modified_params)
    
      
    
    if @family.save
      flash[:notice] = "Successfully created #{@family.name}"
      
      load_all_families
      render :create
    else
      flash[:alert] = "Oops, your family could not be created. #{@hawk_alarm}"
      @action = 'new'
      render :create, status: :unprocessable_entity
    end
  end



  def show
    redirect_to edit_admin_dashboard_family_path(@family)
  end

  def edit
    @action = 'edit'
    render :edit
  end

  def update
    flash[:notice] = +''
    flash[:alert] = nil
    

    modified_params = modify_date_inputs_on_params(update_family_params.dup, nil, [])
    

    
    
      
      
    if @family.update(modified_params)
      
      
      
      flash[:notice] << "Saved #{@family.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
      render :update, status: :unprocessable_entity
    else
      flash[:alert] = "Family could not be saved. #{@hawk_alarm}"
      @action = 'edit'
      render :update, status: :unprocessable_entity
    end
  end

  def destroy
    
    begin
      @family.destroy
      flash[:notice] = 'Family successfully deleted'
    rescue ActiveRecordError => e
      flash[:alert] = 'Family could not be deleted'
    end
    
    load_all_families
  end



  def family_params
    params.require(:family).permit(:name)
  end

  
  def update_family_params
    params.require(:family).permit(:name)
  end
  

  
  def namespace
    'admin_dashboard/'
  end
end


