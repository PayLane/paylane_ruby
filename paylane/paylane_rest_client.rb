# Client library for Paylane REST Server.
# More info at: http://devzone.paylane.com 

require 'rubygems'
require 'net/https'
require 'uri'
require 'json'

module PayLane
  class ClientError < StandardError; end
  class Client

    # PayLane Rest API
    API_URI = "https://direct.paylane.com/rest/"

    attr_reader :username, :password, :params
    attr_accessor :uri, :http, :status

    def initialize(username, password)
      @username = username
      @password = password
      @status = false
    end


    # Return status of last API call for the current
    # client object.
    #
    # @return [Boolean] True if call was successful, False otherwise.
    def success?
      @status
    end


    # Direct Debit sale
    #
    # @param params [Hash] Direct Debit params Hash
    # @return [Hash] Parsed JSON response
    def direct_debit_sale(params)
      connection('directdebits/sale')
      request_method('post', params)
    end


    # Sale info
    #
    # @param params [Hash] Sale info params Hash
    # @return [Hash] Parsed JSON response
    def get_sale_info(params)
      connection('sales/info')
      request_method('get', params)
    end

    # Sale status
    #
    # @param params [Hash] Sale status params Hash
    # @return [Hash] Parsed JSON response
    def check_sale_status(params)
      connection('sales/status')
      request_method('get', params)
    end

    # Check card
    #
    # @param params [Hash] Check card params Hash
    # @return [Hash] Parsed JSON response
    def check_card(params)
      connection('cards/check')
      request_method('get', params)
    end

    # Check card by token
    #
    # @param params [Hash] Check card params Hash
    # @return [Hash] Parsed JSON response
    def check_card_by_token(params)
      connection('cards/checkByToken')
      request_method('get', params)
    end

    # Authorization info
    #
    # @param params [Hash] Authorization info params Hash
    # @return [Hash] Parsed JSON response
    def get_authorization_info(params)
      connection('authorizations/info')
      request_method('get', params)
    end

    # Refund
    #
    # @param params [Hash] Refund params Hash
    # @return [Hash] Parsed JSON response
    def refund(params)
      connection('refund')
      request_method('post', params)
    end

    # Resale by sale
    #
    # @param params [Hash] Resale params Hash
    # @return [Hash] Parsed JSON response
    def resale_by_sale(params)
      connection('resales/sale')
      request_method('post', params)
    end


    # Resale by authorization
    #
    # @param params [Hash] Resale params Hash
    # @return [Hash] Parsed JSON response
    def resale_by_authorization(params)
      connection('resales/authorization')
      request_method('post', params)
    end


    # Paypal sale
    #
    # @param params [Hash] Paypal sale params Hash
    # @return [Hash] Parsed JSON response
    def paypal_sale(params)
      connection('paypal/sale')
      request_method('post', params)
    end


    # Paypal authorization
    #
    # @param params [Hash] Paypal authorization params Hash
    # @return [Hash] Parsed JSON response
    def paypal_authorization(params)
      connection('paypal/authorization')
      request_method('post', params)
    end


    # Bank transfer sale
    #
    # @param params [Hash] Bank transfer params Hash
    # @return [Hash] Parsed JSON response
    def bank_transfer_sale(params)
      connection('banktransfers/sale')
      request_method('post', params)
    end

    # Sofort sale
    #
    # @param params [Hash] Sofort transfer params Hash
    # @return [Hash] Parsed JSON response
    def sofort_sale(params)
      connection('sofort/sale')
      request_method('post', params)
    end

    # Card sale
    #
    # @param params [Hash] Card sale params Hash
    # @return [Hash] Parsed JSON response
    def card_sale(params)
      connection('cards/sale')
      request_method('post', params)
    end


    # Card authorization
    #
    # @param params [Hash] Card authorization params Hash
    # @return [Hash] Parsed JSON response
    def card_authorization(params)
      connection('cards/authorization')
      request_method('post', params)
    end

    # Capture authorization
    #
    # @param params [Hash] Capture authorization params Hash
    # @return [Hash] Parsed JSON response
    def capture_authorization(params)
      connection('authorizations/capture')
      request_method('post', params)
    end

    # Close authorization
    #
    # @param params [Hash] Close authorization params Hash
    # @return [Hash] Parsed JSON response
    def close_authorization(params)
      connection('authorizations/close')
      request_method('post', params)
    end

    # Checks if card is 3-D Secure
    #
    # @param params [Hash] 3-D Secure Card params Hash
    # @return [Hash] Parsed JSON response
    def check_card_3d_secure(params)
      connection('3DSecure/checkCard')
      request_method('get', params)
    end


    # Sale by 3-D Secure authorization
    #
    # @param params [Hash] 3-D Secure Card params Hash
    # @return [Hash] Parsed JSON response
    def sale_by_3d_secure_authorization(params)
      connection('3DSecure/authSale')
      request_method('post', params)
    end


    private


    # Connection to PayLane API
    #
    # @param method [String] PayLane API method name to make full URI path
    def connection(method)
      @uri = URI.parse(API_URI + "#{method}")
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = true
    end


    # Handle method type and some error responses
    #
    # @param method_name [String] method type (PUT, GET, POST, DELETE)
    # @param params [Hash] API call params
    #
    # @return [Hash] parsed JSON response
    # @return [Exception] Raise Exception if response code other than 200
    def request_method(method_name, params = {})
      case method_name
        when 'put'
          request = Net::HTTP::Put.new(@uri.request_uri)
        when 'post'
          request = Net::HTTP::Post.new(@uri.request_uri)
        when 'get'
          request = Net::HTTP::Get.new(@uri.request_uri)
      end
      request["content-type"] = "application/json"
      request.basic_auth(@username, @password)
      request.body = params.to_json
      response = @http.request(request)

      raise ClientError.new("401 Unauthorized") if response.code.to_i == 401
      raise ClientError.new("400 Bad Request") if response.code.to_i == 400
      raise ClientError.new("500 Internal Sever Error") if response.code.to_i == 500
      raise ClientError.new("501 Not implemented") if response.code.to_i == 501

      unless response.code.to_i == 200
        raise ClientError.new("Response status code: #{response.code}")
      end

      resp = JSON.parse(response.body)
      @status = resp["success"]
      resp
    end

  end
end
