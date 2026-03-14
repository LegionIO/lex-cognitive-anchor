# lex-cognitive-anchor

Cognitive anchoring and belief tethering — anchor points resist change via grip, chains link anchors, and bias application models how they distort estimates.

## What It Does

Models how beliefs and assumptions act as anchors that resist revision. Each anchor has a `grip` (0.0–1.0) that decays when the anchor is challenged (`drag`) or simply ages (`drift`). Anchors can be chained together with material-dependent flexibility (steel = rigid, cobweb = fragile). When an anchor's grip falls below the break threshold, its chains sever.

## Core Concept: Anchor Types and Materials

```
ANCHOR_TYPES: belief, assumption, experience, authority, number
CHAIN_MATERIALS: steel (rigid) -> rope -> wire -> thread -> cobweb (fragile)
```

## Usage

```ruby
client = Legion::Extensions::CognitiveAnchor::Client.new

# Register a strong belief anchor
belief = client.create_anchor(
  name: :microservices_are_always_better,
  anchor_type: :belief,
  domain: :architecture,
  grip: 0.85
)

# Register an experience-based anchor
exp = client.create_anchor(
  name: :monolith_failure_2019,
  anchor_type: :experience,
  domain: :architecture,
  grip: 0.70
)

# Chain them together with a semi-flexible wire link
client.create_chain(
  anchor_a: belief[:anchor][:id],
  anchor_b: exp[:anchor][:id],
  material: :wire
)

# Apply anchor bias to a new architectural estimate
client.apply_bias(
  anchor_id: belief[:anchor][:id],
  estimate: { approach: :monolith, confidence: 0.7 }
)
# => { adjusted_estimate: ..., bias_magnitude: 0.72 }

# Check overall anchor landscape
client.anchor_status
# => { anchor_count: 2, chain_count: 1, average_grip: 0.78, broken_chains: 0 }
```

## Integration

Pairs with lex-anchoring (numeric anchoring and prospect theory) and lex-bias (bias detection feeds here). Pairs with lex-belief-revision — when an anchor breaks, the freed beliefs become candidates for revision.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
