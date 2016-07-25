random  = (amount, excludes, cb) ->
	rands = []
	while amount > 0
		amount--
		rand = Math.floor Math.random() * (excludes[1] - excludes[0])
		for num in rands
			if num is rand
				continue
			else
				rands.push(rand)
				break

	cb(rands)

randoms = random 5, [5, 10], (result) ->
	console.log result
