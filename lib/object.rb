# frozen_string_literal: true

class Object
  # Now you can options.convert_keys { |k| k.to_sym }
  def convert_keys(&blk)
    case self
      when Array
        self.map { |v| v.convert_keys(&blk) }
      when Hash
        self.map { |k, v| [blk.call(k), v.convert_keys(&blk)] }.to_h
      else
        self
    end
  end
end
