/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
app.controller('Programacion', function($scope, $filter, ngTableParams, $http){
    
    $scope.semanas = [];
    $scope.pedidos = [];
    $scope.programaciones = [];
    $scope.resumenes = [];
    $scope.maquinas = [];
    $scope.clientes = [];
    $scope.selectedPedido = [];
    $scope.semanaActual = new Date();
    
    $scope.mostrar = true;
    $scope.mostrarPedido = false;
    
    $scope.IdSubProceso = 6;
    $scope.mostrarPedidos = false;
    $scope.selected = null;
    
    $scope.setSelected = function(item) {
        $scope.selected = item;
    };
    
    $scope.setSelectPedido = function(item) {
        item.checked = !item.checked;
        console.log(item);
    };
    
    $scope.allSelectPedido = function(item) {
        $scope.pedidos.forEach(function(item){
            item.checked = true;
        });
    };
    
    $scope.deSelectPedido = function(item) {
        $scope.pedidos.forEach(function(item){
            item.checked = false;
        });
    };

    $scope.loadMaquinas = function(){
        return $http.get('/fimex/angular/maquinas',{params:{IdSubProceso:$scope.IdSubProceso}}).success(function(data) {
            $scope.maquinas = data;
        });
    };
    
    $scope.loadMarcas = function(){
        return $http.get('marcas').success(function(data) {
            $scope.clientes = [];
            $scope.clientes = data;
        });
    };
    
    $scope.savePedidos = function(){
        $scope.pedidos.forEach(function(item){
            if(item.checked)
                $scope.selectedPedido.push(item.IdPedido);
        });
        
        return $http.get('save-pedidos',{params:$scope.selectedPedido}).success(function(data) {
            $scope.loadSemanas();
        });
    };
    
    $scope.loadSemanas = function(){
        return $http.get('load-semana',{params:{semana1:$scope.semanaActual,}}).success(function(data){
            $scope.semanas = [];
            $scope.semanas = data;
            $scope.semanaActual = $scope.semanas.semana1.val;
            $scope.loadMarcas();
            $scope.loadPedidos();
            $scope.loadProgramacionSemanal();
        });
    }
    
    $scope.loadDias = function(){
        return $http.get('load-dias',{params:{semana:$scope.semanaActual,}}).success(function(data){
            $scope.dias = [];
            $scope.dias = data;
            $scope.loadProgramacionDiaria();
            $scope.loadMaquinas();
        });
    }
    
    $scope.loadPedidos = function(){
        return $http.get('pedidos').success(function(data){
            $scope.pedidos = [];
            $scope.pedidos = data.rows;
        });
    }
    
    $scope.loadProgramacionSemanal = function(){
        return $http.get('data-semanal',{params:{semana1:$scope.semanaActual,}}).success(function(data){
            $scope.programaciones = [];
            $scope.programaciones = data.rows;
            $scope.resumenes = data.footer;
            $scope.tableParams.reload();
        });
    };
    
    $scope.tableParams = new ngTableParams({
                page: 1,            // show first page
                count: 10           // count per page
    }, {
        total: $scope.programaciones.length, // length of data
        getData: function($defer, params) {
            console.log($scope.programaciones);
            // use build-in angular filter
            var orderedData = params.sorting() ?
                    $filter('orderBy')($scope.programaciones, params.orderBy()) :
                    $scope.programaciones;

            $defer.resolve(orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count()));
        }
    });
    
    $scope.saveProgramacionSemanal = function(){
        return $http.get('save-semanal',{params:$scope.selected}).success(function(data){
            $scope.loadProgramacionSemanal();
        });
    }
    
    $scope.loadProgramacionDiaria = function(){
        return $http.get('data-diaria',{params:{semana:$scope.semanaActual,}}).success(function(data){
            $scope.programaciones = [];
            $scope.programaciones = data.rows;
            $scope.resumenes = data.footer;
        });
    };
    
    $scope.saveProgramacionDiaria = function(){
        return $http.get('save-diario',{params:$scope.selected}).success(function(data){
            if(data == true){
                $scope.loadProgramacionDiaria();
            }
        });
    }
});