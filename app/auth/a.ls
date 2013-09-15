app = angular.module 'recess.auth', []

app.config [
	'$routeProvider'
	'$httpProvider'

	($routeProvider, $httpProvider) ->
		$routeProvider.when '/auth/login', {
			templateUrl: '/partials/auth/login.html'
		}

		$httpProvider.interceptors.push 'AuthInterceptor'
]

app.run [
	'$rootScope'
	'$location'
	'AuthService'
	'$window'
	'$http'

	($rootScope, $location, AuthService, $window, $http) ->
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

			#console.log "Redirect to login from " + path
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
			$window.location.href = ""
]
