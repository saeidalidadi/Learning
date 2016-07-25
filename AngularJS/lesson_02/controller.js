(function(){
  var app = angular.module('helloAngular', []);

  app.controller('helloController', function($scope){
    $scope.name = '';
   
    $scope.$watch("name", function(oldVal, newVal){
      if ( $scope.name.length > 0 ) {
        $scope.typing = true;
        //$scope.greeting = 'Hello ' + $scope.name + ' from angular';
      }
      else
        $scope.typing = false;
    });
  });
})()
