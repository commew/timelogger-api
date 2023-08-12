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

  describe '.init_default_tasks' do
    context 'when there are default task instances' do
      let(:default_tasks) { described_class.init_default_tasks }

      it 'task instances each name match default tasks name.' do
        expect(default_tasks.pluck(:name)).to eq(described_class::INIT_DATA_HASH.keys)
      end

      it 'categories are created.' do
        expect(default_tasks.first.categories.first).to be_a TaskCategory
      end
    end
  end
end
