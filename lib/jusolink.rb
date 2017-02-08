# -*- coding: utf-8 -*-
require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'linkhub'

# Jusolink API Service class
class Jusolink
  ServiceID = "JUSOLINK";
  ServiceURL = "https://juso.linkhub.co.kr"
  POPBILL_APIVersion = "1.0"

  attr_accessor :token_cache, :scopes, :isTest, :linkhub

  # Generate Linkhub Class Singleton Instance
  class << self
    def instance(linkID, secretKey)
      @instance ||= new
      @instance.token_cache = nil
      @instance.linkhub = Linkhub.instance(linkID, secretKey)
      @instance.scopes = ["200"]
      return @instance
    end
    private :new
  end

  # Get Session Token by checking token-cache
  def getSession_Token()
    targetToken = nil
    refresh = false

    # check already cached CorpNum's SessionToken
    unless @token_cache.nil?
      targetToken = @token_cache
    end

    if targetToken.nil?
      refresh = true
    else
      # Token's expireTime must use parse() because time format is hh:mm:ss.SSSZ
      expireTime = DateTime.parse(targetToken['expiration'])
      serverUTCTime = DateTime.strptime(@linkhub.getTime())
      refresh = expireTime < serverUTCTime
    end

    if refresh
      begin
        # getSessionToken from Linkhub
        targetToken = @linkhub.getSessionToken(ServiceID, "", @scopes)
      rescue LinkhubException => le
        raise JusolinkException.new(le.code, le.message)
      end
      # refresh @token_cache object
      @token_cache = targetToken
    end

    targetToken['session_token']
  end # end of getSession_Token

  def gzip_parse (target)
    sio = StringIO.new(target)
    gz = Zlib::GzipReader.new(sio)
    gz.read()
  end

  # Jusolink API http Get Request Func
  def httpget(url)
    headers = {
      "x-pb-version" => Jusolink::POPBILL_APIVersion,
      "Accept-Encoding" => "gzip,deflate",
    }

    headers["Authorization"] = "Bearer " + getSession_Token()

    uri = URI(ServiceURL + url)
    request = Net::HTTP.new(uri.host, 443)
    request.use_ssl = true

    Net::HTTP::Get.new(uri)

    res = request.get(uri.request_uri, headers)

    if res.code == "200"
      if res.header['Content-Encoding'].eql?('gzip')
        JSON.parse(gzip_parse(res.body))
      else
        JSON.parse(res.body)
      end
    else
      raise JusolinkException.new(JSON.parse(res.body)["code"],
        JSON.parse(res.body)["message"])
    end
  end #end of httpget


  # Get Partner's Remain Point
  def getBalance
    begin
      @linkhub.getPartnerBalance(getSession_Token(), ServiceID)
    rescue LinkhubException => le
      raise JusolinkException.new(le.code, le.message)
    end
  end

  # Get Jusolink UnitCost
  def getUnitCost
    httpget('/Search/UnitCost')['unitCost']
  end

  # search
  def search(index, pageNum = 1, perPage = 20, noSuggest = false, noDiff = false)
    if index.to_s == ''
      raise JusolinkException.new('-99999999', '검색어가 입력되지 않았습니다.')
    end

    uri = "/Search?Searches="+index
    uri += "&PageNum=" + pageNum.to_s
    uri += "&PerPage=" + perPage.to_s

    if noSuggest
      uri += "&noSuggest=true"
    end

    if noDiff
      uri += "&noDiff=true"
    end

    httpget(URI.escape(uri))
  end


end # end of Jusolink class

# Popbill API Exception Handler class
class JusolinkException < StandardError
  attr_reader :code, :message
  def initialize(code, message)
    @code = code
    @message = message
  end
end
