# frozen_string_literal: true

class AppointmentsController < ApplicationController
  # regenerate this controller with
  # bin/rails generate hot_glue:scaffold Appointment --alt-foreign-key-lookup='user_id{email}' --hawk='user_id{current_user.family}'

  helper :hot_glue
  include HotGlue::ControllerHelper

  before_action :authenticate_user!
  before_action :load_appointment, only: %i[show edit update destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol == :turbo_stream }
  
  def load_appointment
    @appointment = current_user.appointments.find(params[:id])
  end
  
  
  
  def load_all_appointments
      @appointments = current_user.appointments.includes(:user).page(params[:page])

  end

  def index
    load_all_appointments
    
  end

  def new
    @appointment = Appointment.new(user: current_user)
    
  end

  def create
    flash[:notice] = +''
    modified_params = modify_date_inputs_on_params(appointment_params.dup, , [])
    modified_params = modified_params.merge(user: current_user) 

    
    user = current_user.family.users.find_by(email: appointment_params[:__lookup_user_email] )
    modified_params.tap { |hs| hs.delete(:__lookup_user_email)}
     @appointment = Appointment.new(modified_params.merge(user: user))

      
      
    
    if @appointment.save
      flash[:notice] = "Successfully created #{@appointment.name}"
      
      load_all_appointments
      render :create
    else
      flash[:alert] = "Oops, your appointment could not be created. #{@hawk_alarm}"
      @action = 'new'
      render :create, status: :unprocessable_entity
    end
  end



  def show
    redirect_to edit_appointment_path(@appointment)
  end

  def edit
    @action = 'edit'
    render :edit
  end

  def update
    flash[:notice] = +''
    flash[:alert] = nil
    

    modified_params = modify_date_inputs_on_params(update_appointment_params.dup, , [])
    modified_params = modified_params.merge(user: current_user) 
    
      
    user = current_user.family.users.find_by(email: appointment_params[:__lookup_user_email] )
    modified_params.tap { |hs| hs.delete(:__lookup_user_email)}

      
      
    modified_params.merge!(user: user)
    
    modified_params = hawk_params({user_id: [current_user.family]}, modified_params)
    
      
      
    if @appointment.update(modified_params)
      
      
      
      flash[:notice] << "Saved #{@appointment.name}"
      flash[:alert] = @hawk_alarm if @hawk_alarm
      render :update, status: :unprocessable_entity
    else
      flash[:alert] = "Appointment could not be saved. #{@hawk_alarm}"
      @appointment.user_id = Appointment.find(@appointment.id).person.id if @appointment.errors.include?(:user)
      @action = 'edit'
      render :update, status: :unprocessable_entity
    end
  end

  def destroy
    
    begin
      @appointment.destroy
      flash[:notice] = 'Appointment successfully deleted'
    rescue ActiveRecordError => e
      flash[:alert] = 'Appointment could not be deleted'
    end
    
    load_all_appointments
  end



  def appointment_params
    params.require(:appointment).permit(:when_at, :user_id, :treatment, :__lookup_user_email)
  end

  
  def update_appointment_params
    params.require(:appointment).permit(:when_at, :user_id, :treatment, :__lookup_user_email)
  end
  

  
  def namespace
    
  end
end


