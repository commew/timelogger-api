require 'rails_helper'

RSpec.describe Task do
  describe '#status' do
    context 'when task attribute completed is true' do
      let(:task_time_units) do
        [build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z')]
      end
      let(:task) { create(:task, task_time_units:, completed: true) }

      it 'returns :completed.' do
        expect(task.status).to eq(described_class::STATUS[:completed])
      end
    end

    context 'when latest task_time_unit end_at is nil' do
      let(:task_time_units) { [build(:task_time_unit, end_at: nil)] }
      let(:task) { create(:task, task_time_units:) }

      it 'returns :recording.' do
        expect(task.status).to eq(described_class::STATUS[:recording])
      end
    end

    context 'when latest task_time_unit end_at is presence' do
      let(:task_time_units) do
        [build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z')]
      end
      let(:task) { create(:task, task_time_units:) }

      it 'returns :pending.' do
        expect(task.status).to eq(described_class::STATUS[:pending])
      end
    end
  end

  describe '#start_at' do
    let(:expected) { '2023-09-10T00:00:00Z' }
    let(:task_time_units) do
      [
        build(:task_time_unit, start_at: expected, end_at: '2023-09-10T00:30:00Z'),
        build(:task_time_unit, start_at: '2023-09-11T00:00:00Z', end_at: '2023-09-11T00:30:00Z')
      ]
    end
    let(:task) { create(:task, task_time_units:) }

    it 'returns expected value.' do
      expect(task.start_at).to eq(expected)
    end
  end

  describe '#end_at' do
    let(:expected) { '2023-09-11T00:30:00Z' }
    let(:task_time_units) do
      [
        build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z'),
        build(:task_time_unit, start_at: '2023-09-11T00:00:00Z', end_at: expected)
      ]
    end
    let(:task) { create(:task, task_time_units:) }

    it 'returns expected value.' do
      expect(task.end_at).to eq(expected)
    end
  end

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
        travel_to '2023-09-11 00:00:15'

        expected = (40 * 60) + (3 * 60) + 21 + 15
        expect(task.duration).to eq(expected)
      end
    end

    context 'when end_at has millisecond precision' do
      let(:task) do
        task_time_units = [build(:task_time_unit, start_at: '2023-10-12 01:23:45', end_at: '2023-10-12 02:34:56.789')]
        create(:task, task_time_units:)
      end

      it 'returns seconds without milliseconds' do
        expect(task.duration).to eq (1 * 3600) + (11 * 60) + 11
      end
    end
  end

  describe '#make_pending' do
    context 'when task status is :recording.' do
      let(:task_time_units) { [build(:task_time_unit, end_at: nil)] }
      let(:task) { create(:task, task_time_units:) }

      it 'task status is :recording' do
        expect(task.status).to eq(:recording)
      end

      it 'update is success.' do
        expect { task.make_pending }.not_to raise_error(Exception)
      end
    end

    context 'when task status is :pending.' do
      let(:task_time_units) do
        [build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z')]
      end
      let(:task) { create(:task, task_time_units:) }

      it 'task status is :pending' do
        expect(task.status).to eq(:pending)
      end

      it 'expect raise error.' do
        expect { task.make_pending }.to raise_error(Exception)
      end
    end

    context 'when task status is :completed.' do
      let(:task_time_units) do
        [build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z')]
      end
      let(:task) { create(:task, task_time_units:, completed: true) }

      it 'task status is :completed' do
        expect(task.status).to eq(:completed)
      end

      it 'expect raise error.' do
        expect { task.make_pending }.to raise_error(Exception)
      end
    end
  end

  describe '#make_recording' do
    context 'when task status is :recording.' do
      let(:task_time_units) { [build(:task_time_unit, end_at: nil)] }
      let(:task) { create(:task, task_time_units:) }

      it 'task status is :recording' do
        expect(task.status).to eq(:recording)
      end

      it 'expect raise error.' do
        expect { task.make_recording }.to raise_error(Exception)
      end
    end

    context 'when task status is :pending.' do
      let(:task_time_units) do
        [build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z')]
      end
      let(:task) { create(:task, task_time_units:) }

      it 'task status is :pending' do
        expect(task.status).to eq(:pending)
      end

      it 'update is success.' do
        expect { task.make_recording }.not_to raise_error(Exception)
      end
    end

    context 'when task status is :completed.' do
      let(:task_time_units) do
        [build(:task_time_unit, start_at: '2023-09-10T00:00:00Z', end_at: '2023-09-10T00:30:00Z')]
      end
      let(:task) { create(:task, task_time_units:, completed: true) }

      it 'task status is :completed' do
        expect(task.status).to eq(:completed)
      end

      it 'expect raise error.' do
        expect { task.make_recording }.to raise_error(Exception)
      end
    end
  end

  describe '#make_completed' do
    context 'when task status is :completed' do
      let(:task) { create(:task, completed: true) }

      it 'expect raise error.' do
        expect { task.make_completed }.to raise_error(Exception)
      end
    end

    context 'when task status is not :completed' do
      let(:task) { create(:task, completed: false) }
      let(:end_at) { '2023-09-10T00:30:00Z' }

      it 'update is success.' do
        expect { task.make_completed }.not_to raise_error(Exception)
      end

      it 'expect end_at is presence.' do
        task.make_completed end_at
        expect(task.end_at).to eq(end_at)
      end
    end
  end

  describe '.start_recording' do
    let(:account) { create(:account) }
    let(:task_category) { build(:task_category) }
    let(:start_at) { '2023-09-10T00:00:00Z' }

    before do
      create(:task_group, account:, categories: [task_category])
    end

    it 'returns valid Task instance.' do
      task = described_class.start_recording(task_category, start_at, account)
      expect(task.valid?).to be(true)
    end

    context 'when requested account does not associate task_category' do
      let(:open_id_provider) { build(:open_id_provider, sub: '111111111111111111112') }
      let(:other_account) { create(:account, open_id_providers: [open_id_provider]) }

      it 'returns invalid Task instance.' do
        task = described_class.start_recording(task_category, start_at, other_account)
        expect(task.invalid?).to be(true)
      end
    end
  end
end
