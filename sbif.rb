## Current Interest Rate & Maximum Conventional Interest Rate
#  something like this

require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Sbif
  RSS_FEED = 'http://www.sbif.cl/sbifweb/RSS/tasas.xml'

  def self.cir
    defined?(@@cir) ? @@cir : tap { self.setup; return @@cir }
  end

  def self.mcir
    defined?(@@mcir) ? @@mcir : tap { self.setup; return @@mcir }
  end

  def self.setup
    @@xml    = Nokogiri::XML open(RSS_FEED)
    @@html   = Nokogiri::HTML @@xml.css("item description").children.first.content
    @@string = @@html.elements.first.content
    @@string.match /%Operaciones.+masInferiores.+\: (.+)% Interes.+\: (.+)%Operaciones.+200 Interes/
    @@cir  = $1.to_f
    @@mcir = $2.to_f
  end
end