class ProductsController < ApplicationController
  def index
   @products = Product.all
  end

  def edit
   @product = Product.find params[:id]
  end
 
  def new
   @product = Product.new
  end
  def show
  @product = Product.find params[:id]
  end 

  def import

   ProcessImportWorker.perform_async params[:file].path
   redirect_to root_url, notice: "Products imported."
  end
end
