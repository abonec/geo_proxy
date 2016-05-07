require 'json'
class Api < EM::Connection
  include EM::Protocols::LineProtocol
  def receive_line(geohash)
    reduced_geohash = reduce(geohash)
    cache.get(reduced_geohash) do |eta|
      if eta
        send_response eta
      else
        get_eta_for(geohash) do |eta|
          if eta
            cache.set(reduced_geohash, eta, 30)
            send_response eta
          else
            send_response 'error with eta_service'
          end
        end
      end
    end
  end

  # reduce geohash with accuracy up to 76 meters
  def reduce(geohash)
    geohash[0,6]
  end

  def get_eta_for(geohash)
    lat, lon = GeoHash.decode geohash
    connection = EM::HttpRequest.new(eta_api(lat,lon)).get
    connection.callback do
      eta = JSON.parse(connection.response)['eta']
      yield eta
    end
    connection.errback do
      yield
    end
  end

  def eta_api(lat, lon)
    "http://localhost:3000/api/v1/cabs/eta?lat=#{lat}&lon=#{lon}"
  end

  def send_response(response)
    send_data response
    close_connection_after_writing
  end

  def cache
    @cache ||= EM::Protocols::Memcache.connect 'localhost', 11211
  end
end
