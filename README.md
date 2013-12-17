#Introduction

There are many solutions available in Rails for moving long-running jobs into a background process. Each of these has its own advantages and Sidekiq is no exception. Sidekiq is similar to Resque,its primary difference is that it handles multiple jobs concurrently using threads instead of processes and this can save on memory usage.

#Requirements
Like Resque, Sidekiq uses Redis to manage its job queue so we’ll need to install this first.If you use Debian OS use this command to install

```
sudo apt-get install redis-server
```
If you're running RPM based OS than use this command to install

```
sudo yum install redis-server
```

and if you’re running OS X the easiest way to do this to use Homebrew to install it by running this command:

```
$ brew install redis
```

Next we’ll add the Sidekiq gem to the gemfile and run bundle to install it.

```
gem 'sidekiq'
```
#Getting Started

After installing redis-server add ```sidekiq.rb``` file withing ```config/initializer``` and configure sidekiq with redis server.

```
Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://localhost:6379', :namespace => 'sidekiq_demo' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://localhost:6379', :namespace => 'sidekiq_demo' }
end
```

There are several interfaces that Sidekiq supports. The most common way to use it is to create a separate worker class and we’ll do this, creating a class in a new ```app/workers``` directory. Putting it here ensures that it’s auto-loaded by the application.

```
class ProcessImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :high

  def perform

  end
end
```

This class needs to include the ```Sidekiq::Worker``` module, and have a perform method which contains the code that we want to run in the background. We’ll move the syntax-highlighting code from the controller into this method. To do this we call PygmentsWorker.perform_async which will add the job to Redis and then call perform asynchronously.

Now in the worker class we add the code to perform background process

```
class ProcessImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :high

  def perform file
   Product.import file  #import is a class method in Model
  end
end
```
Add method ```import``` in Product Model

```
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

```
We call the Worker method from controller to perform background operation to upload product from csv.

```
class ProductsController < ApplicationController 

  def import
   ProcessImportWorker.perform_async params[:file].path
   redirect_to root_url, notice: "Products imported."
  end
end
```
#Sidekiq’s Features

Now that we know how to set up Sidekiq we’ll take a look at some of its features. the ability to prioritize queues. Let’s say that our application has multiple workers and we want certain ones to be processed first. To do this we’ll need to assign a worker to a specific queue and we can do this by setting the queue option, like this:

```
class ProcessImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :high

   # Rest of class 
```

If we don’t specify the name of a queue the worker will default to a queue called default. When we run the sidekiq command now we can specify the queues that we want to be processed with the -q option and give each one a relative weight.

```
bundle exec sidekiq -q high,5 default,1 -P tmp/pids/sidekiq.pid -L log/sidekiq.log -d
```

#Monitoring Sidekiq

Next we’ll talk about monitoring the workers. Sidekiq includes a web interface, which is a Sinatra app that we can mount inside our Rails app in the routes file. we need to add route for that in ```config/routes.rb```
```
 mount Sidekiq::Web, at: '/sidekiq'
```

and we need to add gem within ```Gemfile```

```
gem 'sinatra', require: false
gem 'slim'
```
If we visit the ```/sidekiq``` path now we’ll see the web interface which tells us how many jobs have been processed, the number of failures, the currently-active workers and what queues we have.

![alt tag](/public/sidekiq.png)

