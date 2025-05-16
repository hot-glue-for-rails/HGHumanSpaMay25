FactoryBot.define do
  factory :appointment do
    when_at { "2025-05-15 20:09:54" }
    user_id { 1 }
    treatment { "" }
  end
end
