require 'rails_helper'

RSpec.describe TaskGroup do
  # #create_categories is registerd to "after_create"
  describe '#create_categories' do
    context 'when a task_group created' do
      let(:task_group) { create(:task_group) }

      it 'affect to create task_categories.' do
        expect(task_group.categories.count).not_to eq(0)
      end
    end
  end

  describe 'when task_group was deleted' do
    let(:task_group) { create(:task_group).destroy }

    it 'related task_categories should be deleted as if cascading.' do
      expect(TaskCategory.count).to eq(0)
    end
  end

  describe '.create_default_tasks' do
    it 'default task_groups was created.' do
      described_class.create_default_tasks 'account_will_be_passed'
      expect(described_class.count).to eq(described_class::INIT_DATA.length)
    end
  end
end
