require 'rails_helper'

RSpec.describe Task do
  describe '#duration' do
    context 'when task have some task_time_units' do
      let(:task_time_units) do
        [
          build(:task_time_unit, start_at: '2023-09-09T00:00:00Z', end_at: '2023-09-09T00:40:00Z'),
          build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:03:21Z'),
          build(:task_time_unit, start_at: '2023-09-11T00:00:00Z', end_at: nil)
        ]
      end
      let(:task) { create(:task, task_time_units:) }

      it 'returns expected seconds.' do
        expected = (40 * 60) + (3 * 60) + 21
        expect(task.duration).to eq(expected)
      end
    end
  end
end
