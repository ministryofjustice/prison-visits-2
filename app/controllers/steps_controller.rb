class StepsController < ApplicationController
  helper FormElementsHelper

  def index
    processor = StepsProcessor.new(params)
    @steps = processor.steps
    render processor.template_name
  end

  def create
    processor = StepsProcessor.new(params)
    processor.execute!
    @steps = processor.steps
    render processor.template_name
  end
end
