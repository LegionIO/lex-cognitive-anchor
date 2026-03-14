# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAnchor
      module Helpers
        class Anchor
          attr_reader :id, :anchor_type, :domain, :content,
                      :reference_value, :created_at
          attr_accessor :grip, :weight

          def initialize(anchor_type:, domain:, content:,
                         reference_value: nil, grip: nil, weight: nil)
            validate_anchor_type!(anchor_type)
            @id              = SecureRandom.uuid
            @anchor_type     = anchor_type.to_sym
            @domain          = domain.to_sym
            @content         = content.to_s
            @reference_value = (reference_value || 0.5).to_f.clamp(0.0, 1.0).round(10)
            @grip            = (grip || 0.7).to_f.clamp(0.0, 1.0).round(10)
            @weight          = (weight || 0.5).to_f.clamp(0.0, 1.0).round(10)
            @created_at      = Time.now.utc
          end

          def drag!(rate: Constants::DRAG_RATE)
            @grip = (@grip + rate.abs).clamp(0.0, 1.0).round(10)
          end

          def drift!(rate: Constants::DRIFT_RATE)
            @grip = (@grip - rate.abs).clamp(0.0, 1.0).round(10)
          end

          def bias_pull(new_value)
            pull_strength = @grip * @weight
            adjusted = new_value + ((reference_value - new_value) * pull_strength)
            adjusted.clamp(0.0, 1.0).round(10)
          end

          def ironclad?
            @grip >= 0.8
          end

          def drifting?
            @grip < 0.2
          end

          def heavy?
            @weight >= 0.7
          end

          def light?
            @weight < 0.3
          end

          def grip_label
            Constants.label_for(Constants::GRIP_LABELS, @grip)
          end

          def to_h
            {
              id:              @id,
              anchor_type:     @anchor_type,
              domain:          @domain,
              content:         @content,
              reference_value: @reference_value,
              grip:            @grip,
              weight:          @weight,
              grip_label:      grip_label,
              ironclad:        ironclad?,
              drifting:        drifting?,
              created_at:      @created_at
            }
          end

          private

          def validate_anchor_type!(val)
            return if Constants::ANCHOR_TYPES.include?(val.to_sym)

            raise ArgumentError,
                  "unknown anchor type: #{val.inspect}; " \
                  "must be one of #{Constants::ANCHOR_TYPES.inspect}"
          end
        end
      end
    end
  end
end
