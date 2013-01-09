CodeMirror.defineMode "apl", (config, parserConfig) ->
	wordRE = (words) ->
		new RegExp "^(?:#{words.join "|"})$", "i"

	builtins = "+ − × ÷ ⋆ ○ ?∈ ⌈ ⌊ ⍴".split " "

	token: (stream, state) ->
		style = state.cur stream, state
		word = stream.current()
		if builtins.test word
			style = "keyword"
		style

CodeMirror.defineMIME "text/x-apl", "apl"
