require 'rails_helper'

describe 'interaction for AppointmentsController' do
  include HotGlue::ControllerHelper
  include ActionView::RecordIdentifier

  # HOTGLUE-SAVESTART
  # HOTGLUE-END
  let(:current_user) {create(:user)}

  let!(:user1) {create(:user, user: current_user)}

  let!(:appointment1) {
    appointment = create(:appointment, user: current_user , 
                          when_at: Time.current + rand(5000).seconds, 
                          user: user1 )

    appointment.save!
    appointment
  }
 
  before do
    login_as(current_user)
  end  
  describe "index" do
    it "should show me the list" do
      visit appointments_path
      
      
      expect(page).to have_content(appointment1.treatment)
    end
  end

  describe "new & create" do
    it "should create a new Appointment" do
      visit appointments_path
      click_link "New Appointment"
      expect(page).to have_selector(:xpath, './/h3[contains(., "New Appointment")]')
      new_when_at = Time.current + 5.seconds 
      find("[name='appointment[when_at]']").fill_in(with: new_when_at)
      user_id_selector = find("[name='appointment[user_id]']").click 
      user_id_selector.first('option', text: user1.name).select_option
      list_of_treatment_types = Appointment.defined_enums['treatment'].keys 
      new_treatment = list_of_treatment_types[rand(list_of_treatment_types.length)].to_s 
      find("select[name='appointment[treatment]']  option[value='#{new_treatment}']").select_option
      click_button "Save"
      expect(page).to have_content("Successfully created")

      expect(page).to have_content(new_when_at.strftime('%l:%M %p').strip)
       expect(page).to have_content(user1.name)
      expect(page).to have_content(new_treatment)
    end
  end


  describe "edit & update" do
    it "should return an editable form" do
      visit appointments_path
      find("a.edit-appointment-button[href='/appointments/#{appointment1.id}/edit']").click

      expect(page).to have_content("Editing #{appointment1.name.squish || "(no name)"}")
      new_when_at = Time.current + 5.seconds 
      find("[name='appointment[when_at]']").fill_in(with: new_when_at)
      user_id_selector = find("[name='appointment[user_id]']").click 
      user_id_selector.first('option', text: user1.name).select_option
      list_of_treatment_types = Appointment.defined_enums['treatment'].keys 
      new_treatment = list_of_treatment_types[rand(list_of_treatment_types.length)].to_s 
      find("select[name='appointment[treatment]']  option[value='#{new_treatment}']").select_option
      click_button "Save"
      within("turbo-frame#__#{dom_id(appointment1)} ") do
        expect(page).to have_content(new_when_at.strftime('%l:%M %p').strip)
        expect(page).to have_content(user1.name)
       expect(page).to have_content(new_treatment)
      end
    end
  end 

  describe "destroy" do
    it "should destroy" do
      visit appointments_path
      accept_alert do
        find("form[action='/appointments/#{appointment1.id}'] > input.delete-appointment-button").click
      end
      expect(page).to_not have_content(appointment1.name)
      expect(Appointment.where(id: appointment1.id).count).to eq(0)
    end
  end
end

