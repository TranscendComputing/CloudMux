class ResourceApiBase < ApiBase
	def body_to_json(request)
		if(!request.content_length.nil? && request.content_length != "0")
			return MultiJson.decode(request.body.read)
		else
			return nil
		end
	end
	
	def handle_error(error)
		case error
			when Excon::Errors::BadRequest
				response_body = Nokogiri::XML(error.response.body)
				message = response_body.css('Message').text
				if message.nil?
					response_body = JSON.parse(error.response.body)
					message = response_body["badRequest"]["message"]
				end
				[BAD_REQUEST, message]
			when Excon::Errors::InternalServerError        
				response_body = Nokogiri::XML(error.response.body)
				if response_body.css('Message').empty?
					message = error.response.body
				else
					message = response_body.css('Message').text
				end
				[ERROR, message]
			when Excon::Errors::NotFound
				begin
					response_body = Nokogiri::XML(error.response.body)
					message = response_body.css('Message').text
				rescue
					message = "Unable to connect to service endpoint"
				end
				[NOT_FOUND, message]
			when Excon::Errors::Forbidden
				begin
					response_body = JSON.parse(error.response.body)
					message = response_body["forbidden"]["message"]
				rescue JSON::ParserError => json_error
					response_body = Nokogiri::XML(error.response.body)
					message = response_body.css('Message').text
				rescue
					message = "Unable to connect to service endpoint"
				end
				[FORBIDDEN, message]
			when Excon::Errors::Timeout
				message = "Read Timeout Reached"
				[TIMEOUT, message]
			when Net::HTTPServerException
				message = JSON.parse(error.response.body)["error"][0]
				[ERROR, message]
			when Fog::AWS::IAM::Error
				error = error.message.split(" => ")
				message = error[1]
				[NOT_FOUND, message]     
			when Fog::Compute::AWS::Error
				error = error.message.split(" => ")
				message = error[1]
				[NOT_ACCEPTABLE, message]
			when Fog::AWS::RDS::NotFound, Fog::AWS::Elasticache::NotFound
				message = error.to_s
				[NOT_FOUND, message]
			when ArgumentError
				message = error.to_s
				[BAD_REQUEST, message]
			else
				message = "Invalid request."
				[BAD_REQUEST, message]
		end
	end
end