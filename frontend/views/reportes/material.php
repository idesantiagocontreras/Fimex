<?php
use yii\helpers\Html;
use yii\helpers\URL;

/* @var $this yii\web\View */
/* @var $dataProvider yii\data\ActiveDataProvider */ 

if (isset($_GET['semana'])){
    $semana = $_GET['semana'];
    $cantidad = $_GET['cantidad'];
    $semana = explode('-W',$_GET['semana']);
    $semanas = $semana[1];
}  else {
    $semana = date("Y")."-W".date("W");
    $cantidad = 4;
    $semanas = date("W");
}
?>

<div style="margin-bottom: 10px">
    <input id="semana" type="week" value="<?= $semana ?>">
    <label>Semanas</label>
    <input id="cantidadS" class="easyui-textbox" style="width:80px">
    
    <a href="#" class="easyui-linkbutton" onclick="filtrar(this);" >Filtrar</a>
</div>

<div class="reporte-ete">
    <table style="width:100%" id="ff" class="table table-striped">
        <thead>
            <tr>
                <th>Aleacion</th>
                <th>Total Araña</th>
                <?php 
                for ($i = 0; $i < $cantidad; $i++){
                    $sem = $semanas + $i;
                    echo ' <th>Sem '.$sem.' </th>';
                }
                ?>
            </tr>
        </thead>
        <tbody> 
            <?php foreach($model as $detail): ?>
            <tr>
                <th><?= $detail['Aleacion'] ?> </th>  
                <th><?= $detail['PesoTot'] ?></th>
                <?php 
                for ($i = 0; $i < $cantidad; $i++){
                    $sem = $semanas + $i;
                    echo '<th> '.$detail[$sem].' </th>  ';
                }
                ?>
                
            </tr>
            <?php endforeach; ?>
        </tbody>
       
    </table>

</div>

<script>
    function filtrar(){
        var cantidad = $('#cantidadS').textbox('getValue');	// get datebox value
        var semana = $('#semana').val();	// get datebox value
        //var anio = $('#anio').val();    
        document.location = '/Fimex/reportes/material?cantidad='+cantidad+'&semana='+semana;
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