require 'rubygems'
require 'json/ld'
require_relative 'sparql_quick'

class JackRDF
  
  
  # endp { String } Queryable Sparql endpoint
  
  def initialize( endp, onto=nil )
    @endp = endp
    @sparql = SparqlQuick.new( @endp )
    if onto != nil 
      @urn = onto['uri_prefix'] + "urn:"
      @src = onto['src_verb']
    else
      @urn = "http://data.perseus.org/collections/urn:"
      @src = "http://purl.org/dc/terms/source"
    end
  end
  
  
  # Return the src verb.
  # Used by the JackSON server.
  
  def src_verb
    @src
  end
  
  
  # url { String } URL to JSON-LD
  # file { String } Local path to JSON-LD
  
  def post( url, file )
    
    # Does this already exist?
    
    if @sparql.count([ url.tagify,:p,:o ]) > 0
      throw JackRDF_Critical, "#{url} graph already exists. Use .put()"
    end
    
    # Turn JSON into a hash for checking
    
    hash = file_to_hash( file )
    if hash.has_key?('@context') == false
      throw JackRDF_Error, "#{file} is not JSON-LD"
    end
    context = hash['@context']
    
    # CITE URN put() check
    
    if id_mode( hash ) == true
      if @sparql.count([ hash['@id'].tagify,@src.tagify,url ]) > 0
        throw JackRDF_Critical, "Triples sourced from #{url} already exist in #{hash['urn']} graph. Use .put()"
      end
      
      # Add src
      
      context['src'] = @src
      hash['src'] = url
    end
    
    # RDF subject is url to JSON-LD by default
    
    if hash.has_key?('@id') == false
      hash['@id'] = url
    end
    
    # Convert to RDF
    
    rdf = hash_to_rdf( hash )
    
    # CITE URN support
    
    if id_mode( hash ) == true
      rdf = urn_rdf( hash, rdf )
    end
    
    # Insert the RDF data
    
    @sparql._update.insert_data( rdf )
  end
  
  # hash { Hash }
  
  def urn_rdf( hash, rdf )
    urn_rdf = RDF::Graph.new
    rdf.each do |tri|
      tri.subject = RDF::Resource.new( hash['@id'] )
      tri.object = urn_obj( tri.object )
      urn_rdf << tri
    end
    urn_rdf
  end
  
  def urn_obj( obj )
    str = obj.to_s
    if str.include?( @urn )
      return RDF::Resource.new( str.sub( @urn, 'urn:' ) )
    end
    obj
  end
  
  # hash { Hash }
  
  def hash_to_rdf( hash )
    rdf = to_rdf( to_jsonld( hash ) )
  end
  
  # url { String } URL to JSON file
  # file { String } Path to file
  
  def put( url, file )
    delete( url, file )
    post( url, file )
  end
  
  # url { String } URL to JSON file
  # file { String } Path to file
  
  def delete( url, file )
    hash = to_hash( File.read( file ) )
    if hash.has_key?('@context') == false
      throw JackRDF_Error, "#{file} is not JSON-LD"
    end
    
    # Non-CITE mode deletion is easy
    
    if id_mode( hash ) == false
      return @sparql.delete([ url.tagify, :p, :o ])
    end
    
    # Make sure subject URN and source JSON match
    
    # puts @sparql.count([ hash['@id'].tagify, @src.tagify, url ])
    if @sparql.count([ hash['@id'].tagify, @src.tagify, url ]) != 1
      throw JackRDF_Critical, "#{hash['@id']} is not src'd by #{url}"
    end
    
    # Delete the relevant triples
    
    rdf = urn_rdf( hash, hash_to_rdf( hash ) )
    rdf.each do |tri|
      @sparql._update.delete_data( @sparql.graph( tri ) )
    end
    @sparql.delete([ hash['@id'].tagify, @src.tagify, url ])
  end
  
  # Check for CITE mode markers
  # hash { Hash }
  
  def id_mode( hash )
    context = hash['@context']
    if hash.has_key?('@id') == true 
      if context.has_key?('urn') && context['urn'] == @urn && hash['@id'].include?( 'urn:' )
        return true
      end
    end
    false
  end
  
  # file { String } Path to file
  # @return { Hash }
  
  def file_to_hash( file )
    to_hash( File.read( file ) )
  end
  
  # json { JSON }
  # @return { Hash }
  
  def to_hash( json )
    JSON.parse( json )
  end
  
  # hash { Hash }
  # @return { JSON-LD }
  
  def to_jsonld( hash )
    JSON::LD::API.expand( hash )
  end
  
  # jsonld { JSON-LD }
  # @return { RDF::Graph }
  
  def to_rdf( jsonld )
    RDF::Graph.new << JSON::LD::API.toRdf( jsonld )
  end
  
end

class JackRDF_Error < StandardError
end

class JackRDF_Critical < StandardError
end
