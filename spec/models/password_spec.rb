require 'rails_helper'

RSpec.describe Password, type: :model do
  before(:each) do
    @password = Password.new(password: "foobar", password_confirmation: "foobar")
  end

  it "is valid with password and password_confirmation" do
    expect(@password).to be_valid
  end

  it "is invalid with blank" do
    @password.password = @password.password_confirmation = " " * 6
    expect(@password).not_to be_valid
  end

  it "is invalid when it is shorter than 6 letters" do
    @password.password = @password.password_confirmation = "a" * 5
    expect(@password).not_to be_valid
  end
end
