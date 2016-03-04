require 'rails_helper'

RSpec.describe Password, type: :model do
  it "is valid with password and password_confirmation" do
    password = Password.new(password: "foobar", password_confirmation: "foobar")
    expect(password).to be_valid
  end
end
