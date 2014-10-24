	# Where to check
	http://127.0.0.1:4321/ds/query?query=select+%3Fs+%3Fp+%3Fo%0D%0Awhere+%7B+%3Fs+%3Fp+%3Fo+%7D&output=text&stylesheet=
		
	# Get ready
	cd /var/www/JackRDF/lib
	irb -I .
	
	# Initialize JackRDF
	load 'JackRDF.rb'
	rdf = JackRDF.new( 'http://localhost:4321/ds' )
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.delete( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	# There should be no triples.
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_02.json' )
	rdf.delete( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_02.json' )
	# Make sure contents of urn_2 still there.
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_02.json' )
	rdf.delete( 'http://localhost:4567/test/urn/3', '/var/www/JackRDF/sample/urn_02.json' )
	# Make sure this throws an error.
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_02.json' )
	rdf.delete( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn_02.json' )
	# This shouldn't be possible, but there may be no way to protect against it at this level.
	rake data:destroy
	
	rdf.post( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn.json' )
	rdf.post( 'http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_02.json' )
	rdf.delete( 'http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn_02.json' )
	# This shouldn't be possible, but there may be no way to protect against it at this level.
	rake data:destroy
	
	rdf.post('http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn_02.json' )
	rdf.post('http://localhost:4567/test/urn/2', '/var/www/JackRDF/sample/urn_03.json' )
	rdf.delete('http://localhost:4567/test/urn/1', '/var/www/JackRDF/sample/urn_02.json' )
	# Only Santa Clause should remain!
	rake data:destroy

