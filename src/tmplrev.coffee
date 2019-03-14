
if typeof define isnt 'function'
	`define = require('amdefine')(module)`

define 'tmplrev', ['underscore','difflib'], (_, difflib) ->

	class PLACEHOLDER
		constructor: ()->
			@name = "PLACEHOLDER"
		toString: ()->
			"{#{@name}}"

	PLACEHOLDER = new PLACEHOLDER()
	ANY = Symbol('ANY')
	BOF = Symbol('BOF')
	EOF = Symbol('EOF')
	

	partition = (seq, len, step=null) ->
		ret = []
		if !step || step <= 0
			step = len

		for i in [0...(seq.length-len+step)] by step
			subseq = seq.slice(i,i+len)
			ret.push subseq
		return ret


	partitionBy = (seq, val, exclude=false) ->
		ret = []
		begin = end = 0
		for i in [0...seq.length]
			if _.isEqual(seq[i], val)
				if end > begin
					ret.push seq.slice(begin, end)
				if not exclude
					ret.push seq.slice(i,i+1)
				begin = end = i+1
			else
				end = i+1

		if end > begin
			ret.push seq.slice(begin, end)
		return ret


	diff = (a, b) ->
		ret = [BOF]
		cur_line = 0
		dd = difflib.ndiff(a , b)
		for d in dd
			if d[0] == '-'
				ret.push ANY if _.last(ret) != ANY
				cur_line += 1
			else if d[0] == '+'
				ret.push ANY if _.last(ret) != ANY
			else if d[0] == '?'
				# pass
			else
				ret.push a[cur_line]
				cur_line += 1
		ret.push EOF
		return ret


	detect = (a, b, sidelen=10)->
		pat = partition( partitionBy( diff(a,b), ANY, true), 2, 1)
		for p in pat
			if p[0].length > sidelen
				p[0] = p[0].slice(p[0].length-sidelen, p[0].length)
			if p[1].length > sidelen
				p[1] = p[1].slice(0,sidelen)
		return pat


	find = (seq, subseq, offset=0)->
		for i in [offset...seq.length]
			matched = true
			for j in [0...subseq.length]
				if not _.isEqual( seq[i+j], subseq[j] ) 
					matched = false
					break
			if matched
				return i
		return -1
		

	extract = (pat, seq)->
		seq = seq.split('') if typeof seq == "string"
		seq.unshift BOF if _.first(seq) != BOF
		seq.push EOF 	if _.last(seq) != EOF

		begin = end = 0
		extracted = []

		begin = find(seq, pat[0])
		# console.log seq, pat[0], begin
		if begin != -1
			offset = begin + pat[0].length
			end = find(seq, pat[1], offset)
			if end != -1
				extracted = seq.slice(offset, end)
		return extracted

	{
		ANY: ANY
		BOF: BOF
		EOF: EOF
		PLACEHOLDER: PLACEHOLDER
		diff: diff
		partition: partition
		partitionBy: partitionBy
		detect: detect
		extract: extract
		find: find
	}
	
