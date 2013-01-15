#many of these regexes directly cribbed from
#https://github.com/ngn/vim-apl/blob/master/syntax/apl.vim
CodeMirror.defineMode "apl", (config, parserConfig) ->

	builtInOps = 
		".": "innerProduct"
		"\\": "scan"
		"/": "reduce"
		"⌿": "reduce1Axis"
		"⍀": "scan1Axis"
		"¨": "each"
		"⍣": "power"

	builtInFuncs = 
		#sym  #monadic         #dyadic
		"+": ["conjugate",     "add"]
		"−": ["negate",        "subtract"]
		"×": ["signOf",        "multiply"]
		"÷": ["reciprocal",    "divide"]
		"⌈": ["ceiling",       "greaterOf"]
		"⌊": ["floor",         "lesserOf"]
		"∣": ["absolute",      "residue"]
		"⍳": ["indexGenerate", "indexOf"]
		"?": ["roll",          "deal"]
		"⋆": ["exponentiate",  "toThePowerOf"]
		"⍟": ["naturalLog",    "logToTheBase"]
		"○": ["piTimes",       "circularFuncs"]
		"!": ["factorial",     "binomial"]
		"⌹": ["matrixInverse", "matrixDivide"]
		"<": [null,            "lessThan"]
		"≤": [null,            "lessThanOrEqual"]
		"=": [null,            "equals"]
		">": [null,            "greaterThan"]
		"≥": [null,            "greaterThanOrEqual"]
		"≠": [null,            "notEqual"]
		"≡": ["depth",         "match"]
		"≢": [null,            "notMatch"]
		"∈": ["enlist",        "membership"]
		"⍷": [null,            "find"]
		"∪": ["unique",        "union"]
		"∩": [null,            "intersection"]
		"∼": ["not",           "without"]
		"∨": [null,            "or"]
		"∧": [null,            "and"]
		"⍱": [null,            "nor"]
		"⍲": [null,            "nand"]
		"⍴": ["shapeOf",       "reshape"]
		",": ["ravel",         "catenate"]
		"⍪": [null,            "firstAxisCatenate"]
		"⌽": ["reverse",       "rotate"]
		"⊖": ["axis1Reverse",  "axis1Rotate"]
		"⍉": ["transpose",     null]
		"↑": ["first",         "take"]
		"↓": [null,            "drop"]
		"⊂": ["enclose",       "partitionWithAxis"]
		"⊃": ["diclose",       "pick"]
		"⌷": [null,            "index"]
		"⍋": ["gradeUp",       null]
		"⍒": ["gradeDown",     null]
		"⊤": ["encode",        null]
		"⊥": ["decode",        null]
		"⍕": ["format",        "formatByExample"]
		"⍎": ["execute",       null]
		"⊣": ["stop",          "left"]
		"⊢": ["pass",         "right"]
		
	isOperator = /[\.\/⌿⍀¨⍣]/
	isNiladic = /⍬/
	isFunction = /[\+−×÷⌈⌊∣⍳\?⋆⍟○!⌹<≤=>≥≠≡≢∈⍷∪∩∼∨∧⍱⍲⍴,⍪⌽⊖⍉↑↓⊂⊃⌷⍋⍒⊤⊥⍕⍎⊣⊢]/
	isArrow = /←/
	isComment = /[⍝#].*$/
	
	stringEater = (type) ->
		prev = false
		(c) ->
			prev = c
			if c is type
				return prev is "\\"
			return true

	startState: ->
		prev: false
		func: false
		op: false
		string: false
		escape: false

	token: (stream, state) ->
		if stream.eatSpace()
			return null

		ch = stream.next()

		if ch in ['"', "'"]
			stream.eatWhile stringEater ch
			stream.next()
			state.prev = true
			return "string"

		if /[\[{\(]/.test ch
			state.prev = false
			return null

		if /[\]}\)]/.test ch
			state.prev = true
			return null

		if isNiladic.test ch
			state.prev = false
			return "niladic"

		if /[¯\d]/.test ch
			if state.func
				state.func = false
				state.prev = false
			else
				state.prev = true

			stream.eatWhile /[\w\.]/
			return "number"

		if isOperator.test ch
			return "operator apl-#{builtInOps[ch]}"

		if isArrow.test ch
			return "apl-arrow"

		if isFunction.test ch
			funcName = "apl-"

			if builtInFuncs[ch]?
				if state.prev
					funcName += builtInFuncs[ch][1]
				else
					funcName += builtInFuncs[ch][0]
				
			state.func = true
			state.prev = false
			return "function #{funcName}"

		if isComment.test ch
			stream.skipToEnd()
			return "comment"

		if ch is "∘" and stream.peek() is "."
			stream.next()
			return "function jot-dot"

		stream.eatWhile /[\w\$_]/

		word = stream.current()
		state.prev = true
		return "keyword"


CodeMirror.defineMIME "text/apl", "apl"
