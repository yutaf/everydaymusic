module MyString
  extend ActiveSupport::Concern

  class_methods do
    def create_random_uniq_str
      o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
      (0...32).map { o[rand(o.length)] }.join
    end
  end
end

class MyStringer
  include MyString
end