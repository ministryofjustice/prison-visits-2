module Nomis
  class ApiSerialiser
    def serialise(memory_model_class, payload)
      memory_model = memory_model_class.new
      payload.each do |key, value|
        setter = "#{key}="
        if memory_model.respond_to?(setter)
          memory_model.public_send(setter, value)
        else
          raise_error_for(memory_model_class, key)
        end
      end
      memory_model
    end

  private

    def raise_error_for(klass, key)
      PVB::ExceptionHandler.capture_exception(
        Nomis::Error::UnhandledApiField.new(build_error_message(klass, key))
      )
    end

    def build_error_message(klass, key)
      <<-END_OF_ERROR_MESSAGE
      Unhandled attribute :#{key}

      Consider adding the following to the class #{klass}

         class #{klass}
           # ...
           attribute :#{key}
         end
      END_OF_ERROR_MESSAGE
    end
  end
end
