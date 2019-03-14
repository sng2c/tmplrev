requirejs = require 'requirejs'


requirejs.config(
	baseUrl: __dirname
	paths: 
		tmplrev: '../lib/tmplrev'
	nodeRequire: require
)


tmplrev = requirejs('tmplrev')
underscore = requirejs('underscore')

console.log "runrun"

ANY = tmplrev.ANY
BOF = tmplrev.BOF
EOF = tmplrev.EOF
PH = tmplrev.PLACEHOLDER

exports.tmplrevTest =
	'base test': (test)->
		test.ok(not underscore.isEqual(BOF,EOF))
		test.ok(underscore.isEqual(ANY,ANY))
		test.ok(not underscore.isEqual(ANY,{name:"ANY"}))
		test.ok(not underscore.isEqual(ANY,"ANY"))
		test.notEqual ANY,BOF
		test.notEqual EOF,BOF
		test.notEqual ANY,EOF
		test.done()

	'partition test': (test) ->
		test.notEqual undefined, tmplrev.partition("abc", 1)
		test.deepEqual ['a','b','c'], tmplrev.partition("abc", 1)
		test.deepEqual ['ab','c'], tmplrev.partition("abc", 2)
		test.deepEqual ['ab','cd'], tmplrev.partition("abcd", 2)
		test.deepEqual ['ab','cd'], tmplrev.partition("abcd", 2, 2)
		test.deepEqual ['ab','bc','cd'], tmplrev.partition("abcd", 2, 1)
		test.deepEqual ['abc','efg'], tmplrev.partition("abcdefg", 3, 4)

		test.deepEqual [[1],[2],[3]], tmplrev.partition([1,2,3],1)
		test.deepEqual [[1,2],[2,3]], tmplrev.partition([1,2,3],2,1)
		test.done()

	'partitionBy test': (test) ->
		test.notEqual undefined, tmplrev.partitionBy("abc","b")
		test.deepEqual ['a','b','c'], tmplrev.partitionBy("abc","b")
		test.deepEqual ['ab','c'], tmplrev.partitionBy("abc","c")
		test.deepEqual ['ab','c','de'], tmplrev.partitionBy("abcde","c")
		test.deepEqual ['a','b','c','b','e'], tmplrev.partitionBy("abcbe","b")
		test.deepEqual ['a','c','e'], tmplrev.partitionBy("abcbe","b",true)

		test.deepEqual [[1],[2],[3]], tmplrev.partitionBy([1,2,3],2)
		test.deepEqual [[1],[[2,3]],[4,5]], tmplrev.partitionBy([1,[2,3],4,5],[2,3])

		test.done()

	'diff test': (test)->
		test.deepEqual [BOF, 1, ANY, 3, EOF], tmplrev.diff([1,2,3],[1,0,3])
		test.deepEqual [BOF, 'H','E','L','L', ANY, EOF], tmplrev.diff("HELLO","HELL")
		test.deepEqual [BOF, 1, ANY, 3, 4, ANY, 5, EOF], tmplrev.diff([1,2,3,4,5],[1,3,4,6,5])

		a = ["Price:","10,000"," / SaleOff:","20%", "email: ","a@hotmail.com"]
		b = ["Price:","120,000"," / SaleOff:","10%", "email: ","b@hotmail.com"]
		c = ["Price:","400"," / SaleOff:","0%", "email: ","c@hotmail.com"]
		d = tmplrev.diff(a,b)

		test.deepEqual [BOF, "Price:", ANY, " / SaleOff:", ANY, "email: ", ANY, EOF], d

		test.done()

	'detect test': (test)->
		test.deepEqual [ [ [ BOF, 1 ], [ 3, EOF ] ] ], tmplrev.detect([1,2,3],[1,0,3])
		test.deepEqual [ [ [ BOF, 'H', 'E', 'L', 'L' ], [ EOF ] ] ], tmplrev.detect("HELLO","HELL")
		test.deepEqual [ [ [ BOF, 1 ], [ 3, 4 ] ], [ [ 3, 4 ], [ 5, EOF ] ] ], tmplrev.detect([1,2,3,4,5],[1,3,4,6,5])
		test.deepEqual [ [ [ 1 ], [ 3 ] ], [ [ 4 ], [ 5 ] ] ], tmplrev.detect([1,2,3,4,5],[1,3,4,6,5],1)

		test.done()

	'find test': (test)->
		test.equal 0, tmplrev.find([1,2,3],[1])
		test.equal 1, tmplrev.find([1,2,3],[2])
		test.equal 2, tmplrev.find([1,2,3],[3])

		test.equal 2, tmplrev.find([1,2,3,4,5,6,7,8],[3,4,5])

		test.equal 1, tmplrev.find([0,1,2,3,0,1,2,0,0,1,2,3],[1,2,3])
		test.equal 1, tmplrev.find([0,1,2,3,0,1,2,0,0,1,2,3],[1,2,3],1)
		test.equal 9, tmplrev.find([0,1,2,3,0,1,2,0,0,1,2,3],[1,2,3],2)

		test.done()		
		

	'extract test': (test)->
		test.deepEqual [5], tmplrev.extract( tmplrev.detect([1,2,3],[1,0,3])[0], [1,5,3] )
		test.deepEqual ['TmplRev'], tmplrev.extract( tmplrev.detect("Hello I am KHS".split(/\s/),"Hello I am Hanson".split(/\s/))[0], "Hello I am TmplRev".split(/\s/) )
		
		pats = tmplrev.detect("Hello I am KHS".split(/\s/)[0],"Hello I am Hanson".split(/\s/))

		
		test.deepEqual [], tmplrev.extract(tmplrev.detect("AB1C", "AB2C")[0], "A3C")
		test.deepEqual ['3'], tmplrev.extract(tmplrev.detect("AB1C", "AB2C")[0], "AB3C")

		test.done()

	'full test':(test)->
		a = [
			"[Web발신]"
			,PH, PH, "승인"
			,"김*승"
			,"29,500","원 ", PH
			,"02/25 16:12"
			,"강동서울정형외"
			,"누적","919,360","원"
		]

		b = [
			"[Web발신]"
			,"KB국민카드","2*2*","승인"
			,"김*승"
			,"9,000","원 ","할부"
			,"02/25 16:17"
			,"봄약국"
			,"누적","928,360","원"
		]
		c = [
			"[Web발신]"
			,"KB국민카드","2*2*","승인"
			,"김*승"
			,"7,800","원 ","할부"
			,"02/26 15:34"
			,"강동서울정형외"
			,"누적","936,160","원"
		]

		d = tmplrev.diff(a,b)
		# console.log [[d]]
		pats = tmplrev.detect(a,b)
		# console.log pats
		labels = 
			0:['KB국민카드', '2*2*']
			1:[ '7,800' ]
			2:[ '할부', '02/26 15:34', '강동서울정형외' ]
			3:[ '936,160' ]
		for i,p of pats
			founds = tmplrev.extract(p, c)
			test.deepEqual labels[i], founds
		test.done()

	'object diff test':(test)->
		class Token
			constructor: (token, value)->
				@token = token
				@value = value
			toString: ()->
				@value

		a = [new Token("EMAIL","a@a.com"), "KHS"]
		b = [new Token("EMAIL","b@a.com"), "KHS"]
		test.deepEqual [BOF,ANY,'KHS',EOF], tmplrev.diff(a,b)
		test.done()

