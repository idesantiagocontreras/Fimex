app.controller('Produccion', function($scope, $filter, $http){
    $scope.Fecha = new Date();
    
    $scope.producciones = [{
        Fecha: new Date(),
        IdArea: null,
        IdCentroTrabajo:null,
        IdEmpleado:null,
        IdMaquina:null,
        IdProduccion:null,
        IdProduccionEstatus:null,
        IdSubProceso:null,
    }];
    $scope.aleaciones = [];
    $scope.maquinas = [];
    $scope.empleados = [];
    $scope.defectos = [];
    $scope.fallas = [];
    $scope.materiales = [];
    
    //Catalogos para las Capturas
    
    $scope.programaciones = [];
    $scope.detalles = [];
    $scope.rechazos = [];
    $scope.consumos = [];
    $scope.TiemposMuertos = [];
    $scope.temperaturas = [];
    
    $scope.mostrar = false;
    $scope.delete = false;
    $scope.newLance = true;
    
    $scope.index = 0;
    $scope.indexProgramacion = null;
    $scope.indexDetalle = null;
    $scope.indexMaquina = null;
    
    $scope.aleacionSelect = null;
    $scope.maquinaSelect = null;
    
    $scope.Prev = function(){
        if($scope.index > 0 ){
            $scope.index -= 1;
        }
        $scope.show();
        console.log($scope.index);
    };
    
    $scope.Next = function(){
        if($scope.index < $scope.producciones.length-1  ){
            $scope.index += 1;
        }
        $scope.show();
        console.log($scope.index);
    };
    
    $scope.First = function(){
        $scope.index = 0
        $scope.show();
        console.log($scope.index);
    };
    
    $scope.Last = function(){
        $scope.index = $scope.producciones.length - 1;
        $scope.show();
        console.log($scope.index);
    };
    
    $scope.show = function(){
        if($scope.producciones[$scope.index].IdProduccionEstatus != 1){
            $scope.mostrar = false;
        }else{
            $scope.mostrar = true;
        }
        $scope.loadData();
    }
    
    $scope.loadData = function(){
        $scope.maquinas.forEach(function(value, key) {
            console.log($scope.producciones[$scope.index].IdMaquina);
            if(value.IdMaquina == $scope.producciones[$scope.index].IdMaquina){
                $scope.indexMaquina = key;
            }
        });
        console.log($scope.maquinas);
        $scope.loadDetalle();
        $scope.loadConsumo();
        $scope.loadTemperaturas();
        $scope.loadTiempos();
    }

    $scope.loadEmpleados = function(depto){
        return $http.get('empleados',{params:{depto:depto}}).success(function(data) {
            $scope.empleados = data;
        });
    };
    
    $scope.loadMaquinas = function(){
        return $http.get('maquinas',{params:{IdSubProceso:$scope.producciones[0].IdSubProceso}}).success(function(data) {
            $scope.maquinas = data;
        });
    };
    
    $scope.loadAleaciones = function(){
        return $http.get('aleaciones',{params:$scope.producciones[$scope.index]}).success(function(data) {
            $scope.aleaciones = data;
        });
    };
    
    $scope.selectMaquina = function(index){
        $scope.maquinas.forEach(function(value, key) {
            if(value.IdMaquina == $scope.producciones[$scope.index].IdMaquina){
                return $scope.indexMaquina = key;
            }
        });
    }
    
    /********************************************************************
     *                        ENCABEZADO DE PRODUCCION
     *******************************************************************/

    $scope.loadProduccion = function(){
        return $http.get('produccion',{params:$scope.producciones[0]}).success(function(data) {
            $scope.mostrar = false;
            if(data.length > 0 ){
                $scope.producciones = [];
                $scope.producciones = data;
                $scope.Last();
            }
        });
        console.log($scope.producciones);
    };
    
    $scope.addProduccion = function(){
        $scope.inserted = {
            IdProduccion:null,
            Fecha: $scope.producciones[$scope.index].Fecha,
            IdArea: $scope.producciones[$scope.index].IdArea,
            IdCentroTrabajo:null,
            IdEmpleado:null,
            IdMaquina:null,
            IdProduccionEstatus:1,
            IdSubProceso:$scope.producciones[$scope.index].IdSubProceso,
        };
        $scope.producciones.push($scope.inserted);
        $scope.Last();
    };
    
    $scope.saveProduccion = function (){
        return $http.get('save-produccion',{params:$scope.producciones[$scope.index]}).success(function(data) {
            $scope.producciones[$scope.index] = data;
        });
    };
    
    /********************************************************************
     *                        DETALLE DE PRODUCCION
     *******************************************************************/
    
    $scope.loadDetalle = function(){
        return $http.get('detalle',{params:{
                IdProduccion: $scope.producciones[$scope.index].IdProduccion,
            }}).success(function(data) {
            $scope.detalles = [];
            $scope.detalles = data;
        });
    };
    
    $scope.addDetalle = function() {
        console.log($scope.indexMaquina);
        console.log($scope.maquinas[$scope.indexMaquina]);
        console.log($scope.producciones[$scope.index]);
        if($scope.producciones[$scope.index].IdProduccion != null){
            $scope.inserted = {
                Fecha: $scope.producciones[$scope.index].Fecha,
                IdProduccionDetalle: null,
                IdProduccion:$scope.producciones[$scope.index].IdProduccion,
                IdProgramacion:$scope.programaciones[$scope.indexProgramacion].IdProgramacion,
                IdProductos:$scope.programaciones[$scope.indexProgramacion].IdProductoCasting,
                Inicio:null,
                Fin:null,
                CiclosMolde: $scope.programaciones[$scope.indexProgramacion].CiclosMolde,
                PiezasMolde: $scope.programaciones[$scope.indexProgramacion].PiezasMolde,
                Programadas: $scope.programaciones[$scope.indexProgramacion].Programadas,
                Hechas: 0,
                Rechazadas: 0,
                Eficiencia: $scope.maquinas[$scope.indexMaquina].Eficiencia,
                idProductos: {Identificacion:$scope.programaciones[$scope.indexProgramacion].ProductoCasting},
            };
            $scope.detalles.push($scope.inserted);
            $scope.saveDetalle($scope.detalles.length - 1);
        }
    };
    
    $scope.saveDetalle = function(index){
        $scope.detalles[index].Fecha = $scope.producciones[$scope.index].Fecha;
        if($scope.detalles[index].Incio != '00:00' && $scope.detalles[index].Fin != '00:00'){
            return $http.get('save-detalle',{params:$scope.detalles[index]}).success(function(data) {
                $scope.detalles[index] = data;
                $scope.loadProgramacion();
            });
        }
    };
    
    $scope.deleteDetalle = function(index){
        var dat = $scope.detalles[index];
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('delete-detalle',{params:dat}).success(function(data) {
            $scope.loadDetalle();
        });
    };
    
    $scope.selectDetalle = function(index){
        console.log(index);
        console.log($scope.indexDetalle);
        if($scope.indexDetalle != null){
            $scope.detalles[$scope.indexDetalle].Class = "";
            $scope.indexDetalle = null;
        }
        $scope.indexDetalle = index;
        $scope.detalles[$scope.indexDetalle].Class = "info";
        $scope.loadRechazos();
    }

    /********************************************************************
     *                        PROGRAMACION
     *******************************************************************/
    $scope.loadProgramacion = function(){
        console.log($scope.producciones);
        return $http.get('programacion',{params:{
                Dia: $scope.Fecha,
                IdArea: $scope.producciones[$scope.index].IdArea,
                IdSubProceso: $scope.producciones[$scope.index].IdSubProceso,
                IdMaquina: $scope.producciones[$scope.index].IdMaquina,
            }}).success(function(data) {
            $scope.programaciones = [];
            $scope.programaciones = data;
        });
    };
    
    $scope.actualizarProgramacion = function(){
        return $http.get('save-programacion',{
            params:$scope.programaciones[$scope.indexProgramacion]
        }).success(function(data) {
            $scope.loadProgramacion();
        });
    };
    
    $scope.selectProgramacion = function(index){
        if($scope.indexProgramacion != null){
            $scope.indexProgramacion = null;
        }
        $scope.indexProgramacion = index;
    }
    
    /********************************************************************
     *                        CONTROL DE RECHAZO
     *******************************************************************/
    
    $scope.loadDefectos = function(){
        return $http.get('defectos',{params:{
                IdSubProceso: $scope.producciones[$scope.index].IdSubProceso,
            }}).success(function(data) {
            $scope.defectos = [];
            $scope.defectos = data;
        });
    };
    
    $scope.loadRechazos = function(){
        return $http.get('rechazos',{params:{
                IdProduccionDetalle: $scope.detalles[$scope.indexDetalle].IdProduccionDetalle,
            }}).success(function(data) {
            $scope.rechazos = [];
            $scope.rechazos = data;
            console.log($scope.rechazos);
        });
    };
    
    $scope.addRechazo = function(){
        console.log($scope.indexDetalle);
        if($scope.indexDetalle != null){
            $scope.inserted = {
                IdProduccionDefecto: null,
                IdProduccionDetalle: $scope.detalles[$scope.indexDetalle].IdProduccionDetalle,
                IdDefecto:null,
                Rechazadas:0
            };
            $scope.rechazos.push($scope.inserted);
        }
    };
    
    $scope.delRechazo = function(index){
        console.log($scope.indexDetalle);
        return $http.get('del-rechazo',{params:$scope.rechazos[index].IdProduccionDefecto}).success(function(data) {
            $scope.loadRechazos();
        });
    };
    
    $scope.saveRechazo = function(index){
        return $http.get('save-rechazo',{params:$scope.rechazos[index]}).success(function(data) {
            $scope.rechazos[index] = data;
            $scope.loadDetalle();
        });
    };
    /********************************************************************
     *                        CONTROL DE FALLAS
     *******************************************************************/
    
    $scope.loadFallas = function(){
        return $http.get('fallas',{params:{
                IdSubProceso: $scope.producciones[$scope.index].IdSubProceso,
            }}).success(function(data) {
            $scope.fallas = [];
            $scope.fallas = data;
        });
    };
    
    $scope.loadTiempos = function(){
        return $http.get('tiempos',{params:{
                IdMaquina: $scope.producciones[$scope.index].IdMaquina,
                Fecha: $scope.producciones[$scope.index].Fecha,
            }}).success(function(data) {
            $scope.TiemposMuertos = [];
            $scope.TiemposMuertos = data;
        });
    };
    
    $scope.deleteTiempo = function(index){
        var dat = $scope.TiemposMuertos[index];
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('delete-tiempo',{params:dat}).success(function(data) {
            $scope.TiemposMuertos = data;
            $scope.loadTiempos();
        });
    };
    
    $scope.addTiempo = function() {
        if($scope.producciones[$scope.index].IdProduccion != null){
            $scope.inserted = {
                IdTiempoMuerto: null,
                IdMaquina: $scope.producciones[$scope.index].IdMaquina,
                Fecha: $scope.producciones[$scope.index].Fecha,
                IdCausa: null,
                Inicio:'00:00:00',
                Fin:'00:00:00',
                Descripcion:'',
            };
            $scope.TiemposMuertos.push($scope.inserted);
        }
    };
    
    $scope.saveTiempo = function(index){
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        if($scope.TiemposMuertos[index].Incio != '00:00' && $scope.TiemposMuertos[index].Fin != '00:00' && $scope.TiemposMuertos[index].IdCausa != null){
            return $http.get('save-tiempo',{params:$scope.TiemposMuertos[index]}).success(function(data) {
                $scope.loadTiempos();
            });
        }   
    };
    
    /********************************************************************
     *                        CONTROL DE CONSUMOS
     *******************************************************************/
    
    $scope.loadMaterial = function(){
        return $http.get('material',{params:{
                IdSubProceso: $scope.producciones[$scope.index].IdSubProceso,
            }}).success(function(data) {
            $scope.materiales = [];
            $scope.materiales = data;
        });
    };
    
    $scope.loadConsumo = function(){
        return $http.get('consumo',{params:{
                IdProduccion: $scope.producciones[$scope.index].IdProduccion,
            }}).success(function(data) {
            $scope.consumos = [];
            $scope.consumos = data;
        });
    };
    
    $scope.deleteConsumo = function(index){
        var dat = $scope.detalles[index];
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('delete-consumo',{params:dat}).success(function(data) {
            $scope.consumos = data;
        });
    };
    
    $scope.addConsumo = function() {
        if($scope.producciones[$scope.index].IdProduccion != null){
            $scope.inserted = {
                IdMaterialVaciado: null,
                IdProduccion: $scope.producciones[$scope.index].IdProduccion,
                IdMaterial: null,
                Cantidad: 0,
            };
            $scope.consumos.push($scope.inserted);
        }
    };
    
    $scope.saveConsumo = function(index){
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('save-consumo',{params:$scope.consumos[index]}).success(function(data) {
            $scope.loadConsumo();
        });
    };
    
    /********************************************************************
     *                        CONTROL DE TEMPERATURAS
     *******************************************************************/
    
    $scope.loadTemperaturas = function(){
        return $http.get('temperaturas',{params:{
                IdProduccion: $scope.producciones[$scope.index].IdProduccion,
            }}).success(function(data) {
            $scope.temperaturas = [];
            $scope.temperaturas = data;
        });
    };
    
    $scope.deleteTemperatura = function(index){
        var dat = $scope.detalles[index];
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('delete-temperatura',{params:dat}).success(function(data) {
            $scope.temperaturas = data;
        });
    };
    
    $scope.addTemperatura = function() {
        if($scope.producciones[$scope.index].IdProduccion != null){
            $scope.inserted = {
                IdTemperatura: null,
                IdProduccion: $scope.producciones[$scope.index].IdProduccion,
                IdMaquina: null,
                Fecha: $scope.producciones[$scope.index].Fecha,
                Temperatura: 0,
                Temperatura2: 0,
            };
            $scope.temperaturas.push($scope.inserted);
        }
    };
    
    $scope.saveTemperatura = function(index){
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('save-temperatura',{params:$scope.temperaturas[index]}).success(function(data) {
            $scope.loadConsumo();
        });
    };
    
    /********************************************************************
     *                        DETALLE DE PRODUCCION ALMAS
     *******************************************************************/
    
    $scope.loadAlmasDetalle = function(){
        return $http.get('almas-detalle',{params:{
                IdProduccion: $scope.producciones[$scope.index].IdProduccion,
            }}).success(function(data) {
            $scope.detalles = [];
            $scope.detalles = data;
        });
    };
    
    $scope.addAlmasDetalle = function() {
        if($scope.producciones[$scope.index].IdProduccion != null){
            $scope.inserted = {
                Fecha: $scope.producciones[$scope.index].Fecha,
                IdAlmaProduccion: null,
                IdProduccion:$scope.producciones[$scope.index].IdProduccion,
                IdProgramacionAlma:$scope.programaciones[$scope.indexProgramacion].IdProgramacion,
                IdAlma:$scope.programaciones[$scope.indexProgramacion].IdAlma,
                IdProductos:$scope.programaciones[$scope.indexProgramacion].IdProductoCasting,
                Inicio:null,
                Fin:null,
                CiclosMolde: $scope.programaciones[$scope.indexProgramacion].PiezasCaja,
                PiezasMolde: $scope.programaciones[$scope.indexProgramacion].PiezasMolde,
                Programadas: $scope.programaciones[$scope.indexProgramacion].Programadas,
                Hechas: 0,
                Rechazadas: 0,
                Eficiencia: $scope.maquinas[$scope.indexMaquina].Eficiencia,
                idProductos: {Identificacion:$scope.programaciones[$scope.indexProgramacion].ProductoCasting},
            };
            $scope.detalles.push($scope.inserted);
            $scope.saveDetalle($scope.detalles.length - 1);
        }
    };
    
    $scope.saveAlmasDetalle = function(index){
        $scope.detalles[index].Fecha = $scope.producciones[$scope.index].Fecha;
        if($scope.detalles[index].Incio != '00:00' && $scope.detalles[index].Fin != '00:00'){
            return $http.get('save-detalle',{params:$scope.detalles[index]}).success(function(data) {
                $scope.detalles[index] = data;
                $scope.loadProgramacion();
            });
        }
    };
    
    $scope.deleteAlmasDetalle = function(index){
        var dat = $scope.detalles[index];
        //$scope.detalles[index].IdProduccionDetalle = parseInt($scope.detalles[index].IdProduccionDetalle);
        return $http.get('delete-alma-detalle',{params:dat}).success(function(data) {
            $scope.loadDetalle();
        });
    };
    
    $scope.selectAlmasDetalle = function(index){
        console.log(index);
        console.log($scope.indexDetalle);
        if($scope.indexAlmaDetalle != null){
            $scope.detalles[$scope.indexDetalle].Class = "";
            $scope.indexDetalle = null;
        }
        $scope.indexDetalle = index;
        $scope.detalles[$scope.indexDetalle].Class = "info";
        $scope.loadRechazos();
    }
    
    /********************************************************************
     *                        CONTROL DE RECHAZO ALMAS
     *******************************************************************/
    
    $scope.loadAlmasDefectos = function(){
        return $http.get('almas-defectos',{params:{
                IdSubProceso: $scope.producciones[$scope.index].IdSubProceso,
            }}).success(function(data) {
            $scope.defectos = [];
            $scope.defectos = data;
        });
    };
    
    $scope.loadAlmasRechazos = function(){
        return $http.get('almas-rechazos',{params:{
                IdProduccionDetalle: $scope.detalles[$scope.indexDetalle].IdProduccionDetalle,
            }}).success(function(data) {
            $scope.rechazosAlmas = [];
            $scope.rechazosAlmas = data;
            console.log($scope.rechazosAlmas);
        });
    };
    
    $scope.addAlmasRechazo = function(){
        console.log($scope.indexDetalle);
        if($scope.indexDetalle != null){
            $scope.inserted = {
                IdAlmaProduccionDefecto: null,
                IdAlmaProduccionDetalle: $scope.detalles[$scope.indexDetalle].IdProduccionDetalle,
                IdDefecto:null,
                Rechazadas:0
            };
            $scope.rechazosAlmas.push($scope.inserted);
        }
    };
    
    $scope.delAlmaRechazo = function(index){
        console.log($scope.indexAlmaDetalle);
        return $http.get('del-alma-rechazo',{params:$scope.rechazosAlmas[index].IdProduccionDefecto}).success(function(data) {
            $scope.loadAlmasRechazos();
        });
    };
    
    $scope.saveAlmaRechazo = function(index){
        return $http.get('save-alma-rechazo',{params:$scope.rechazosAlmas[index]}).success(function(data) {
            $scope.rechazosAlmas[index] = data;
            $scope.loadAlmaDetalle();
        });
    };
});