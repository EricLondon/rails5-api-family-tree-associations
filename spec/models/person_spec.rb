require 'rails_helper'

RSpec.describe Person, type: :model do
  context 'Associations' do
    it { should belong_to(:father).class_name('Person').with_foreign_key('father_id').optional }
    it { should belong_to(:mother).class_name('Person').with_foreign_key('mother_id').optional }
    it { should belong_to(:spouse).class_name('Person').with_foreign_key('spouse_id').optional }
  end

  context 'Validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:gender) }

    it { should validate_numericality_of(:depth).only_integer }
    it { should validate_numericality_of(:father_id).only_integer.allow_nil }
    it { should validate_numericality_of(:mother_id).only_integer.allow_nil }
    it { should validate_numericality_of(:spouse_id).only_integer.allow_nil }
  end

  context 'parents' do
    let(:person) { create(:person, :with_parents) }

    it 'has a mother' do
      expect(person.mother_id).to eq(person.mother.id)
    end

    it 'has a father' do
      expect(person.father_id).to eq(person.father.id)
    end
  end

  describe 'children' do
    context 'male' do
      let(:person) { person_with_children('male') }
      let(:child) { person.children.first }

      it 'has the correct associations' do
        expect(child.father_id).to eq(person.id)
        expect(child.mother_id).to eq(person.spouse.id)
      end
    end

    context 'female' do
      let(:person) { person_with_children('female') }
      let(:child) { person.children.first }

      it 'has the correct associations' do
        expect(child.father_id).to eq(person.spouse.id)
        expect(child.mother_id).to eq(person.id)
      end
    end
  end

  describe 'siblings' do
    let(:person) { person_with_all_relationships }
    let(:siblings) { person.siblings }

    it 'has the correct count' do
      expect(siblings.count).to eq(2)
    end

    it 'has the correct associations' do
      siblings.each do |sibling|
        expect(sibling.father_id).to eq(person.father_id)
        expect(sibling.mother_id).to eq(person.mother_id)
      end
    end
  end

  describe 'as_json' do
    let(:person) { person_with_all_relationships }
    let(:person_attr) { person.as_json }

    it 'has id' do
      expect(person.id).to eq(person_attr['id'])
    end

    it 'has first_name' do
      expect(person.first_name).to eq(person_attr['first_name'])
    end

    it 'has last_name' do
      expect(person.last_name).to eq(person_attr['last_name'])
    end

    it 'has gender' do
      expect(person.gender).to eq(person_attr['gender'])
    end

    it 'has depth' do
      expect(person.depth).to eq(person_attr['depth'])
    end

    it 'has spouse_id' do
      expect(person.spouse.id).to eq(person_attr['spouse_id'])
    end

    it 'has mother_id' do
      expect(person.mother.id).to eq(person_attr['mother_id'])
    end

    it 'has father_id' do
      expect(person.father.id).to eq(person_attr['father_id'])
    end

    it 'has children_ids' do
      expect(person.children_ids).to match_array(person_attr['children_ids'])
    end

    it 'has sibling_ids' do
      expect(person.sibling_ids).to match_array(person_attr['sibling_ids'])
    end

    it 'has the correct keys' do
      expect(person_attr.keys).to match_array(%w[id first_name last_name maiden_name gender depth spouse_id mother_id father_id children_ids sibling_ids])
    end
  end

  describe 'new_relationship_type' do
    context 'without relationships' do
      let(:person) { create(:person) }
      let(:new_relationship_type) { person.new_relationship_type }

      it 'can have new parents or spouse' do
        expect(%w[parents spouse]).to include(new_relationship_type)
      end
    end

    context 'with parents' do
      let(:person) { create(:person, :with_parents) }
      let(:new_relationship_type) { person.new_relationship_type }

      it 'can have a new spouse' do
        expect(new_relationship_type).to eq('spouse')
      end
    end

    context 'with spouse' do
      let(:person) { create(:person, :with_spouse) }
      let(:new_relationship_type) { person.new_relationship_type }

      it 'can have new parents or child' do
        expect(%w[parents child]).to include(new_relationship_type)
      end
    end

    context 'with parents and spouse' do
      let(:person) { create(:person, :with_spouse, :with_parents) }
      let(:new_relationship_type) { person.new_relationship_type }

      it 'can have a new child' do
        expect(new_relationship_type).to eq('child')
      end
    end

    context 'with all relationships' do
      let(:person) { person_with_all_relationships }
      let(:new_relationship_type) { person.new_relationship_type }

      it 'can have a new child' do
        expect(new_relationship_type).to eq('child')
      end
    end
  end

  describe 'create_people' do
    it 'creates new relationships' do
      described_class.destroy_all
      described_class.create_people(1)
      expect(described_class.count).to be >= 1
    end
  end

  def person_with_children(gender)
    person = gender == 'female' ? create(:person, :female) : create(:person)
    person.add_new_spouse
    person.add_new_child
    person
  end

  def person_with_all_relationships
    person = create(:person)
    person.add_new_parents
    person.add_new_spouse
    person.add_new_child
    person.father.add_new_child
    person.mother.add_new_child
    person
  end
end
