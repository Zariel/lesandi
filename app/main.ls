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
	'$httpProvider'

	($routeProvider, $locationProvider, $httpProvider) ->
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
			.when '/auth/login', {
				templateUrl: '/partials/auth/login.html'
			}

		$locationProvider.html5Mode true .hashPrefix '!'

		$httpProvider.interceptors.push 'AuthInterceptor'
]

app.run [
	'$rootScope'
	'$location'
	'AuthService'
	'$window'
	'$http'

	($rootScope, $location, AuthService, $window, $http, HeartBeat) ->
		$rootScope.reqs = []

		nextPath = "/"
		$rootScope.$on 'unauthorised-api', (event, { page }) ->
			return if page is '/auth/login'

			nextPath := page

			$location.path '/auth/login'

		$rootScope.$on '$routeChangeStart', (event, next, current) ->
			path = $location.path!

			return if path is '/404'
			return if AuthService.isLoggedIn!
			return if next?$$route?originalPath is '/auth/login'

			if current?$$route?originalPath is not '/auth/login'
				nextPath := path

			console.log "Redirect to login from " + path
			event.preventDefault!

			$location.path '/auth/login'

		$rootScope.$on 'authSuccess', (event, auth) ->
			#HeartBeat.start!

			for req in $rootScope.reqs
				$http req.config .then req.defer.resolve, req.defer.reject

			$rootScope.reqs = []
			if auth.isNew or $location.path! is not nextPath
				$location.path nextPath

		$rootScope.$on 'logout', (event) ->
			#HeartBeat.stop!
			# this causes a full reload, clearing state.
			$window.location.href = "/"
]

app.factory 'PageTitle', [
	'$rootScope'

	($rootScope) ->
		{
			setTitle: (title) ->
				$rootScope.pageTitle = title
		}
]

