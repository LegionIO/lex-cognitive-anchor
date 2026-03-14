# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveAnchor::Client do
  subject(:client) { described_class.new }

  it 'includes the runner module' do
    expect(described_class.ancestors).to include(
      Legion::Extensions::CognitiveAnchor::Runners::CognitiveAnchor
    )
  end

  it 'responds to create_anchor' do
    expect(client).to respond_to(:create_anchor)
  end

  it 'responds to apply_bias' do
    expect(client).to respond_to(:apply_bias)
  end

  it 'responds to anchor_status' do
    expect(client).to respond_to(:anchor_status)
  end

  it 'can create anchor and apply bias through client' do
    result = client.create_anchor(anchor_type: :number, domain: :test, content: 'price anchor')
    expect(result[:success]).to be true
    bias_result = client.apply_bias(anchor_id: result[:anchor][:id], new_value: 0.8)
    expect(bias_result[:success]).to be true
  end
end
