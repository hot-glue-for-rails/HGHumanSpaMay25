require 'rails_helper'

describe 'interaction for AdminDashboard::UsersController' do
  include HotGlue::ControllerHelper
  include ActionView::RecordIdentifier

  # HOTGLUE-SAVESTART
  # HOTGLUE-END
  


  let!(:user1) {
    user = create(:user, family: family , 
                          email: FFaker::Internet.email, 
                          name: FFaker::Movie.title )

    user.save!
    user
  }
  let(:family) {create(:family , : current_user )}
  
  describe "index" do
    it "should show me the list" do
      visit admin_dashboard_family_users_path(family)
      expect(page).to have_content(user1.email)
      expect(page).to have_content(user1.name)
    end
  end

  describe "new & create" do
    it "should create a new User" do
      visit admin_dashboard_family_users_path(family)
      click_link "New User"
      expect(page).to have_selector(:xpath, './/h3[contains(., "New User")]')
      new_email = FFaker::Internet.email 
      find("[name='user[email]']").fill_in(with: new_email)
      new_name = FFaker::Movie.title 
      find("[name='user[name]']").fill_in(with: new_name)
      click_button "Save"
      expect(page).to have_content("Successfully created")

      expect(page).to have_content(new_email)
      expect(page).to have_content(new_name)
    end
  end


  describe "edit & update" do
    it "should return an editable form" do
      visit admin_dashboard_family_users_path(family)
      find("a.edit-user-button[href='/admin_dashboard/users/#{user1.id}/edit']").click

      expect(page).to have_content("Editing #{user1.name.squish || "(no name)"}")
      new_email = FFaker::Internet.email 
      find("[name='user[email]']").fill_in(with: new_email)
      new_name = FFaker::Movie.title 
      find("[name='user[name]']").fill_in(with: new_name)
      click_button "Save"
      within("turbo-frame#admin_dashboard__#{dom_id(user1)} ") do
        expect(page).to have_content(new_email)
       expect(page).to have_content(new_name)
      end
    end
  end 

  describe "destroy" do
    it "should destroy" do
      visit admin_dashboard_family_users_path(family)
      accept_alert do
        find("form[action='/admin_dashboard/families/#{family.id}/users/#{user1.id}'] > input.delete-user-button").click
      end
      expect(page).to_not have_content(user1.name)
      expect(User.where(id: user1.id).count).to eq(0)
    end
  end
end

