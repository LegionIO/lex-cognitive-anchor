# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAnchor::Helpers::Chain do
  subject(:chain) { described_class.new(anchor_id: 'a-123') }

  describe '#initialize' do
    it 'assigns a UUID' do
      expect(chain.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores anchor_id' do
      expect(chain.anchor_id).to eq('a-123')
    end

    it 'defaults material to :steel' do
      expect(chain.material).to eq(:steel)
    end

    it 'defaults length to 0.5' do
      expect(chain.length).to eq(0.5)
    end

    it 'sets flexibility based on material' do
      steel = described_class.new(anchor_id: 'x', material: :steel)
      thread = described_class.new(anchor_id: 'x', material: :thread)
      expect(thread.flexibility).to be > steel.flexibility
    end

    it 'raises on unknown material' do
      expect do
        described_class.new(anchor_id: 'x', material: :diamond)
      end.to raise_error(ArgumentError, /unknown material/)
    end
  end

  describe '#extend!' do
    it 'increases length' do
      initial = chain.length
      chain.extend!(amount: 0.1)
      expect(chain.length).to eq((initial + 0.1).round(10))
    end
  end

  describe '#shorten!' do
    it 'decreases length' do
      initial = chain.length
      chain.shorten!(amount: 0.1)
      expect(chain.length).to eq((initial - 0.1).round(10))
    end
  end

  describe '#wear!' do
    it 'decreases flexibility' do
      initial = chain.flexibility
      chain.wear!
      expect(chain.flexibility).to be < initial
    end
  end

  describe '#broken?' do
    it 'returns false initially' do
      expect(chain).not_to be_broken
    end

    it 'returns true when flexibility below threshold' do
      chain.flexibility = 0.05
      expect(chain).to be_broken
    end
  end

  describe '#elastic?' do
    it 'returns false for steel' do
      expect(chain).not_to be_elastic
    end

    it 'returns true for cobweb' do
      c = described_class.new(anchor_id: 'x', material: :cobweb)
      expect(c).to be_elastic
    end
  end

  describe '#short?' do
    it 'returns false at default' do
      expect(chain).not_to be_short
    end

    it 'returns true below 0.3' do
      chain.length = 0.2
      expect(chain).to be_short
    end
  end

  describe '#flexibility_label' do
    it 'returns a symbol' do
      expect(chain.flexibility_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      expected = %i[id anchor_id material length flexibility
                    flexibility_label broken elastic created_at]
      expect(chain.to_h.keys).to match_array(expected)
    end
  end
end
