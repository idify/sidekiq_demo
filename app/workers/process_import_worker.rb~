class ProcessImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :high

  def perform file
   Product.import file
  end
end
