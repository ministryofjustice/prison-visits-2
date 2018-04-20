class LoadTestDataRemover
  def run
    Visit.joins(:visitors).where("visitors.first_name = 'Load'").where("visitors.last_name = 'Test'").destroy_all
  end
end
