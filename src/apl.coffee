CodeMirror.defineMode "apl", (config, parserConfig) ->
	wordRE = (words) ->
		new RegExp "^(?:#{words.join "|"})$", "i"

	builtins = "+ − × ÷ ⋆ ○ ?∈ ⌈ ⌊ ⍴".split " "

	startState: ->
		indentStack: null
		indentation: 0
		mode: false

	token: (stream, state) ->
		style = state.cur stream, state
		word = stream.current()
		if builtins.test word
			style = "keyword"
		style

	indent: (state) ->
		state.indentStack.indentation

CodeMirror.defineMIME "text/x-apl", "apl"
