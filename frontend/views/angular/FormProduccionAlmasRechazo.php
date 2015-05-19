<div class="panel panel-danger">
    <!-- Default panel contents -->
    <div class="panel-heading"><?=$titulo?></div>
    <div class="panel-body">
        <button class="btn btn-success" ng-show="mostrar" ng-click="addRechazo()">Agregar Defecto</button>
    </div>
    <div id="rechazo" class="scrollable">
        <table class="table table-condensed">
            <thead>
                <tr>
                    <th>Defecto</th>
                    <th>Cantidad</th>
                </tr>
            </thead>
            <tbody>
                <tr ng-repeat="rechazo in rechazosAlmas">
                    <th><select class="form-control" ng-model-options="{updateOn: 'blur'}" ng-change="saveRechazo({{$index}})" ng-model="rechazo.IdDefecto">
                        <option ng-selected="rechazo.IdDefecto == defecto.IdDefectoTipo" ng-repeat="defecto in defectos" value="{{defecto.IdDefectoTipo}}">{{defecto.NombreTipo}}</option>
                    </select></th>
                    <th><input class="form-control" type="number" ng-model-options="{updateOn: 'blur'}" ng-change="saveRechazo({{$index}})" ng-model="rechazo.Rechazadas" value="{{rechazo.Rechazadas}}"/></th>
                    <th><button class="btn btn-danger" ng-show="delete" ng-click="delRechazo({{$index}})">Eliminar</button></th>
                </tr>
            </tbody>
        </table>
    </div>
</div>