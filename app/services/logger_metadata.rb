module LoggerMetadata
module_function

  def add(hash)
    LogStasher.request_context.merge!(hash)
  end
end
