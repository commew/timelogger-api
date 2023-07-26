require 'rails_helper'

RSpec.describe TaskGroup do
  # TasdGroup,TaskCategory のデフォルト値が変わる可能性があるため、
  # テストにハードコードしない目的の記述
  sample_task_group_name = described_class::INIT_DATA.keys.first
  sample_task_category_names = described_class::INIT_DATA[sample_task_group_name].pluck(:name)

  # #create_categories is registerd to "after_create"
  describe '#create_categories' do
    context "when created task_group's name prop is \"#{sample_task_group_name}\"" do
      let(:task_group) { described_class.create(name: sample_task_group_name) }
      let(:task_category_names) do
        described_class::INIT_DATA[sample_task_group_name].pluck(:name)
      end

      it 'affect to create task_categories.' do
        expect(task_group.task_categories.pluck(:name)).to eq(sample_task_category_names)
      end
    end
  end

  context 'when task_group was deleted' do
    it 'related task_categories should be deleted as if cascading.' do
      described_class.create(name: sample_task_group_name).destroy
      expect(TaskCategory.count).to eq(0)
    end
  end
end
