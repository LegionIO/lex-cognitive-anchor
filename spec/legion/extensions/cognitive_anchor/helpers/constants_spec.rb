# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAnchor::Helpers::Constants do
  described_class = Legion::Extensions::CognitiveAnchor::Helpers::Constants

  describe 'ANCHOR_TYPES' do
    it 'contains expected types' do
      expect(described_class::ANCHOR_TYPES).to eq(%i[belief assumption experience authority number])
    end

    it 'is frozen' do
      expect(described_class::ANCHOR_TYPES).to be_frozen
    end
  end

  describe 'CHAIN_MATERIALS' do
    it 'contains expected materials' do
      expect(described_class::CHAIN_MATERIALS).to eq(%i[steel rope wire thread cobweb])
    end
  end

  describe 'numeric constants' do
    it 'defines MAX_ANCHORS' do
      expect(described_class::MAX_ANCHORS).to eq(200)
    end

    it 'defines DRAG_RATE' do
      expect(described_class::DRAG_RATE).to eq(0.06)
    end

    it 'defines BREAK_THRESHOLD' do
      expect(described_class::BREAK_THRESHOLD).to eq(0.1)
    end
  end

  describe '.label_for' do
    it 'returns :ironclad for high grip' do
      expect(described_class.label_for(described_class::GRIP_LABELS, 0.9)).to eq(:ironclad)
    end

    it 'returns :drifting for low grip' do
      expect(described_class.label_for(described_class::GRIP_LABELS, 0.1)).to eq(:drifting)
    end

    it 'returns :elastic for high flexibility' do
      expect(described_class.label_for(described_class::FLEXIBILITY_LABELS, 0.9)).to eq(:elastic)
    end

    it 'returns :brittle for low flexibility' do
      expect(described_class.label_for(described_class::FLEXIBILITY_LABELS, 0.1)).to eq(:brittle)
    end
  end
end
