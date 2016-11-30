class PrisonsDecorator < Draper::CollectionDecorator
  delegate :each
  GRID_COLUMNS = 3

  def slab_size
    object.size < GRID_COLUMNS ? object.size : (object.size / GRID_COLUMNS)
  end
end
