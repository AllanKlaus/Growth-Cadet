# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :dns_record do
    ip { Faker::Internet.ip_v4_address }
  end
end
