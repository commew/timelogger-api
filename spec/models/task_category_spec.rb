require 'rails_helper'

RSpec.describe TaskCategory do
  context 'when related task_group was deleted' do
    let(:sample_task_name) { TaskGroup::INIT_DATA.keys.first }
    let(:task_group) { TaskGroup.create(name: sample_task_name).delete }

    it 'related task_categories should be deleted as if cascading.' do
      expect(described_class.count).to eq(0)
    end
  end
end
