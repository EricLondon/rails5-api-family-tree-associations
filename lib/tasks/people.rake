namespace :people do
  desc "create_people"
  task create: :environment do
    Person.create_people(100)
  end
end
