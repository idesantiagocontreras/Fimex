<div class="panel panel-primary">
    <!-- Default panel contents -->
    <div class="panel-heading">Captura de produccion almas</div>
    <div class="panel-body">
        <button class="btn btn-success" ng-show="mostrar" ng-click="addAlmasDetalle()">Agregar Produccion</button>
    </div>
    <div id="detalle" class="scrollable">
        <table ng-table class="table table-condensed table-striped table-bordered">
            <thead>
                <tr>
                    <th>Alma</th>
                    <?php if($IdSubProceso == 6):?>
                    <th class="col-md-1">MolXHrs</th>
                    <th class="col-md-1">PzaXMol</th>
                    <?php endif?>
                    <th class="col-md-2">Inicio</th>
                    <th class="col-md-2">Fin</th>
                    <th class="col-md-2">OK</th>
                    <th class="col-md-2">Rech</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr 
                    ng-class="{'info': indexAlmaDetalle == $index}"
                    ng-click="selectAlmasDetalle($index);"
                    ng-repeat="alma in almas">
                    <td class="col-md-3">{{alma.idProductos.Identificacion}}/{{alma.almasTipo.Descripcion}}</td>
                    <?php if($IdSubProceso == 6):?>
                    <td class="captura">{{alma.PiezasCaja}}</td>
                    <td class="captura">{{alma.PiezasMolde}}</td>
                    <?php endif?>
                    <td class="captura"><input ng-model-options="{updateOn: 'blur'}" placeholder="Inicio" ng-focus="selectAlmasDetalle({{$index}})" ng-change="saveAlmaDetalle({{$index}})" ng-model="alma.Inicio" value="{{alma.Inicio | date:'HH:mm'}}"/></td>
                    <td class="captura"><input ng-model-options="{updateOn: 'blur'}" placeholder="Fin" ng-focus="selectAlmasDetalle({{$index}})" ng-change="saveAlmaDetalle({{$index}})" ng-model="alma.Fin" value="{{alma.Fin | date:'HH:mm'}}"/></td>
                    <td class="captura"><input ng-model-options="{updateOn: 'blur'}" placeholder="OK" ng-change="saveAlmasDetalle({{$index}})" ng-model="alma.Hechas" value="{{alma.Hechas}}"/></td>
                    <td class="captura">{{alma.Rechazadas}}</td>
                    <td><button class="btn btn-danger" ng-click="deleteAlmaDetalle($index)">Eliminar</button></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>