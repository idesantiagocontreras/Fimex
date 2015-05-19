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
                <th ng-show="mostrar" style="max-width: 100px" rowspan="2">Orden<br /><input class="form-control" ng-model="filtro.orden" /></th>
                <th ng-show="mostrar" style="min-width: 200px" rowspan="2">Descripcion<br /><input class="form-control" ng-model="filtro.descripcion" /></th>
                <th ng-show="mostrar" style="max-width: 100px" rowspan="2">Embarque<br /><input class="form-control" ng-model="filtro.embarque" /></th>
                <th ng-show="mostrar" style="max-width: 100px" rowspan="2">Aleacion<br /><input class="form-control" ng-model="filtro.aleacion" /></th>
                <th ng-show="mostrar" style="max-width: 100px" rowspan="2">Cliente<br /><input class="form-control" ng-model="filtro.cliente" /></th>
                <th style="max-width: 100px" rowspan="2">Producto<br /><input class="form-control" ng-model="filtro.producto" /></th>
                <th style="max-width: 100px" rowspan="2">Casting<br /><input class="form-control" ng-model="filtro.casting" /></th>
                <th colspan="2">Pedido</th>
                <th <?= $colspan; ?>>Existencias Almacenes</th>
                <th colspan="2">Maquinado</th>
                <th colspan="2">Casting</th>
                <th colspan="2">Programacion</th>
                <th style="max-width: 100px" style="max-width: 100px" rowspan="2">Prog</th>
                <?php for($x=1;$x<=4;$x++):?>
                <th colspan="4">Semana {{semanas.semana<?=$x?>.week}},{{semanas.semana<?=$x?>.year}}</th>
                <?php endfor;?>
            </tr>
            <tr>
                <th style="max-width: 50px">Pzas</th>
                <th style="max-width: 50px">Mol</th>
            <?php if($area == 2){ ?>
                <th style="max-width: 50px" >PLA</th>
                <th style="max-width: 50px" >CTA</th>
                <th style="max-width: 50px" >PMA</th>
                <th style="max-width: 50px" >PTA</th>
                <th style="max-width: 50px" >TRA</th>
                <th style="max-width: 50px" >Exist</th>
                <th style="max-width: 50px" >Falta</th>
                <th style="max-width: 50px" >Exist</th>
                <th style="max-width: 50px" >Falta</th>
            <?php } ?>
            <?php if($area == 3){ ?>
                <th style="max-width: 50px" >PLB</th>
                <th style="max-width: 50px" >CTB</th>
                <th style="max-width: 50px" >PCC</th>
                <th style="max-width: 50px" >PMB</th>
                <th style="max-width: 50px" >PTB</th>
                <th style="max-width: 50px" >TRB</th>
                <th style="max-width: 50px" >Exist</th>
                <th style="max-width: 50px" >Falta</th>
                <th style="max-width: 50px" >Exist</th>
                <th style="max-width: 50px" >Falta</th>
            <?php } ?>
            <?php if($area == 4){ ?>
                <th style="max-width: 50px" >Term.</th>
                <th style="max-width: 50px" >Cast.</th>
                <th style="max-width: 50px" >Maq.</th>
                <th style="max-width: 50px" >GPT1</th>
                <th style="max-width: 50px" >GPP</th>
                <th style="max-width: 50px" >GPTA</th> 
                <th style="max-width: 50px" >GPC</th>
                <th style="max-width: 50px" >Exist</th>
                <th style="max-width: 50px" >Falta</th>
                <th style="max-width: 50px" >Exist</th>
                <th style="max-width: 50px" >Falta</th>
            <?php } ?>
                <th valign="middle">Pzas</th>
                <th>Mol</th>
                <?php for($x=1;$x<=4;$x++):?>
                <th ng-click="orden = '-Prioridad<?=$x?>'">Pr</th>
                <th ng-click="orden = '-Programadas<?=$x?>'">Prg</th>
                <th ng-click="orden = '-Hechas<?=$x?>'">H</th>
                <th ng-click="orden = '-Programadas<?=$x?>'">Hrs</th>
                <?php endfor;?>
            </tr>
        </thead>
        <tbody style="font-size: 10pt">
            <tr style="{{programacion.class}}" ng-repeat="programacion in programaciones | filter:{
                OrdenCompra:filtro.orden,
                Producto:filtro.producto,
                ProductoCasting:filtro.casting,
                Descripcion:filtro.descripcion,
                FechaEmbarque:filtro.embarque,
                Aleacion:filtro.aleacion,
                Marca:filtro.cliente,
            } | orderBy:orden" ng-click="setSelected(programacion);">
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.OrdenCompra}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.Descripcion}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.FechaEmbarque}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.Aleacion}}</td>
                <td ng-show="mostrar" style="max-width: 100px">{{programacion.Marca}}</td>
                <td style="max-width: 100px">{{programacion.Producto}}</td>
                <td style="max-width: 100px">{{programacion.ProductoCasting}}</td>
                <td style="max-width: 50px">{{programacion.SaldoCantidad}}</td>
                <td style="max-width: 50px">{{programacion.MoldesSaldo}}</td>
            <?php if($area == 3){ ?>
                <td style="max-width: 50px" class="info">{{programacion.PLB == 0 ? '' : programacion.PLB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.CTB == 0 ? '' : programacion.CTB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.PCC  == 0 ? '' :  programacion.PCC}}</td>
                <td style="max-width: 50px" class="info">{{programacion.PMB == 0 ? '' : programacion.PMB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.PTB == 0 ? '' : programacion.PTB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.TRB == 0 ? '' : programacion.TRB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.ExitPTB == 0 ? '' : programacion.ExitPTB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.FaltaPTB == 0 ? '' : programacion.FaltaPTB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.ExitCast == 0 ? '' : programacion.ExitCast}}</td>
                <td style="max-width: 50px" class="info">{{programacion.FaltaCast == 0 ? '' : programacion.FaltaCast}}</td>
            <?php } ?>
            <?php if($area == 4){ ?>
                <td style="max-width: 50px" class="info">{{programacion.GPT}}</td>
                <td style="max-width: 50px" class="info">{{programacion.GPCB}}</td>
                <td style="max-width: 50px" class="info">{{programacion.GPM}}</td>
                <td style="max-width: 50px" class="info">{{programacion.GPT1}}</td>
                <td style="max-width: 50px" class="info">{{programacion.GPP}}</td>
                <td style="max-width: 50px" class="info">{{programacion.GPTA}}</td>
                <td style="max-width: 50px" class="info">{{programacion.GPC}}</td>
                <td style="max-width: 50px" class="info">{{programacion.ExitGPT}}</td>
                <td style="max-width: 50px" class="info">{{programacion.FaltaGPT}}</td>
                <td style="max-width: 50px" class="info">{{programacion.ExitGPT}}</td>
                <td style="max-width: 50px" class="info">{{programacion.FaltaGPT}}</td>
            <?php } ?>
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
<div>
    <table class="table table-striped table-bordered table-hover">
        <thead>
            <tr>
                <th rowspan="2">Resumen</th>
                <?php for($x=1;$x<=4;$x++):?>
                <th colspan="4">Semana {{semanas.semana<?=$x?>.week}},{{semanas.semana<?=$x?>.year}}</th>
                <?php endfor;?>
            </tr>
            <tr>
                <?php for($x=1;$x<=4;$x++):?>
                <th>Mol</th>
                <th>Ton</th>
                <th>Ton P</th>
                <th>Hrs</th>
                <?php endfor;?>
                
            </tr>
        </thead>
        <tbody>
            <tr ng-repeat="resumen in resumenes">
                <th>{{resumen.Programadas}}</th>
                <?php for($x=1;$x<=4;$x++):?>
                <td>{{resumen.Prioridad<?=$x?> | currency:'':0}}</td>
                <td>{{resumen.Programadas<?=$x?> | currency:'':2}}</td>
                <td>{{resumen.Hechas<?=$x?> | currency:'':2}}</td>
                <td>{{resumen.Horas<?=$x?> | currency:'':2}}</td>
                <?php endfor;?>
            </tr>
        </tbody>
    </table>
</div>
