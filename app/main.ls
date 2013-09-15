app = angular.module 'recess', [
	'ngResource'
	'ngRoute'
	'ngSanitize'

	'indexdb'
	'infinite-scroll'

	'recess.feeds'
	'recess.controls'
	'recess.auth'
]

app.config [
	'$routeProvider'
	'$locationProvider'

	($routeProvider, $locationProvider) ->
		$routeProvider
			.when '/', {
				controller: 'FeedController'
				templateUrl: '/partials/feeds/feeds.html'
				resolve: {
					feed: [
						'$q'
						'Feed'

						($q, Feed) ->
							defer = $q.defer!

							Feed.query { from: 0, count: 25 }, defer.resolve, defer.reject

							defer.promise
					]
				}
				reloadOnSearch: false
			}

		$locationProvider.html5Mode true .hashPrefix '!'

]

app.factory 'PageTitle', [
	'$rootScope'

	($rootScope) ->
		{
			setTitle: (title) ->
				$rootScope.pageTitle = title
		}
]

