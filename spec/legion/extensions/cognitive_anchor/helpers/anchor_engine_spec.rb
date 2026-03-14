# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAnchor::Helpers::AnchorEngine do
  subject(:engine) { described_class.new }

  let(:default_attrs) { { anchor_type: :belief, domain: :reasoning, content: 'first impression' } }

  describe '#create_anchor' do
    it 'creates and stores an anchor' do
      a = engine.create_anchor(**default_attrs)
      expect(a).to be_a(Legion::Extensions::CognitiveAnchor::Helpers::Anchor)
      expect(engine.all_anchors.size).to eq(1)
    end

    it 'raises when limit reached' do
      stub_const('Legion::Extensions::CognitiveAnchor::Helpers::Constants::MAX_ANCHORS', 1)
      engine.create_anchor(**default_attrs)
      expect do
        engine.create_anchor(anchor_type: :number, domain: :t, content: 'x')
      end.to raise_error(ArgumentError, /anchor limit/)
    end
  end

  describe '#create_chain' do
    it 'creates a chain linked to anchor' do
      a = engine.create_anchor(**default_attrs)
      c = engine.create_chain(anchor_id: a.id)
      expect(c.anchor_id).to eq(a.id)
    end

    it 'raises for unknown anchor' do
      expect do
        engine.create_chain(anchor_id: 'bad')
      end.to raise_error(ArgumentError, /anchor not found/)
    end
  end

  describe '#apply_bias' do
    it 'pulls value toward anchor reference' do
      a = engine.create_anchor(**default_attrs, reference_value: 0.3, grip: 0.8, weight: 0.6)
      result = engine.apply_bias(anchor_id: a.id, new_value: 0.9)
      expect(result[:biased]).to be < 0.9
      expect(result[:shift]).to be > 0
    end
  end

  describe '#drag_anchor' do
    it 'increases anchor grip' do
      a = engine.create_anchor(**default_attrs, grip: 0.5)
      engine.drag_anchor(anchor_id: a.id)
      expect(a.grip).to be > 0.5
    end
  end

  describe '#drift_all!' do
    it 'drifts all anchors' do
      a = engine.create_anchor(**default_attrs)
      initial = a.grip
      engine.drift_all!
      expect(a.grip).to be < initial
    end
  end

  describe '#wear_all_chains!' do
    it 'wears all chains' do
      a = engine.create_anchor(**default_attrs)
      c = engine.create_chain(anchor_id: a.id)
      initial = c.flexibility
      engine.wear_all_chains!
      expect(c.flexibility).to be < initial
    end
  end

  describe '#anchors_by_type' do
    it 'returns counts per type' do
      engine.create_anchor(**default_attrs)
      engine.create_anchor(anchor_type: :number, domain: :t, content: 'x')
      counts = engine.anchors_by_type
      expect(counts[:belief]).to eq(1)
      expect(counts[:number]).to eq(1)
    end
  end

  describe '#strongest_anchors' do
    it 'returns sorted by grip descending' do
      engine.create_anchor(**default_attrs, grip: 0.3)
      a2 = engine.create_anchor(anchor_type: :number, domain: :t, content: 'x', grip: 0.9)
      expect(engine.strongest_anchors(limit: 1).first).to eq(a2)
    end
  end

  describe '#chains_for' do
    it 'returns chains for a specific anchor' do
      a = engine.create_anchor(**default_attrs)
      engine.create_chain(anchor_id: a.id)
      engine.create_chain(anchor_id: a.id, material: :rope)
      expect(engine.chains_for(a.id).size).to eq(2)
    end
  end

  describe '#anchor_report' do
    it 'returns comprehensive hash' do
      engine.create_anchor(**default_attrs)
      report = engine.anchor_report
      expect(report).to include(:total_anchors, :total_chains, :by_type,
                                :ironclad_count, :drifting_count, :avg_grip)
    end
  end
end
