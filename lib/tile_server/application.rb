module TileServer
  class Application < Sinatra::Base
  	def initialize
	  super
	  
	  tileset = ENV.fetch "TILESERVER_DATABASE", "tiles.mbtiles"
	  		
	  @pool = Pond.new maximum_size: 12, timeout: 600 do
		SQLite3::Database.new tileset, readonly: true
      end
	  
	  @info = {}
	
	  preinfo = nil
		
	  @pool.checkout do |db|
	    db.execute "SELECT name, value FROM metadata" do |(name, value)|
		  case name
		  when "maxzoom", "minzoom"
		    @info[name] = Integer(value)
			
		  when "bounds"
			@info[name] = value.split(",").map! { |v| Float(v) }
			
		  when "json"
			preinfo = JSON.parse value
			
		  else
			@info[name] = value
		   end
		end
	
		unless preinfo.nil?
			@info = preinfo.merge @info
		end
	  end
	
	end
	
	get '/tiles.json' do
	  last_modified DateTime.strptime(@info['mtime'], '%Q')
	
	  json @info.merge({
		"tilejson" => "2.0.0",
		"tiles" => [
			request.base_url + "/tiles/{z}/{x}/{y}.pbf"
		]
	  })
	end
	
	get '/tiles/:z/:x/:y.pbf' do	
      zoom = Integer(params[:z])
	  x = Integer(params[:x])
	  y = Integer(params[:y])
		
	  last_modified DateTime.strptime(@info['mtime'], '%Q')

      tile = nil

      @pool.checkout do |db|
	    db.execute "SELECT tile_data FROM tiles WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?", [ Integer(params[:z]), Integer(params[:x]), Integer(params[:y]) ] do |(data)|
	      headers['Content-Encoding'] = 'gzip'
		  tile = data
	    end
	  end
	  
	  if tile.nil?
		404
	  else
	    content_type 'application/octet-stream'
		tile
	  end
	end
  end
end
