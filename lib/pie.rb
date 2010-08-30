require 'sinatra/base'

class Pie 
  class WebApp < Sinatra::Base
    set :root, File.join(File.expand_path(File.dirname(__FILE__)), "..")

    get '/' do
      "hello"
    end

    get '/:place_name' do
      name = params[:place_name]
      $current = name unless name.nil?
      erb :image_page
    end
  end

  at_exit { WebApp.run! if !$0.include?("spec")}

  attr_accessor :places
  attr_accessor :images

  class Places < Hash
    def method_missing name, options = {}
      unless options.is_a? Hash
        puts "options for creating a place must have key and value"
        return
      end
      puts "making a #{name} with #{options.inspect}"
      self[name.to_sym] = options
    end

    def after(place_name)
      index = keys.index(place_name.to_sym)
      next_place_name = keys[index + 1]
      self[next_place_name]
    end

    def before(place_name)
      index = keys.index(place_name.to_sym)
      index = index - 1
      if index < 0
        nil
      else
        prev_place_name = keys[index]
        self[prev_place_name]
      end
    end
  end

  def create_places(&block)
    @places ||= Places.new
    @places.instance_eval(&block)
  end

  def image(image_hash)
    @images ||= {}
    puts "--- set image"
    puts image_hash.inspect
    @images.merge!(image_hash)
  end

 def current_image
    puts "------- current_image"
    puts $current.inspect
    puts @images.inspect
    @images[$current.to_sym]
  end

  def current_description
    puts "------- current_description"
    puts $current.inspect
    puts @places.inspect
    place = @places[$current.to_sym]
    place[:description] unless place.nil?
  end
end

def make_pie(&block)
  $pie = Pie.new
  $pie.instance_eval(&block)
end

make_pie do
  create_places do
    ship description:"ookina funa"
    building description:"ookina biru"
    tower description:"ookina towa"
  end

  image ship:"images/big_ship.jpg", 
        building:"images/building.jpg", 
        tower:"images/tokyo_tower.jpg" 
end
