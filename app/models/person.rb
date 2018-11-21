class Person < ApplicationRecord
  enum gender: { male: 'male', female: 'female' }

  validates :first_name, presence: true
  validates :gender, presence: true
  validates :last_name, presence: true
  validates_numericality_of :depth, only_integer: true, allow_nil: false
  validates_numericality_of :father_id, only_integer: true, allow_nil: true
  validates_numericality_of :mother_id, only_integer: true, allow_nil: true
  validates_numericality_of :spouse_id, only_integer: true, allow_nil: true

  belongs_to :father, class_name: 'Person', foreign_key: 'father_id', optional: true
  belongs_to :mother, class_name: 'Person', foreign_key: 'mother_id', optional: true
  belongs_to :spouse, class_name: 'Person', foreign_key: 'spouse_id', optional: true

  def as_json(options = nil)
    super({ except: %i[created_at updated_at], methods: %i[children_ids sibling_ids] }.merge(options || {}))
  end

  def children
    if gender == 'male'
      Person.where(father_id: id)
    else
      Person.where(mother_id: id)
    end
  end

  def children_ids
    children.map(&:id)
  end

  def siblings
    Person.where('(mother_id = ? OR father_id = ?) AND id != ?', mother_id, father_id, id)
  end

  def sibling_ids
    siblings.map(&:id)
  end

  def can_have_new_spouse?
    spouse_id.nil?
  end

  def can_have_new_child?
    !spouse_id.nil?
  end

  def can_have_new_parents?
    mother_id.nil? || father_id.nil?
  end

  def new_relationship_type
    options = []
    options << 'child' if can_have_new_child?
    options << 'parents' if can_have_new_parents?
    options << 'spouse' if can_have_new_spouse?
    options.sample
  end

  def add_new_parents
    new_father = Person.create!(
      first_name: Faker::Name.first_name,
      last_name: last_name,
      gender: 'male',
      depth: depth - 1
    )

    new_mother = Person.create!(
      first_name: Faker::Name.first_name,
      last_name: last_name,
      maiden_name: Faker::Name.last_name,
      gender: 'female',
      spouse: new_father,
      depth: depth - 1
    )

    new_father.spouse = new_mother
    new_father.save!

    self.father = new_father
    self.mother = new_mother
    save!
  end

  def add_new_spouse
    spouse_attr = {
      first_name: Faker::Name.first_name,
      depth: depth
    }

    if gender == 'male'
      spouse_attr.merge!(
        gender: 'female',
        last_name: last_name,
        maiden_name: Faker::Name.last_name,
        spouse_id: id
      )
      new_spouse = Person.create!(spouse_attr)

      self.spouse = new_spouse
      save!
    else
      spouse_attr.merge!(
        gender: 'male',
        last_name: Faker::Name.last_name,
        spouse_id: id
      )
      new_spouse = Person.create!(spouse_attr)

      self.maiden_name = last_name
      self.last_name = spouse_attr[:last_name]
      self.spouse = new_spouse
      save!
    end
  end

  def add_new_child
    if gender == 'male'
      father_id = id
      mother_id = spouse.id
      new_last_name = last_name
    else
      father_id = spouse.id
      mother_id = id
      new_last_name = spouse.last_name
    end

    Person.create!(
      first_name: Faker::Name.first_name,
      last_name: new_last_name,
      gender: self.class.genders.keys.sample,
      depth: depth + 1,
      father_id: father_id,
      mother_id: mother_id
    )
  end

  class << self
    def create_people(how_many = 1_000)
      create_first if Person.count.zero?

      eligible_person_for_relationship, relationship_type = eligible_for_relationship
      eligible_person_for_relationship.send("add_new_#{relationship_type}")

      create_people(how_many) if Person.count < how_many
    end

    def create_first
      Person.create!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        gender: genders.keys.sample,
        depth: 0
      )
    end

    def eligible_for_relationship
      person = Person.order('RANDOM()').first
      relationship_type = person.new_relationship_type
      return [person, relationship_type] if relationship_type

      eligible_for_relationship
    end
  end
end
