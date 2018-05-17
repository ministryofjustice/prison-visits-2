module Nomis
  class Code
    include MemoryModel

    attribute :code, :string
    attribute :desc, :string
  end
end
