require "rails_helper"

# Test Budget: 1 behavior x 2 = 2 max unit tests (using 2)
# Behavior: 14-day retention gate — account age < 14 days shows 'Not enough data yet'
#           account age >= 14 days does NOT show 'Not enough data yet'

RSpec.describe "Dashboard retention rate gate", type: :request do
  let!(:user) do
    User.find_or_create_by!(email: "marcus_retention@example.com") do |u|
      u.password = "password123"
      u.experience_level = "expert"
      u.timezone = "UTC"
    end
  end

  before do
    allow(User).to receive(:first).and_return(user)
  end

  it "shows 'Not enough data yet' when user account is fewer than 14 days old" do
    user.update_column(:created_at, 13.days.ago)

    get dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Not enough data yet")
  end

  it "does not show 'Not enough data yet' when user account is 14 or more days old" do
    user.update_column(:created_at, 14.days.ago)

    get dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("Not enough data yet")
  end
end
