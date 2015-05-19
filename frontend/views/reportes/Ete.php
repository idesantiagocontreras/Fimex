<?php

use yii\helpers\Html;
use yii\grid\GridView;
use yii\widgets\ActiveForm;
use yii\helpers\ArrayHelper;
use yii\helpers\URL;

/* @var $this yii\web\View */
/* @var $dataProvider yii\data\ActiveDataProvider */
?>
   
<div style="margin-bottom: 20px" >
    <form id="form_ete" class="easyui-form" method="get">
        <input id="fecha_ini" value="<?php if(isset($_GET['ini'])) echo $_GET['ini']; ?>" class="easyui-datebox" style="width:200px" data-options="formatter:myformatter,parser:myparser" type="text" >
        <input id="fecha_fin" value="<?php if(isset($_GET['fin'])) echo $_GET['fin']; ?>" class="easyui-datebox" style="width:200px" data-options="formatter:myformatter,parser:myparser" >
        <input width="20" id="maquina" class="easyui-combobox" 
                        data-options="
                            url:'/Fimex/reportes/maquinas',
                            method:'get',
                            valueField:'IdMaquina',
                            textField:'Identificador',
                            panelHeight:'100',  
                        ">
        <a href="#" class="easyui-linkbutton" onclick="Filtrar();" >Filtrar</a>
    </form>
</div>
<div class="reporte-ete">
    <table id="ff" class="table table-striped">
        <thead>
            <tr>
                <th>Fecha</th>
                <th>No. Parte</th>
                <th>Inicio</th>
                <th>Fin</th>
                <th>T Tot</th>
                <th>T Disp</th>
                <th>SU</th>
                <th>MC</th>
                <th>MP</th>
                <th>TT</th>
                <th>MI</th>
                <th>MPRO</th>
                <th>DISPO</th>
                <th>P Esp</th>
                <th>P Real</th>
                <th>EFIC</th>
                <th>Rec</th>
                <th>OK</th>
                <th>CAL</th>
                <th>ETE</th>
            </tr>
        </thead>
        <tbody> 
            <?php foreach($model as $detail): ?>
            <tr>
                <th><?=date('Y-m-d',strtotime($detail['Inicio']))?></th>
                <th><?=$detail['Identificacion']?></th>
                <th><?=date('H:i',strtotime($detail['Inicio']))?></th>
                <th><?=date('H:i',strtotime($detail['Fin']))?></th>
                <th><?=$detail['TTOT']?></th>
                <th><?=$detail['TDISPO']?></th>
                <th><?php if(isset($detail['Causa2'])) echo $detail['Causa2']; else echo 0 ?></th>
                <th><?php if(isset($detail['Causa3'])) echo $detail['Causa3']; else echo 0; ?></th>
                <th><?php if(isset($detail['Causa4'])) echo $detail['Causa4']; else echo 0; ?></th>
                <th><?php if(isset($detail['Causa5'])) echo $detail['Causa5']; else echo 0; ?></th>
                <th><?php if(isset($detail['Causa6'])) echo $detail['Causa6']; else echo 0; ?></th>
                <th><?php if(isset($detail['Causa7'])) echo $detail['Causa7']; else echo 0; ?></th>
                <th><?=round($detail['DISPO'])."%"?></th>
                <th><?=number_format($detail['PESPERADO'])?></th>
                <th><?=number_format($detail['PREAL'])?></th>
                <th><?=round($detail['EFICIENCIA'])."%"?></th>
                <th><?=$detail['Rechazadas']?></th>
                <th><?=$detail['OK']?></th>
                <th><?=round($detail['CALIDAD'],2)."%"?></th>
                <th><?=round($detail['ETE'])."%"?></th>
            </tr>
            <?php endforeach; ?>
        </tbody>
       
    </table>

</div>

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
    
     function Filtrar(){
        var m = $('#maquina').combobox('getValue');
        var ini = $('#fecha_ini').datebox('getValue');
        var fin = $('#fecha_fin').datebox('getValue');

        document.location = '/Fimex/reportes/ete?ini='+ini+'&fin='+fin+'&maquina='+m;
    }
   
    
</script>
