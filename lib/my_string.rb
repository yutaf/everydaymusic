module MyString
  def create_random_uniq_str
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
    (0...32).map { o[rand(o.length)] }.join
  end
  module_function :create_random_uniq_str
end