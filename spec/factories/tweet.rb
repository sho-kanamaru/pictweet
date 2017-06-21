FactoryGirl.define do
  factory :tweet do
    text "hello!"
    image "hoge.png"
    created_at { Faker::Time.between(2.days.ago, Time.now, :all) }

    after(:create) do |tweet|
      3.times { create(:comment, tweet: tweet) }
    end
  end
end
