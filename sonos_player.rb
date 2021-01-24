require 'net/https'
require 'uri'

class SonosPlayer
	REMOVE_TRACKS_SOAP = <<-EOF
<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:RemoveAllTracksFromQueue xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
            <InstanceID>0</InstanceID>
        </u:RemoveAllTracksFromQueue>
    </s:Body>
</s:Envelope>
	EOF

	URL_WILDCARD = "TRACK_URL"
	ADD_TRACK_SOAP = <<-EOF
<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:AddURIToQueue xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
            <InstanceID>0</InstanceID>
            <EnqueuedURI>#{URL_WILDCARD}</EnqueuedURI>
            <EnqueuedURIMetaData></EnqueuedURIMetaData>
            <DesiredFirstTrackNumberEnqueued>1</DesiredFirstTrackNumberEnqueued>
            <EnqueueAsNext>0</EnqueueAsNext>
        </u:AddURIToQueue>
    </s:Body>
</s:Envelope>
	EOF

	PLAY_SOAP = <<-EOF
<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:Play xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
            <InstanceID>0</InstanceID>
            <Speed>1</Speed>
        </u:Play>
    </s:Body>
</s:Envelope>
    EOF

    def initialize(config)
        @host = config['host']
    end

    def play_url(url)
    	remove_tracks
    	add_track(url)
    	play
    end

    def pause
        # TODO
    end

    private

    def send(command, soap_body)
		url = "http://#{@host}/MediaRenderer/AVTransport/Control"
		uri = URI.parse(url)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = false

		headers = {
			'Content-Type' => 'text/xml; charset=utf-8',
			'SOAPAction' => "urn:schemas-upnp-org:service:AVTransport:1##{command}"
		}

		http.post(uri.path, soap_body, headers)
    end

    def remove_tracks
		send('RemoveAllTracksFromQueue', REMOVE_TRACKS_SOAP)
    end

    def add_track(url)
		send('AddURIToQueue', ADD_TRACK_SOAP.gsub(URL_WILDCARD, url))
    end

	def play
		send('Play', PLAY_SOAP)
	end
end
