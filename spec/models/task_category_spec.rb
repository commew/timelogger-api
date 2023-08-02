require 'rails_helper'

RSpec.describe TaskCategory do
  describe '#as_json' do
    context 'when there is a' do
      let(:task_category) { create(:task_category, name: '会議') }
      let(:expected) do
        {
          'id' => task_category.id,
          'name' => task_category.name
        }
      end

      it 'returns expected hash no including timestamps.' do
        expect(task_category.as_json).to eq(expected)
      end
    end
  end
end
