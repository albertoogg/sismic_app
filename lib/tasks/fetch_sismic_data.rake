namespace :fetch_sismic_data do
    desc 'Fetch and persist sismic data from USGS feed'
    task fetch: :environment do
      require 'rest-client'
      require 'json'
  
      # Realizamos la solicitud GET al feed de USGS
      response = RestClient.get 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson'
      data = JSON.parse(response.body)
  
      # Iteramos sobre cada elemento del feed
      data['features'].each do |feature|
        attributes = feature['properties']
  
        # Validamos los campos requeridos
        next unless attributes['title'] && attributes['url'] && attributes['place'] && attributes['magType'] && feature['geometry']['coordinates'].size == 2
  
        # Validamos los rangos
        next unless (-1.0..10.0).cover?(attributes['mag'].to_f) && (-90.0..90.0).cover?(feature['geometry']['coordinates'][1].to_f) && (-180.0..180.0).cover?(feature['geometry']['coordinates'][0].to_f)
  
        # Persistimos los datos en la base de datos
        Feature.create(
          external_id: feature['id'],
          magnitude: attributes['mag'],
          place: attributes['place'],
          time: attributes['time'],
          url: attributes['url'],
          tsunami: attributes['tsunami'],
          mag_type: attributes['magType'],
          title: attributes['title'],
          longitude: feature['geometry']['coordinates'][0],
          latitude: feature['geometry']['coordinates'][1]
        )
      end
    end
  end
  
