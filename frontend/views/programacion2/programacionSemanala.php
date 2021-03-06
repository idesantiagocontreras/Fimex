  <?php

use yii\helpers\Html;
use yii\helpers\URL;
use common\models\Grid;

 $area = Yii::$app->session->get('area');
 $area = $area['IdArea'];
 $fiel = 'ExitPTB'; $colspan = 'colspan="8"';
 if($area == 4){ 
    $fiel = 'ExitGPT'; $colspan = 'colspan="7"'; 
}elseif($area == 3){  
    $fiel = 'ExitPTB'; $colspan = 'colspan="6"';}
            

$id = 'programacion_semanal';

$semana = $semanas["semana1"]['value'];

echo Html::beginTag('div',['id'=>'tbSemanal']);
    echo Html::a('Guardar',"javascript:void(0)",[
        'class'=>"easyui-linkbutton",
        'data-options'=>"iconCls:'icon-save',plain:true",
        'onclick'=>"accept('#$id')"
    ]);
    echo Html::a('',"javascript:void(0)",[
        'onclick'=>"#"
    ]);
echo Html::endTag('div');

echo Html::beginTag('div',['id'=>'tbSemanal2']);
    echo Html::a('Actualizar',"javascript:void(0)",[
        'class'=>"easyui-linkbutton",
        'data-options'=>"iconCls:'icon-reload',plain:true",
        'onclick'=>"getChanges('#$id')"
    ]);
echo Html::endTag('div');
        
