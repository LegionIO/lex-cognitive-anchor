# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAnchor::Helpers::Anchor do
  subject(:anchor) do
    described_class.new(anchor_type: :belief, domain: :reasoning, content: 'first impression')
  end

  describe '#initialize' do
    it 'assigns a UUID' do
      expect(anchor.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets anchor_type' do
      expect(anchor.anchor_type).to eq(:belief)
    end

    it 'defaults reference_value to 0.5' do
      expect(anchor.reference_value).to eq(0.5)
    end

    it 'defaults grip to 0.7' do
      expect(anchor.grip).to eq(0.7)
    end

    it 'defaults weight to 0.5' do
      expect(anchor.weight).to eq(0.5)
    end

    it 'clamps grip to 0..1' do
      a = described_class.new(anchor_type: :number, domain: :t, content: 'x', grip: 5.0)
      expect(a.grip).to eq(1.0)
    end

    it 'raises on unknown type' do
      expect do
        described_class.new(anchor_type: :magic, domain: :t, content: 'x')
      end.to raise_error(ArgumentError, /unknown anchor type/)
    end
  end

  describe '#drag!' do
    it 'increases grip' do
      initial = anchor.grip
      anchor.drag!
      expect(anchor.grip).to eq((initial + 0.06).round(10))
    end
  end

  describe '#drift!' do
    it 'decreases grip' do
      initial = anchor.grip
      anchor.drift!
      expect(anchor.grip).to eq((initial - 0.03).round(10))
    end
  end

  describe '#bias_pull' do
    it 'pulls new value toward reference' do
      anchor.grip = 0.8
      anchor.weight = 0.5
      biased = anchor.bias_pull(0.9)
      expect(biased).to be < 0.9
      expect(biased).to be > 0.5
    end

    it 'has no effect with zero grip' do
      anchor.grip = 0.0
      expect(anchor.bias_pull(0.9)).to eq(0.9)
    end

    it 'returns reference when grip and weight are 1.0' do
      anchor.grip = 1.0
      anchor.weight = 1.0
      expect(anchor.bias_pull(0.9)).to eq(anchor.reference_value)
    end
  end

  describe '#ironclad?' do
    it 'returns false at default' do
      expect(anchor).not_to be_ironclad
    end

    it 'returns true at 0.8+' do
      anchor.grip = 0.85
      expect(anchor).to be_ironclad
    end
  end

  describe '#drifting?' do
    it 'returns false at default' do
      expect(anchor).not_to be_drifting
    end

    it 'returns true below 0.2' do
      anchor.grip = 0.1
      expect(anchor).to be_drifting
    end
  end

  describe '#heavy?' do
    it 'returns false at default' do
      expect(anchor).not_to be_heavy
    end

    it 'returns true at 0.7+' do
      anchor.weight = 0.8
      expect(anchor).to be_heavy
    end
  end

  describe '#grip_label' do
    it 'returns :firm at default' do
      expect(anchor.grip_label).to eq(:firm)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      expected = %i[id anchor_type domain content reference_value grip weight
                    grip_label ironclad drifting created_at]
      expect(anchor.to_h.keys).to match_array(expected)
    end
  end
end
