module PersistToNomisResponse
  extend ActiveSupport::Concern

  def initialize(persist_to_nomis)
    self.persist_to_nomis = persist_to_nomis
  end

  def persist_to_nomis=(val)
    @persist_to_nomis = ActiveRecord::Type::Boolean.new.cast(val)
  end

  def persist_to_nomis?
    !!@persist_to_nomis
  end
end
