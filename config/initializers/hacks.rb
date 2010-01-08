module ActionController #:nodoc:

  class Responder
    def has_errors?
      begin
        resource.respond_to?(:errors) && !resource.errors.empty?
      rescue
        false
      end
    end
  end
end
