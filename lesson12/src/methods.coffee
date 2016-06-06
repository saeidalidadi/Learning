model = require "./model"

internals =
	countPagination: (next) ->
		model.countPosts (total) ->
			if total % 5 is 0 and total >= 5
				paginations = total // 5
			else if total > 5
				paginations = (total // 5) + 1
			next(null, paginations)


module.exports = methodsList = [
	{
		name: 'countPagination'
		method: internals.countPagination
		options: {}
	}
]



