json.array!(@users) do |user|
  json.extract! user, :id, :email, :name, :first_name, :last_name, :gender, :locale, :timezone, :fetch_cnt, :delivery_time, :interval, :is_active
  json.url user_url(user, format: :json)
end
