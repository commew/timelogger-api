require 'rails_helper'

RSpec.describe TaskGroup do
  describe '#as_json' do
    context 'when there is "仕事" task_group' do
      let(:task_group) { create(:task_group, name: '仕事') }
      let(:expected) do
        {
          'id' => task_group.id,
          'name' => task_group.name,
          'categories' => task_group.categories.as_json
        }
      end

      it 'returns expected hash no including timestamps.' do
        expect(task_group.as_json).to eq(expected)
      end
    end
  end

  # #create_categories is registerd to "after_create"
  describe '#create_categories' do
    context 'when a task_group created' do
      let(:task_group) { create(:task_group) }

      it 'affect to create task_categories.' do
        expect(task_group.categories).not_to be_empty
      end
    end
  end

  describe '.default_tasks' do
    context 'when there are default task instances' do
      let(:default_tasks) { described_class.default_tasks }

      it 'task instances each name match default tasks name.' do
        expect(default_tasks.pluck(:name)).to eq(described_class::INIT_DATA.keys)
      end

      it 'no categories, because this method don\'t save into database.' do
        expect(default_tasks.first.categories).to be_empty
      end
    end
  end
end
