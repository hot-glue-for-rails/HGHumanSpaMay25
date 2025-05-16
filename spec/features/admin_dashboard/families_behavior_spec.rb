require 'rails_helper'

describe 'interaction for AdminDashboard::FamiliesController' do
  include HotGlue::ControllerHelper
  include ActionView::RecordIdentifier

    # HOTGLUE-SAVESTART
  # HOTGLUE-END
  

  let!(:family1) {
    family = create(:family , 
                          name: FFaker::Movie.title )

    family.save!
    family
  }
  
  describe "index" do
    it "should show me the list" do
      visit admin_dashboard_families_path
      expect(page).to have_content(family1.name)
    end
  end

  describe "new & create" do
    it "should create a new Family" do
      visit admin_dashboard_families_path
      click_link "New Family"
      expect(page).to have_selector(:xpath, './/h3[contains(., "New Family")]')
      new_name = FFaker::Movie.title 
      find("[name='family[name]']").fill_in(with: new_name)
      click_button "Save"
      expect(page).to have_content("Successfully created")

      expect(page).to have_content(new_name)
    end
  end


  describe "edit & update" do
    it "should return an editable form" do
      visit admin_dashboard_families_path
      find("a.edit-family-button[href='/admin_dashboard/families/#{family1.id}/edit']").click

      expect(page).to have_content("Editing #{family1.name.squish || "(no name)"}")
      new_name = FFaker::Movie.title 
      find("[name='family[name]']").fill_in(with: new_name)
      click_button "Save"
      within("turbo-frame#admin_dashboard__#{dom_id(family1)} ") do
        expect(page).to have_content(new_name)
      end
    end
  end 

  describe "destroy" do
    it "should destroy" do
      visit admin_dashboard_families_path
      accept_alert do
        find("form[action='/admin_dashboard/families/#{family1.id}'] > input.delete-family-button").click
      end
      expect(page).to_not have_content(family1.name)
      expect(Family.where(id: family1.id).count).to eq(0)
    end
  end
end

