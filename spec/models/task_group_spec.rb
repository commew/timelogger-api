require 'rails_helper'

RSpec.describe TaskGroup do
  # #create_categories is registerd to "after_create"
  describe '#create_categories' do
    context 'when a task_group created' do
      let(:task_group) { create(:task_group) }

      it 'affect to create task_categories.' do
        expect(task_group.task_categories.count).not_to eq(0)
      end
    end
  end

  context 'when task_group was deleted' do
    let(:task_group) { create(:task_group).destroy }

    it 'related task_categories should be deleted as if cascading.' do
      expect(TaskCategory.count).to eq(0)
    end
  end
end
