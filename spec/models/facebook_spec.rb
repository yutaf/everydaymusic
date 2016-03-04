require 'rails_helper'

RSpec.describe Facebook, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with user_id" do
    facebook = Facebook.new(user_id: 123, facebook_user_id: "1234")
    expect(facebook).to be_valid
  end
end
