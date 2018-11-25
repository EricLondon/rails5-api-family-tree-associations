require 'rails_helper'

RSpec.describe Api::PeopleController, type: :controller do
  describe 'index' do
    let!(:person) { person_with_all_relationships }
    let!(:request) { get :index }
    let!(:data) { JSON.parse(response.body) }

    let(:data_person) { data.find {|p| p['id'] == person.id } }
    let(:data_father) { data.find {|p| p['id'] == person.father_id } }
    let(:data_mother) { data.find {|p| p['id'] == person.mother_id } }
    let(:data_spouse) { data.find {|p| p['id'] == person.spouse_id } }
    let(:data_children) { data.select {|p| person.children_ids.include?(p['id']) } }
    let(:data_siblings) { data.select {|p| person.sibling_ids.include?(p['id']) } }

    it 'is success' do
      expect(response).to be_success
      expect(data.size).to eq(7)
    end

    it 'includes the correct associations' do
      expect(data_person).to_not be_nil
      expect(data_father).to_not be_nil
      expect(data_mother).to_not be_nil
      expect(data_spouse).to_not be_nil
      expect(data_children.count).to eq(1)
      expect(data_siblings.count).to eq(2)
    end
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
