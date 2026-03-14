# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAnchor::Runners::CognitiveAnchor do
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  let(:engine) { Legion::Extensions::CognitiveAnchor::Helpers::AnchorEngine.new }

  describe '#create_anchor' do
    it 'returns success' do
      result = runner.create_anchor(anchor_type: :belief, domain: :reasoning,
                                    content: 'test', engine: engine)
      expect(result[:success]).to be true
      expect(result[:anchor][:anchor_type]).to eq(:belief)
    end

    it 'returns failure for invalid type' do
      result = runner.create_anchor(anchor_type: :magic, domain: :t,
                                    content: 'x', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#create_chain' do
    it 'returns success' do
      a = engine.create_anchor(anchor_type: :belief, domain: :t, content: 'x')
      result = runner.create_chain(anchor_id: a.id, engine: engine)
      expect(result[:success]).to be true
      expect(result[:chain]).to be_a(Hash)
    end
  end

  describe '#apply_bias' do
    it 'returns bias result' do
      a = engine.create_anchor(anchor_type: :number, domain: :t, content: 'x',
                               reference_value: 0.3, grip: 0.8)
      result = runner.apply_bias(anchor_id: a.id, new_value: 0.9, engine: engine)
      expect(result[:success]).to be true
      expect(result[:biased]).to be < 0.9
    end
  end

  describe '#list_anchors' do
    before do
      engine.create_anchor(anchor_type: :belief, domain: :t, content: 'a')
      engine.create_anchor(anchor_type: :number, domain: :t, content: 'b')
    end

    it 'returns all anchors' do
      result = runner.list_anchors(engine: engine)
      expect(result[:count]).to eq(2)
    end

    it 'filters by type' do
      result = runner.list_anchors(anchor_type: :belief, engine: engine)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#anchor_status' do
    it 'returns report' do
      result = runner.anchor_status(engine: engine)
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_anchors)
    end
  end
end
