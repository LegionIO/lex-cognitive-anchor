# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveAnchor
      module Helpers
        module Constants
          ANCHOR_TYPES = %i[belief assumption experience authority number].freeze

          CHAIN_MATERIALS = %i[steel rope wire thread cobweb].freeze

          MAX_ANCHORS = 200
          MAX_CHAINS  = 100
          DRAG_RATE   = 0.06
          DRIFT_RATE  = 0.03
          BREAK_THRESHOLD = 0.1

          GRIP_LABELS = [
            [(0.8..),      :ironclad],
            [(0.6...0.8),  :firm],
            [(0.4...0.6),  :moderate],
            [(0.2...0.4),  :loose],
            [(..0.2),      :drifting]
          ].freeze

          FLEXIBILITY_LABELS = [
            [(0.8..),      :elastic],
            [(0.6...0.8),  :flexible],
            [(0.4...0.6),  :moderate],
            [(0.2...0.4),  :rigid],
            [(..0.2),      :brittle]
          ].freeze

          def self.label_for(table, value)
            table.each { |range, label| return label if range.cover?(value) }
            table.last.last
          end
        end
      end
    end
  end
end
