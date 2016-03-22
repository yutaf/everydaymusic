require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with email, locale, timezone, delivery_time, is_active" do
    user = User.new(
        email: 'foo@bar.baz',
        locale: 'en_US',
        timezone: -3,
        delivery_time: '08:00:00',
        is_active: true
    )
    expect(user).to be_valid
  end
end
