class Product < ActiveRecord::Base
  attr_accessible :currency, :long_description, :manufacturer_name, :price, :product_name, :short_description

 
 def self.import(file)
  CSV.foreach(file, headers: true) do |row| 
   product_hash = row.to_hash # exclude the price field
   product = Product.where(id: product_hash["id"])
   if product.count == 1
    product.first.update_attributes(product_hash)
   else
    Product.create!(product_hash)
   end # end if !product.nil?
  end # end CSV.foreach
 end # end self.import(file)
end
