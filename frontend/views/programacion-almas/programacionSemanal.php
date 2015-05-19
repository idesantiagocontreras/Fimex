  <?php

use yii\helpers\Html;
use yii\helpers\URL;

$area = Yii::$app->session->get('area');
$area = $area['IdArea'];
$fiel = 'ExitPTB'; $colspan = 'colspan="5"';
if($area == 4){ 
    $fiel = 'ExitGPT'; $colspan = 'colspan="7"'; 
}elseif($area == 3){  
    $fiel = 'ExitPTB'; $colspan = 'colspan="6"';}
?>
<input type="week" ng-model="semanaActual" ng-change="loadSemanas();" />
<button class="btn btn-success" ng-click="loadProgramacionSemanal();">Actualizar</button>
<button class="btn btn-primary" ng-show="!mostrar" ng-click="mostrar = true">Mostrar Datos</button>
<button class="btn btn-primary" ng-show="mostrar" ng-click="mostrar = false">Ocultar Datos</button>
<button class="btn btn-primary" ng-show="!mostrarPedido" ng-click="mostrarPedido = true">Mostrar Pedidos</button>
<div class="panel panel-default">
    <div class="panel-body">
    </div>
    <div id="semanal" class="scrollable">
    <table ng-table fixed-table-headers="semanal" class="table table-striped table-bordered table-hover">
        <thead>
            <tr>
                <th ng-show="mostrar" style="max-width: 100px">Orden<br /><input class="form-control" ng-model="filtro.orden" /></th>
                <?php for($x=1;$x<=4;$x++):?>
                <th colspan="4">Semana {{semanas.semana<?=$x?>.week}},{{semanas.semana<?=$x?>.year}}</th>
                <?php endfor;?>
            </tr>
        </thead>
        <tbody style="font-size: 10pt">
            <tr style="{{programacion.class}}" ng-repeat="programacion in programaciones" ng-click="setSelected(programacion);">
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.OrdenCompra}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.Descripcion}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.FechaEmbarque}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.Aleacion}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.Marca}}</td>
                <td style="max-width: 100px">{{programacion.Producto}}</td>
                <td style="max-width: 100px">{{programacion.ProductoCasting}}</td>
                <td style="max-width: 50px">{{programacion.SaldoCantidad}}</td>
                <td style="max-width: 50px">{{programacion.MoldesSaldo}}</td>
                <td class="active"><input style="width: 50px;" ng-model="programado"></td>
                <td class="active">{{programado / programacion.PiezasMolde | number:0}}</td>
                <td class="active">{{programacion.Programadas == 0 ? '' : programacion.Programadas * programacion.PiezasMolde}}</td>
                <?php for($x=1;$x<=4;$x++): ?>
                <td><input style="width: 50px;" ng-model-options="{updateOn: 'blur'}" ng-change="saveProgramacionSemanal();" ng-model="programacion.Prioridad<?=$x?>" value="{{programacion.Prioridad<?=$x?>}}"></td>
                <td><input style="width: 50px;" ng-model-options="{updateOn: 'blur'}" ng-change="saveProgramacionSemanal();" ng-model="programacion.Programadas<?=$x?>" value="{{programacion.Programadas<?=$x?>}}"></td>
                <td>{{programacion.Hechas<?=$x?>}}</td>
                <td>{{(programacion.Programadas<?=$x?> / programacion.MoldesHora) | number : 1}}</td>
                <?php endfor; ?>
            </tr>
        </tbody>
    </table>
    </div>
</div>
