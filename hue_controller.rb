require 'net/https'
require 'uri'
require 'yaml'

class HueController
	HUE_WILDCARD = "HUE_VALUE"
	CHANGE_COLOR_JSON = <<-EOF
{
    "on": true,
    "effect": "none",
    "hue": #{HUE_WILDCARD},
    "sat": 255,
    "bri": 255,
    "transitiontime": 0
}
EOF

	def initialize(config)
		@host = config['host']
		@api_key = config['api_key']
		@primary_lights = config['primary']
		@secondary_lights = config['secondary']
	end

	def set_colors(primary, secondary)
		hue1, sat1, lum1 = to_hsl(primary)
		hue2, sat2, lum2 = to_hsl(secondary)

		@primary_lights.each do |light_id|
			send(light_id, hue1)
		end

		@secondary_lights.each do |light_id|
			send(light_id, hue2)
		end
	end

	private

    def send(light_id, hue)
		url = "http://#{@host}/api/#{@api_key}/lights/#{light_id}/state"
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = false

		http.put(uri.path, CHANGE_COLOR_JSON.gsub(HUE_WILDCARD, hue.to_s), {})
    end

    def hex_to_int(hex)
    	val = 0
    	hex.split('').each do |c|
    		if ('0'.ord..'9'.ord) === c.ord
	    		val *= 16
    			val += c.ord - '0'.ord
    		elsif ('a'.ord..'f'.ord) === c.ord
	    		val *= 16
    			val += c.ord - 'a'.ord + 10
    		elsif ('A'.ord..'F'.ord) === c.ord
	    		val *= 16
    			val += c.ord - 'F'.ord + 10
    		end
    	end
    	val
    end

    def to_hsl(rgb)
    	r = hex_to_int(rgb[0..1])
    	g = hex_to_int(rgb[2..3])
    	b = hex_to_int(rgb[4..5])

		r /= 255.0
		g /= 255.0
		b /= 255.0
		max = [r, g, b].max
		min = [r, g, b].min
		h = (max + min) / 2.0
		s = (max + min) / 2.0
		l = (max + min) / 2.0

		if(max == min)
			h = 0
			s = 0 # achromatic
		else
			d = max - min;
			s = l >= 0.5 ? d / (2.0 - max - min) : d / (max + min)
			case max
				when r
					h = (g - b) / d + (g < b ? 6.0 : 0)
				when g
					h = (b - r) / d + 2.0
				when b
					h = (r - g) / d + 4.0
			end
			h /= 6.0
		end

    	return [(h*65535).round, (s*254).round, (l*254).round]
    end
end
