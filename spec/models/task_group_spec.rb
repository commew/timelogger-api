require 'rails_helper'

RSpec.describe TaskGroup do
  describe '#as_json' do
    context 'when there is "仕事" task_group, including "資料作成" category' do
      let(:task_category_name) { '資料作成' }
      let(:task_category) { [build(:task_category, name: task_category_name)] }
      let(:task_group) { create(:task_group, name: '仕事', categories: task_category) }
      let(:expected) do
        {
          'id' => task_group.id,
          'name' => task_group.name,
          'categories' => task_group.categories.as_json(only: %i[id name])
        }
      end

      it 'returns expected hash no including timestamps.' do
        expect(task_group.as_json).to eq(expected)
      end

      it 'returns category name "資料作成"' do
        expect(task_group.categories.first.name).to eq(task_category_name)
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
        task_group_name = described_class::INIT_DATA_HASH.keys.first
        expected = described_class::INIT_DATA_HASH[task_group_name].first[:name]
        expect(default_tasks.first.categories.first.name).to eq(expected)
      end
    end
  end
end
