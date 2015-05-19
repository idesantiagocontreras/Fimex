<?php

use yii\helpers\Html;
use yii\grid\GridView;

/* @var $this yii\web\View */
/* @var $dataProvider yii\data\ActiveDataProvider */

?>
<div class="reporte-moldeo">
    <table class="table table-striped">
        <tr>
            <th>Id</th>
            <th>Fecha</th>
            <th>Identificacion</th>
            <th>Descripcion</th>
            <th>Inicio</th>
            <th>Fin</th>
            <th>Buenas</th>
            <th>Rechazadas</th>
        </tr>
        <?php foreach($model as $detail): ?>
        <tr>
            <td><?=$detail['IdProduccionDetalle']?></td>
            <td><?=date('Y-m-d',strtotime($detail['idProduccion']['Fecha']))?></td>
            <td><?=$detail['idProductos']['Identificacion']?></td>
            <td><?=$detail['idProductos']['Descripcion']?></td>
            <td><?=date('H:i:s',strtotime($detail['Inicio']))?></td>
            <td><?=date('H:i:s',strtotime($detail['Fin']))?></td>
            <td><?=$detail['Hechas']?></td>
            <td><?=$detail['Rechazadas']?></td>
        </tr>
        <?php endforeach; ?>
    </table>
</div>

