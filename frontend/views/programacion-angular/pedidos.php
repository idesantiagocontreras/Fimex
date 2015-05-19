<?php

use yii\helpers\Html;
use yii\helpers\URL;
?>
<button class="btn btn-success" ng-click="savePedidos();">Agregar Pedidos</button>
<button class="btn btn-success" ng-show="selectAll" ng-click="allSelectPedido();selectAll=false;">Marcar todos</button>
<button class="btn btn-success" ng-show="!selectAll" ng-click="deSelectPedido();selectAll=true;">Desmarcar todos</button>
<button class="btn btn-primary" ng-show="mostrarPedido" ng-click="mostrarPedido = false">Ocultar Pedidos</button>
<div id="pedidos" class="scrollable">
    <table ng-table show-filter="true" fixed-table-headers="pedidos"  class="table table-striped table-bordered table-hover">
        <thead>
            <th>Orden<br /><input class="form-control" ng-model="filtro.Orden"></th>
            <th>Producto<br /><input class="form-control" ng-model="filtro.Producto"></th>
            <th>Casting<br /><input class="form-control" ng-model="filtro.Casting"></th>
            <th>Descripcion<input class="form-control" ng-model="filtro.Descripcion"></th>
            <th>Embarque<input class="form-control" ng-model="filtro.Embarque"></th>
            <th>Aleacion<input class="form-control" ng-model="filtro.Aleacion"></th>
            <th>
                Cliente
                <select class="form-control" ng-model="filtro.Cliente">
                    <option value="">Todos</option>
                    <option ng-repeat="cliente in clientes" value="{{cliente.value}}">{{cliente.text}}</option>
                </select>
            </th>
            <th>Cantidad<input class="form-control" ng-model="filtro.Cantidad"></th>
        </thead>
        <tbody>
            <tr ng-class="{'info' : pedido.checked}" ng-repeat="pedido in pedidos | filter:{
                OrdenCompra:filtro.Orden,
                Identificacion:filtro.Producto,
                ProductoCasting:filtro.Casting,
                Producto:filtro.Descripcion,
                FechaEmbarque:filtro.Embarque,
                Aleacion:filtro.Aleacion,
                Marca:filtro.Cliente,
                Cantidad:filtro.Cantidad,
            }" ng-click="setSelectPedido(pedido)">
                <td>{{pedido.OrdenCompra}}</td>
                <td>{{pedido.Identificacion}}</td>
                <td>{{pedido.ProductoCasting}}</td>
                <td>{{pedido.Producto}}</td>
                <td>{{pedido.FechaEmbarque}}</td>
                <td>{{pedido.Aleacion}}</td>
                <td>{{pedido.Marca}}</td>
                <td>{{pedido.Cantidad | number:0}}</td>
            </tr>
        </tbody>
    </table>
</div>