$this->registerJS("
    $('#semana1').change(function(){
        var semana = $(this).val();
        location.href ='/fimex/programacion2/semanalA?semana1=' + semana;
    });
");
$this->registerJS("
    var ProgramacionIndex = undefined;
    
    $('#$id').datagrid('enableFilter');
    /*function onClickRow(index){
        if (ProgramacionIndex != index){
        var row = $('#$id').datagrid('getValue');
            if (row){
                alert(row.Aleacion);
               
            }
            if (endEditing('#$id')){
                $('#$id').datagrid('selectRow', index);
                $('#".$id."2').datagrid('selectRow', index);
                $('#$id').datagrid('beginEdit', index);
                ProgramacionIndex = index;
            } else {
                $('#$id').datagrid('selectRow', index);
                $('#".$id."2').datagrid('selectRow', index);
            }
        }
    }*/
    
    /*function onClickRow(index){
        var grid = 'programacion_semanal2';
        var row = $('#".$id."2').datagrid('getSelected');
        if (row){
            alert(row.Aleacion);
            var data = row.Aleacion; //$(grid).datagrid('getChanges');
            $.get('".URL::to('/fimex/programacion2/datos_alea')."',
                {Data: JSON.stringify(data)},
                function(data,status){
                    if(status == 'success' ){
                        //$(grid).datagrid('load');
                        $(programacion_semanal2).datagrid('load');
                        console.log(data);
                    }else{
                        
                    }
                }
            );
        }
    }*/
    
  /*  function onDblClick(index){
        if (ProgramacionIndex != index){
            if (endEditing('#$id')){
                $('#$id').datagrid('selectRow', index);
                $('#".$id."2').datagrid('selectRow', index);
                $('#$id').datagrid('beginEdit', index);
                ProgramacionIndex = index;
            } else {
                $('#$id').datagrid('selectRow', index);
                $('#".$id."2').datagrid('selectRow', index);
            }
        }
    }*/
    
    function onClickRow(index){
        if (ProgramacionIndex != index){
            if (endEditing('#$id')){
                $('#$id').datagrid('selectRow', index);
                $('#".$id."2').datagrid('selectRow', index);
                $('#$id').datagrid('beginEdit', index);
                ProgramacionIndex = index;
            } else {
                $('#$id').datagrid('selectRow', index);
                $('#".$id."2').datagrid('selectRow', index);
            }
        }
    }
        
    function endEditing(grid){
        if (ProgramacionIndex == undefined){return true}
        if ($(grid).datagrid('validateRow', ProgramacionIndex)){
            $(grid).datagrid('endEdit', ProgramacionIndex);
            ProgramacionIndex = undefined;
            return true;
        } else {
            return false;
        }
    }
    
    function accept(grid){
        if (endEditing(grid)){
            var data = $(grid).datagrid('getChanges');
            $.get('".URL::to('/fimex/programacion2/save_semanal')."',
                {Data: JSON.stringify(data)},
                function(data,status){
                    if(status == 'success' ){
                        $(grid).datagrid('load');
                        $(grid+2).datagrid('load');
                        console.log(data);
                        \$var = $(grid).datagrid('getChanges');
                    }else{
                        reject('#$id');
                        alert('Error al guardar los datos');
                    }
                }
            );
        }
    }
    
    function getChanges(grid){
        $(grid).datagrid('load');
        $('#programacion_semanal2').datagrid('load');
    }
    
    function onAfterEdit(grid){
        accept('#$id');
    }
    function onUnselect(){
        onAfterEdit('#$id');
    }
",$this::POS_END);
?>
<div class="easyui-layout" style="width:100%;height:700px;">
    <div data-options="region:'west',border:false" style="width:60%">
        <table id="<?= $id ?>2" class="easyui-datagrid datagrid-f" data-options="
            url:'/fimex/programacion2/data_semanal',
            queryParams:{
                semana1:'<?= $semanas["semana1"]['value']?>',
            },          
            singleSelect:true,
            method:'get',
            collapsible:true,
            remoteSort:false,
            multiSort:true,
            showFooter:true,
            groupField:'Marca',
            loadMsg: 'Cargando datos',
            onAfterEdit: onAfterEdit,
            onClickRow: function(index){
                onClickRow(index);
            },
            toolbar: '#tbSemanal2',
        " style="height:650px;">
            <thead data-options="frozen:true">
                <tr>	
                    <th data-options="field:'Producto',sortable:true,width:150">No. Parte</th>
                    <th data-options="field:'ProductoCasting',sortable:true,width:150">Cod Cliente</th>
                </tr>
            </thead>
            <thead>
                <tr>
                    <th rowspan="2" data-options="field:'IdProgramacion',width:50,hidden:true,editor:{type:'numberbox',options:{precision:0,editable:false}}">Id</th>
                    <th rowspan="2" data-options="field:'Descripcion',sortable:true,width:200">Descripcion</th>
                    <th rowspan="2" data-options="field:'FechaEmbarque',align:'center',sortable:true,width:100">Embarque</th>
                    <th rowspan="2" data-options="field:'Aleacion',align:'center',sortable:true,width:80">Aleacion</th>
                    <th rowspan="2" data-options="field:'AreaAct',align:'center',width:60">AreaAct</th>
                    <th rowspan="2" data-options="field:'Marca',align:'center',sortable:true,width:100">Cliente</th>
                    <th rowspan="2" data-options="field:'Presentacion',sortable:true,hidden:true,width:100">Presentacion</th>
                    <th colspan="2" data-options="align:'center'">Pedido</th>
                    <th colspan="2" data-options="align:'center'">Saldo</th>
                    <th <?= $colspan; ?> data-options="field:'0',align:'center'">Existencias Almacenes</th>
                    <th rowspan="2" data-options="field:'Pzas_falt',align:'center',width:80">PZAS FALT</th>
                    <th rowspan="2" data-options="field:'Mold_falt',align:'center',width:80">MOLD FALT</th>
                    <th rowspan="2" data-options="field:'CiclosMolde',align:'center',width:70">CIC X<br>MOLD</th>
                    <th rowspan="2" data-options="field:'Programadas',align:'center',width:110">Total programado</th>
                    <th rowspan="2" data-options="field:'IdProgramacionSemana1',hidden:true,align:'center'">IdProgramacionSemana1</th>
                    <th rowspan="2" data-options="field:'IdProgramacionSemana2',hidden:true,align:'center'">IdProgramacionSemana2</th>
                    <th rowspan="2" data-options="field:'IdProgramacionSemana3',hidden:true,align:'center'">IdProgramacionSemana3</th>
                    <th rowspan="2" data-options="field:'Anio1',align:'center',hidden:true">Anio1</th>
                    <th rowspan="2" data-options="field:'Anio2',align:'center',hidden:true">Anio2</th>
                    <th rowspan="2" data-options="field:'Anio3',align:'center',hidden:true">Anio3</th>
                    <th rowspan="2" data-options="field:'Semana1',align:'center',hidden:true">Semana1</th>
                    <th rowspan="2" data-options="field:'Semana2',align:'center',hidden:true">Semana2</th>
                    <th rowspan="2" data-options="field:'Semana3',align:'center',hidden:true">Semana3</th>
                </tr>
                <tr>
                    <th data-options="field:'Cantidad',sortable:true,width:50,align:'center'">Pzas</th>
                    <th data-options="field:'Moldes',sortable:true,width:50,align:'center'">Mol</th>
                    <th data-options="field:'SaldoCantidad',sortable:true,width:50,align:'center'">Pzas</th>
                    <th data-options="field:'MoldesSaldo',sortable:true,width:50,align:'center'">Mol</th>
                    <th data-options="field:'PLA',align:'center',width:50">PLA</th>
                    <th data-options="field:'PLA2',align:'center',width:50">PLA2</th>
                    <th data-options="field:'CTA',align:'center',width:50">CTA</th>
                    <th data-options="field:'CTA2',align:'center',width:50">CTA2</th>
                    <th data-options="field:'PMA',align:'center',width:50">PMA</th>
                    <th data-options="field:'PMA2',align:'center',width:50">PMA2</th>
                    <th data-options="field:'PTA',align:'center',width:50">PTA</th>
                    <th data-options="field:'TRA',align:'center',width:50">TRA</th>
                    
                </tr>
            </thead>
        </table>
    </div>
    <div data-options="region:'center',border:false" >
        <table id="<?= $id ?>" class="easyui-datagrid datagrid-f" title="" data-options="
            url:'/fimex/programacion2/data_semanal',
            queryParams:{
                semana1:'<?= $semanas["semana1"]['value']?>',
            },
            singleSelect:true,
            method:'get',
            collapsible:true,
            remoteSort:false,
            multiSort:true,
            showFooter:true,
            groupField:'Marca',
            loadMsg: 'Cargando datos',
            onAfterEdit: onAfterEdit,
            onClickRow: function(index){
                onClickRow(index);
            },
            toolbar: '#tbSemanal',
        " style="height:650px;">
            <thead>
                <tr>
                    <th colspan="4" data-options="align:'center'">
                        <input id="semana1" type="week" value="<?= $semanas["semana1"]['value']?>">
                    </th>
                    <th colspan="4" data-options="align:'center'">
                        <input id="semana2" type="week" value="<?= $semanas["semana2"]['value']?>">
                    </th>
                    <th colspan="4" data-options="align:'center'">
                        <input id="semana3" type="week" value="<?= $semanas["semana3"]['value']?>">
                    </th>
                    <th colspan="4" data-options="align:'center'">
                        <input id="semana3" type="week" value="<?= $semanas["semana3"]['value']?>">
                    </th>
                </tr>
                <tr>
                    <th data-options="field:'Prioridad1',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Pr</th>
                    <th data-options="field:'Programadas1',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Prg</th>
                    <th data-options="field:'Hechas1',width:50,align:'center'">H</th>
                    <th data-options="field:'Falta1',width:50,align:'center'">F</th>
                    <th data-options="field:'Prioridad2',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Pr</th>
                    <th data-options="field:'Programadas2',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Prg</th>
                    <th data-options="field:'Hechas2',width:50,align:'center'">H</th>
                    <th data-options="field:'Falta2',width:50,align:'center'">F</th>
                    <th data-options="field:'Prioridad3',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Pr</th>
                    <th data-options="field:'Programadas3',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Prg</th>
                    <th data-options="field:'Hechas3',width:50,align:'center'">H</th>
                    <th data-options="field:'Falta3',width:50,align:'center'">F</th>
                    <th data-options="field:'Prioridad3',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Pr</th>
                    <th data-options="field:'Programadas3',width:50,align:'center',editor:{type:'numberspinner',options:{precision:0}}">Prg</th>
                    <th data-options="field:'Hechas3',width:50,align:'center'">H</th>
                    <th data-options="field:'Falta3',width:50,align:'center'">F</th>
                </tr>
            </thead>
        </table>
    </div>
</div>