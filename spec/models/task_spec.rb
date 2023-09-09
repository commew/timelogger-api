require 'rails_helper'

Rspec.describe Task do
  describe '#status', skip: 'not implemented yet' do
    let(:task_time_units) { [build(:task_time_unit, start_at:) ]}
    let(:task) { create :task, task_time_units:}
  end

  describe '#start_at', skip: 'not implemented yet' do
  end

  describe '#end_at', skip: 'not implemented yet' do
  end

  describe '#duration', skip: 'not implemented yet' do
  end

  describe '#make_pending', skip: 'not implemented yet' do
  end

  describe '#make_recording', skip: 'not implemented yet' do
  end
  
  describe '#make_completed', skip: 'not implemented yet' do
  end
  
  describe '.start_recording', skip: 'not implemented yet' do
  end
  
end
