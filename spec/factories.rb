FactoryBot.define do
  factory :person do
    first_name { 'person_first' }
    last_name { 'person_last' }
    gender { 'male' }
    depth { 0 }

    trait :with_parents do
      father
      mother
    end

    trait :with_spouse do
      spouse
    end

    trait :female do
      gender { 'female' }
    end
  end

  factory :father, class: 'Person' do
    first_name { 'father_first' }
    last_name { 'father_last' }
    gender { 'male' }
    depth { -1 }
  end

  factory :mother, class: 'Person' do
    first_name { 'mother_first' }
    last_name { 'mother_last' }
    maiden_name { 'mother_maiden' }
    gender { 'female' }
    depth { -1 }
  end

  factory :spouse, class: 'Person' do
    first_name { 'spouse_first' }
    last_name { 'spouse_last' }
    maiden_name { 'spouse_maiden' }
    gender { 'female' }
    depth { 0 }
  end
end
