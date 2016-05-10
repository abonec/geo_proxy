# based on this algorithm explanation:
# http://www.bigfastblog.com/geohash-intro
module GeohashNaive
  #BASE32 mapping
  BASE32='0123456789bcdefghjkmnpqrstuvwxyz'
  # those bits used for set ones to every 5 bits group by using bitwise OR
  BITS=[0b10000, 0b01000, 0b00100, 0b00010, 0b00001]
  def encode(lat, lon, precision=12)
    # lat_plane and lon_plane used to split whole world in a half on every iteration
    lat_plane = [-90.0,90.0]
    lon_plane = [-180.0, 180.0]
    # in each iteration we process either lon or lat. Starting with lon
    lon_processing = true
    # each hash letter increase precision of our hash by splitting our plane in a half
    (0...precision).map do
      # starting with an every zero
      ch = 0b00000
      5.times do |bit|
        # in case of lon processin
        if lon_processing
          # calculate mid of our world or subworld
          mid = lon_plane.inject(:+) / 2
          # if lon in a right plane we set 1 in a corresponding place
          if lon > mid
            ch |= BITS[bit]
            lon_plane[0] = mid
          else
            lon_plane[1] = mid
          end
        else
          # calculate mid of our world or subworld
          mid = lat_plane.inject(:+) / 2
          # if lat in a right plane we set 1 in a corresponding place
          if lat > mid
            ch |= BITS[bit]
            lat_plane[0] = mid
          else
            lat_plane[1] = mid
          end
        end
        # next every iteration should process next coordinate, i.e. lon -> lat -> lon -> lat ....
        lon_processing = !lon_processing
      end
      # puts ch.to_s(2)
      BASE32[ch]
    end.join
  end
  module_function :encode


  def decode(geohash)
    lat_plane = [-90.0, 90.0]
    lon_plane = [-180.0, 180.0]
    lon_processing = true
    geohash.downcase.each_char do |char|
      ch = BASE32.index(char)
      BITS.each do |bit|
        if lon_processing
          mid = lon_plane.inject(:+) / 2
          if bit & ch == bit
            lon_plane[0] = mid
          else
            lon_plane[1] = mid
          end
        else
          mid = lat_plane.inject(:+) / 2
          if bit & ch == bit
            lat_plane[0] = mid
          else
            lat_plane[1] = mid
          end
        end
        lon_processing = !lon_processing
      end
    end
    [lat_plane.last, lon_plane.last]
  end
  module_function :decode
end
