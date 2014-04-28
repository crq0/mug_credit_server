FactoryGirl.define do
  sequence :username do |n|
    "user#{n}"
  end

  factory :user do
    username { generate(:username) }
    phash "7668ddf038bd73f6fd03dbf070f07e23addd1d9" #abc123
    salt "salt"
  end

  factory :transaction do
    user
    amount 12.0
    hash "fake_hash"
    created { Time.now }
  end
end
