# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAnchor
      module Helpers
        class AnchorEngine
          def initialize
            @anchors = {}
            @chains  = {}
          end

          def create_anchor(anchor_type:, domain:, content:,
                            reference_value: nil, grip: nil, weight: nil)
            raise ArgumentError, 'anchor limit reached' if @anchors.size >= Constants::MAX_ANCHORS

            a = Anchor.new(anchor_type: anchor_type, domain: domain, content: content,
                           reference_value: reference_value, grip: grip, weight: weight)
            @anchors[a.id] = a
            a
          end

          def create_chain(anchor_id:, material: :steel, length: nil, flexibility: nil)
            raise ArgumentError, 'chain limit reached' if @chains.size >= Constants::MAX_CHAINS

            fetch_anchor(anchor_id)
            c = Chain.new(anchor_id: anchor_id, material: material,
                          length: length, flexibility: flexibility)
            @chains[c.id] = c
            c
          end

          def apply_bias(anchor_id:, new_value:)
            anchor = fetch_anchor(anchor_id)
            pulled = anchor.bias_pull(new_value.to_f)
            chain_factor = chain_rigidity_factor(anchor_id)
            biased = (new_value.to_f + ((pulled - new_value.to_f) * chain_factor)).clamp(0.0, 1.0).round(10)
            { anchor: anchor, original: new_value.to_f, biased: biased,
              shift: (biased - new_value.to_f).abs.round(10), chain_factor: chain_factor }
          end

          def drag_anchor(anchor_id:, rate: Constants::DRAG_RATE)
            anchor = fetch_anchor(anchor_id)
            anchor.drag!(rate: rate)
            anchor
          end

          def drift_all!
            @anchors.each_value(&:drift!)
          end

          def wear_all_chains!
            @chains.each_value(&:wear!)
          end

          def broken_chains
            @chains.values.select(&:broken?)
          end

          def anchors_by_type
            counts = Constants::ANCHOR_TYPES.to_h { |t| [t, 0] }
            @anchors.each_value { |a| counts[a.anchor_type] += 1 }
            counts
          end

          def strongest_anchors(limit: 5)
            @anchors.values.sort_by { |a| -a.grip }.first(limit)
          end

          def weakest_anchors(limit: 5)
            @anchors.values.sort_by(&:grip).first(limit)
          end

          def ironclad_anchors
            @anchors.values.select(&:ironclad?)
          end

          def drifting_anchors
            @anchors.values.select(&:drifting?)
          end

          def chains_for(anchor_id)
            @chains.values.select { |c| c.anchor_id == anchor_id }
          end

          def avg_grip
            return 0.0 if @anchors.empty?

            (@anchors.values.sum(&:grip) / @anchors.size).round(10)
          end

          def anchor_report
            {
              total_anchors:  @anchors.size,
              total_chains:   @chains.size,
              by_type:        anchors_by_type,
              ironclad_count: ironclad_anchors.size,
              drifting_count: drifting_anchors.size,
              broken_chains:  broken_chains.size,
              avg_grip:       avg_grip
            }
          end

          def all_anchors
            @anchors.values
          end

          def all_chains
            @chains.values
          end

          private

          def chain_rigidity_factor(anchor_id)
            active = chains_for(anchor_id).reject(&:broken?)
            return 1.0 if active.empty?

            avg_flex = active.sum(&:flexibility) / active.size.to_f
            (1.0 - (avg_flex * 0.5)).round(10)
          end

          def fetch_anchor(id)
            @anchors.fetch(id) { raise ArgumentError, "anchor not found: #{id}" }
          end
        end
      end
    end
  end
end
