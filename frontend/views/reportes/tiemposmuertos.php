<?php

use yii\helpers\Html;
use yii\grid\GridView;

/* @var $this yii\web\View */
/* @var $dataProvider yii\data\ActiveDataProvider */
?>
<script>
function filtrar(){
    var ini = $('#fecha-ini').datebox('getValue');	// get datebox value
    var fin = $('#fecha-fin').datebox('getValue');	// get datebox value
    document.location = '/Fimex/reportes/tiemposmuertos?ini='+ini+'&fin='+fin;

}

   
</script>
<script type="text/javascript">
function myformatter(date){
    var y = date.getFullYear();
    var m = date.getMonth()+1;
    var d = date.getDate();
    return y+'-'+(m<10?('0'+m):m)+'-'+(d<10?('0'+d):d);
}
function myparser(s){
    if (!s) return new Date();
    var ss = (s.split('-'));
    var y = parseInt(ss[0],10);
    var m = parseInt(ss[1],10);
    var d = parseInt(ss[2],10);
    if (!isNaN(y) && !isNaN(m) && !isNaN(d)){
        return new Date(y,m-1,d);
    } else {
        return new Date();
    }
}
</script>

      <div style="margin-bottom: 10px">
        <input id="fecha-ini" class="easyui-datebox" style="width:200px" data-options="formatter:myformatter,parser:myparser" type="text" >
        <input id="fecha-fin" class="easyui-datebox" style="width:200px" data-options="formatter:myformatter,parser:myparser" >
        <a href="#" class="easyui-linkbutton" onclick="filtrar(this);" >Filtrar</a>
    </div>


<div class="reporte-tiemposmuertos">
    
    <table id="tiemposmuertos" class="easyui-datagrid datagrid-f" title="" style="height:600px" data-options="
    url:'/Fimex/reportes/tiemposmuertos',
    queryParams:{
        ini:'0', fin:'0'
    },
    singleSelect:false,
    method:'get',
    collapsible:true,
    remoteSort:false,
    multiSort:true,
    showFooter:true,
    loadMsg: 'Cargando datos',
    onClickRow: function(index){
        onClickRow(index);
    },
    toolbar: '#tbSemanal',
   ">
    <thead data-options="frozen:true,width:50">
        <tr>
            <th data-options="field:'IdTiempoMuerto',sortable:true,width:150">Id</th>
            <th data-options="field:'Fecha',sortable:true,width:150">Fecha</th>
            <th data-options="field:'Maquina',sortable:true,width:150">Maquina</th>
            <th data-options="field:'Descripcion',sortable:true,width:150">Descripcion</th>
            <th data-options="field:'Causa',sortable:true,width:150">Causa</th>
            <th data-options="field:'TipoCausa',sortable:true,width:150">Tipo Causa</th>
            <th data-options="field:'Inicio',sortable:true,width:150">Inicio</th>
            <th data-options="field:'Fin',sortable:true,width:150">Fin</th>
            <th data-options="field:'Minutos',sortable:true,width:150">Minutos</th>
        </tr>
    </thead>
    <tbody>
        <?php foreach($model as $detail): ?>
        <tr>
            <td><?=$detail['IdTiempoMuerto']?></td>
            <td><?=date('d-m-Y',strtotime($detail['Inicio']))?></td>
            <td><?=$detail['Maquina']?></td>
            <td><?=$detail['Descripcion']?></td>
            <td><?=$detail['Causa']?></td>
            <td><?=$detail['TipoCausa']?></td>
            <td><?=date('d-m-Y H:i:s',strtotime($detail['Inicio']))?></td>
            <td><?=date('d-m-Y H:i:s',strtotime($detail['Fin']))?></td>
            <td><?=number_format($detail['Minutos'], 0, '.', '');?></td>
        </tr>
        <?php endforeach; ?>
    </tbody>
    </table>

</div>
