class ParameterPruner
  def prune(params)
    prune_object(params)
  end

private

  def prune_hash(hash)
    HashWithIndifferentAccess.new(
      hash.
        map { |k, v| [k, prune(v)] }.
        reject { |_, v| v.blank? }.
        to_h
    )
  end

  def prune_object(obj)
    case obj
    when Hash
      prune_hash(obj)
    when Array
      obj.map { |p| prune(p) }.reject(&:blank?)
    else
      obj.presence
    end
  end
end
