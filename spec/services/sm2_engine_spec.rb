require 'spec_helper'
require_relative '../../app/value_objects/sm2_input'
require_relative '../../app/value_objects/sm2_result'
require_relative '../../app/services/sm2_engine'

RSpec.describe SM2Engine do
  # Test Budget: 5 distinct behaviors x 2 = 10 max unit tests
  # AC1: first correct answer (repetitions=0) → interval=1, repetitions=1
  # AC2: second correct answer (repetitions=1) → interval=6, repetitions=2
  # AC3: third correct answer (repetitions=2) → interval=(prev * EF).round, repetitions=3
  # AC4: quality < 3 → interval=1, repetitions=0 (reset)
  # AC5: EF clamping [1.3, 2.5]
  # AC6: no Rails constants referenced

  describe '.call' do
    context 'when first correct answer (repetitions=0, quality=4)' do
      it 'returns interval=1, repetitions=1, ease_factor=2.5' do
        input = SM2Input.new(repetitions: 0, interval: 1, ease_factor: 2.5, quality: 4)
        result = SM2Engine.call(input)

        expect(result.interval).to eq(1)
        expect(result.repetitions).to eq(1)
        expect(result.ease_factor).to eq(2.5)
      end
    end

    context 'when second correct answer (repetitions=1, quality=4)' do
      it 'returns interval=6, repetitions=2' do
        input = SM2Input.new(repetitions: 1, interval: 1, ease_factor: 2.5, quality: 4)
        result = SM2Engine.call(input)

        expect(result.interval).to eq(6)
        expect(result.repetitions).to eq(2)
      end
    end

    context 'when third correct answer (repetitions=2, quality=4, EF=2.5)' do
      it 'returns interval=15, repetitions=3' do
        input = SM2Input.new(repetitions: 2, interval: 6, ease_factor: 2.5, quality: 4)
        result = SM2Engine.call(input)

        expect(result.interval).to eq(15)
        expect(result.repetitions).to eq(3)
      end
    end

    context 'when quality < 3 (incorrect answer)' do
      it 'resets to interval=1, repetitions=0' do
        input = SM2Input.new(repetitions: 5, interval: 30, ease_factor: 2.5, quality: 1)
        result = SM2Engine.call(input)

        expect(result.interval).to eq(1)
        expect(result.repetitions).to eq(0)
      end
    end

    context 'when EF clamping is needed' do
      it 'clamps EF to 1.3 when computed EF would fall below 1.3' do
        # quality=0: EF delta = 0.1 - (5-0)*(0.08 + 5*0.02) = 0.1 - 5*0.18 = 0.1 - 0.9 = -0.8
        # Starting EF=1.3: 1.3 - 0.8 = 0.5 → clamped to 1.3
        input = SM2Input.new(repetitions: 0, interval: 1, ease_factor: 1.3, quality: 0)
        result = SM2Engine.call(input)

        expect(result.ease_factor).to eq(1.3)
      end

      it 'clamps EF to 2.5 when computed EF would exceed 2.5' do
        # quality=5: EF delta = 0.1 - 0 * (0.08 + 0) = 0.1
        # Starting EF=2.5: 2.5 + 0.1 = 2.6 → clamped to 2.5
        input = SM2Input.new(repetitions: 0, interval: 1, ease_factor: 2.5, quality: 5)
        result = SM2Engine.call(input)

        expect(result.ease_factor).to eq(2.5)
      end
    end

    context 'when checking Rails independence' do
      it 'does not reference ActiveRecord, ApplicationRecord, or Rails constants' do
        rails_constants = %w[ActiveRecord ApplicationRecord Rails ActiveSupport ActionController]

        rails_constants.each do |const_name|
          # Verify neither SM2Engine nor SM2Input nor SM2Result reference Rails constants
          [SM2Engine, SM2Input, SM2Result].each do |klass|
            source_file = klass.instance_method(:initialize).source_location&.first ||
                          klass.method(:call).source_location&.first rescue nil
            next unless source_file

            source = File.read(source_file)
            expect(source).not_to include(const_name),
              "#{klass} references Rails constant #{const_name}"
          end
        end
      end
    end
  end
end
