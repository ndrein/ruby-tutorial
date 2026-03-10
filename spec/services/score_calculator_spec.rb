require 'spec_helper'
require_relative '../../app/services/score_calculator'

RSpec.describe ScoreCalculator do
  # Test Budget: 4 distinct behaviors x 2 = 8 max unit tests
  # B1: correct + time-based scoring (5/4/3/2 tiers)
  # B2: hard_flag=true always yields 3 for correct answers
  # B3: incorrect/skipped → 1
  # B4: timeout/skipped → 0

  describe '.call' do
    context 'when answer is correct without hard flag' do
      it 'returns 5 when elapsed < 10 seconds' do
        expect(ScoreCalculator.call(:correct, 5, false)).to eq(5)
      end

      it 'returns 4 when 10 <= elapsed < 25 seconds' do
        expect(ScoreCalculator.call(:correct, 15, false)).to eq(4)
      end

      it 'returns 3 when 25 <= elapsed <= 30 seconds' do
        expect(ScoreCalculator.call(:correct, 27, false)).to eq(3)
      end

      it 'returns 2 when elapsed > 30 seconds' do
        expect(ScoreCalculator.call(:correct, 35, false)).to eq(2)
      end
    end

    context 'when hard_flag is true and answer is correct' do
      it 'returns 3 regardless of elapsed time' do
        expect(ScoreCalculator.call(:correct, 27, true)).to eq(3)
        expect(ScoreCalculator.call(:correct, 5, true)).to eq(3)
      end
    end

    context 'when answer is not correct' do
      it 'returns 1 for incorrect answer' do
        expect(ScoreCalculator.call(:incorrect, 10, false)).to eq(1)
      end

      it 'returns 0 for timeout or skipped' do
        expect(ScoreCalculator.call(:timeout, 45, false)).to eq(0)
        expect(ScoreCalculator.call(:skipped, 0, false)).to eq(0)
      end
    end
  end
end
