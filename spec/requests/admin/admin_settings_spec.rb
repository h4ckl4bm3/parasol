require 'spec_helper'

describe "Admin::Settings" do
  describe "GET /admin/settings" do
    it "works! (now write some real specs)" do
      sign_in_as_a_valid_admin
      get admin_settings_path
      expect(response.status).to eq 200
    end
  end
end