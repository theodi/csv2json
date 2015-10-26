require 'rdf'
require 'rdf/turtle'

class EarlFormatter
  def initialize(step_mother, io, options)
    output = RDF::Resource.new("")
    @graph = RDF::Graph.new
    @graph << [ CSV2JSON, RDF.type, RDF::DOAP.Project ]
    @graph << [ CSV2JSON, RDF.type, EARL.TestSubject ]
    @graph << [ CSV2JSON, RDF.type, EARL.Software ]
    @graph << [ CSV2JSON, RDF::DOAP.name, "csv2json" ]
    @graph << [ CSV2JSON, RDF::DC.title, "csv2json" ]
    @graph << [ CSV2JSON, RDF::DOAP.homepage, RDF::Resource.new("https://github.com/theodi/csvlint.rb") ]
    @graph << [ CSV2JSON, RDF::DOAP.license, RDF::Resource.new("https://raw.githubusercontent.com/theodi/csvlint.rb/master/LICENSE.md") ]
    @graph << [ CSV2JSON, RDF::DOAP["programming-language"], "Ruby" ]
    @graph << [ CSV2JSON, RDF::DOAP.implements, RDF::Resource.new("http://www.w3.org/TR/tabular-data-model/") ]
    @graph << [ CSV2JSON, RDF::DOAP.implements, RDF::Resource.new("http://www.w3.org/TR/tabular-metadata/") ]
    @graph << [ CSV2JSON, RDF::DOAP.implements, RDF::Resource.new("http://www.w3.org/TR/csv2json/") ]
    @graph << [ CSV2JSON, RDF::DOAP.developer, ODI ]
    @graph << [ CSV2JSON, RDF::DOAP.maintainer, ODI ]
    @graph << [ CSV2JSON, RDF::DOAP.documenter, ODI ]
    @graph << [ CSV2JSON, RDF::FOAF.maker, ODI ]
    @graph << [ CSV2JSON, RDF::DC.creator, ODI ]
    @graph << [ CSV2JSON, RDF::DC["isPartOf"], CSVLINT ]
    @graph << [ output, RDF::FOAF["primaryTopic"], CSV2JSON ]
    @graph << [ output, RDF::DC.issued, DateTime.now ]
    @graph << [ output, RDF::FOAF.maker, ODI ]
    @graph << [ ODI, RDF.type, RDF::FOAF.Organization ]
    @graph << [ ODI, RDF.type, EARL.Assertor ]
    @graph << [ ODI, RDF::FOAF.name, "Open Data Institute" ]
    @graph << [ ODI, RDF::FOAF.homepage, "https://theodi.org/" ]
  end

  def scenario_name(keyword, name, file_colon_line, source_indent)
    @test = RDF::Resource.new("http://www.w3.org/2013/csvw/tests/#{name.split(" ")[0]}")
  end

  def after_steps(steps)
    passed = true
    steps.each do |s|
      passed = false unless s.status == :passed
    end
    a = RDF::Node.new
    @graph << [ a, RDF.type, EARL.Assertion ]
    @graph << [ a, EARL.assertedBy, ODI ]
    @graph << [ a, EARL.subject, CSV2JSON ]
    @graph << [ a, EARL.test, @test ]
    @graph << [ a, EARL.mode, EARL.automatic ]
    r = RDF::Node.new
    @graph << [ a, EARL.result, r ]
    @graph << [ r, RDF.type, EARL.TestResult ]
    @graph << [ r, EARL.outcome, passed ? EARL.passed : EARL.failed ]
    @graph << [ r, RDF::DC.date, DateTime.now ]
  end

  def after_features(features)
    RDF::Writer.for(:ttl).open("csv2json-earl.ttl", { :prefixes => { "earl" => EARL }, :standard_prefixes => true, :canonicalize => true, :literal_shorthand => true }) do |writer|
      writer << @graph
    end 
  end

  private
    EARL = RDF::Vocabulary.new("http://www.w3.org/ns/earl#")
    ODI = RDF::Resource.new("https://theodi.org/")
    CSV2JSON = RDF::Resource.new("https://github.com/theodi/csv2json")
    CSVLINT = RDF::Resource.new("https://github.com/theodi/csvlint.rb")

end
