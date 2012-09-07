#!/opt/local/bin/ruby

require 'rubygems'
require 'monster_mash'
require 'yajl/json_gem'
require 'nokogiri'

class Google < MonsterMash::Base
  post(:request_token) do
    uri "https://www.google.com/accounts/ClientLogin"

    headers 'GData-Version' => '3.0',
            'Content-type'  => 'application/x-www-form-urlencoded'

    params  'Email'       => 'hola@ejemplo.com',
            'Passwd'      => 'hola',
            'source'      => 'hola',
            'service'     => 'writely',
            'accountType' => 'HOSTED_OR_GOOGLE'

    handler do |response|
      response.body.strip.to_a.last.split("=").last
    end
  end

  get(:show_documents) do |token|
    uri "https://docs.google.com/feeds/default/private/full"

    headers 'GData-Version' => '3.0',
            'Content-Type'  => 'application/atom+xml',
            'Authorization' => "GoogleLogin auth=#{token}"

    params  'alt' => 'json'

    handler do |response|
      JSON.parse response.body
    end
  end

  get(:show_folders) do |token|
    uri "https://docs.google.com/feeds/default/private/full/-/folder?showfolders=true"

    headers 'GData-Version' => '3.0',
            'Content-Type'  => 'application/atom+xml',
            'Authorization' => "GoogleLogin auth=#{token}"

    params  'alt' => 'json'

    handler do |response|
      JSON.parse response.body
    end
  end


  get(:document_info) do |token, id|
    uri "https://docs.google.com/feeds/default/private/full/#{id}"

    headers 'GData-Version' => '3.0',
            'Content-Type'  => 'application/x-www-form-urlencoded',
            'Authorization' => "GoogleLogin auth=#{token}"

    params  'alt' => 'json'

    handler do |response|
      JSON.parse response.body
    end
  end

  get(:download_document) do |token, id|
    uri "https://docs.google.com/feeds/download/documents/export/Export"

    headers 'GData-Version' => '3.0',
            'Content-Type'  => 'application/atom+xml',
            'Authorization' => "GoogleLogin auth=#{token}"

    params  'id'            => "#{id}",
            'exportFormat'  => 'html'

    handler do |response|
      response.body
    end
  end
end