<?php
/* @var $this yii\web\View */

use yii\bootstrap\Modal;

use yii\helpers\Html;
use yii\helpers\ArrayHelper;
use yii\helpers\URL;
 $id = 'maqop';
?>

<table id="<?php echo $id ?>" class="easyui-datagrid " style="width:100%;height:auto;"

        data-options="
			url:'maqopd',
			method:'post',
		    singleSelect: true,
			showFooter: true,
		    onClickRow:onClickRow ,
			toolbar:tb2
			
		"
   >
   
   <div id="tb2" style="height:auto">
						<!--
						
						<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-undo',plain:true" onclick="reject()">Reject</a>
						
						-->
						<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true" onclick="getChanges()">GetChanges</a>
						<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-undo',plain:true" onclick="deshacerfila()">Deshacer fila</a>
						<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-add',plain:true" onclick="agregar()">Agregar</a>
						<a href="javascript:void(0)" class="easyui-linkbutton" data-options="iconCls:'icon-save',plain:true" onclick="guardarcambios()">Guardar</a>
					</div>
   
    <thead>
		<tr>
			
			
			<th colspan="2">Operador</th>
			<th colspan="2">Maquina</th>
		</tr>
	
        <tr>
 
		
			
			
			<th data-options="field:'operador',width:60,
										
											
				editor:{
					type:'combobox',
					options:{
					valueField:'CODIGOANTERIOR',
					textField:'NOMBRECOMPLETO',
					url:'op',
					method:'get',
						}
				}
			">Opeador</th>
			
				<th data-options="field:'NOMBRECOMPLETO',width:300">Nombre</th>
			
			<th data-options="field:'maquina',width:100,
										
											
				editor:{
					type:'combobox',
					options:{
					valueField:'Maquina',
					textField:'Descripcion',
					url:'maq',
					method:'get',
						}
				}
			">Maquina</th>
			
				<th data-options="field:'Descripcion',width:400">Descripcion</th>
			
            
        </tr>
    </thead>
</table>

<script type="text/javascript">
		
	var editIndex = undefined;

		function endEditing(){
			var maquina = null;
			var operador = null;
			
			if (editIndex == undefined){return true}
			
			if ($('#<?php echo $id ?>').datagrid('validateRow', editIndex)){
			
				var ed_maquina = $('#<?php echo $id ?>').datagrid('getEditor', {index:editIndex,field:'maquina'});
				var ed_operador = $('#<?php echo $id ?>').datagrid('getEditor', {index:editIndex,field:'operador'});
			
				if (ed_maquina == null || ed_operador == null  )
							{return true;editIndex = undefined;}
							
							
				maquina = $(ed_maquina.target).combobox('getValue');
				operador = $(ed_operador.target).combobox('getValue');
				
				$('#<?php echo $id ?>').datagrid('getRows')[editIndex]['maquina'] = maquina;
				$('#<?php echo $id ?>').datagrid('getRows')[editIndex]['operador'] = operador;
				
				var grid = '#<?php echo $id ?>';
				$('#<?php echo $id ?>').datagrid('endEdit', editIndex);
				guardarcambios();
				$('#<?php echo $id ?>').datagrid('reload', editIndex);
			}
		}
		
		function deshacerfila(){
					var sel = $('#<?php echo $id ?>').datagrid('getSelected');
					var row=  $('#<?php echo $id ?>').datagrid('getRowIndex',sel);
					$('#<?php echo $id ?>').datagrid('cancelEdit',row);
					editIndex = undefined;
					$('#<?php echo $id ?>').datagrid('clearSelections');
					
		}
		
		function guardarcambios(){
		  var grid = '#<?php echo $id ?>';
			if (endEditing()){
				//$(grid).datagrid('acceptChanges');
				
					var data = $(grid).datagrid('getChanges');
					//$.post('".URL::to('/Fimex/programacion/save_semanal')."',
					$.post('mosave',
						{Data: JSON.stringify(data)},
						function(data,status){
							if(status == 'success' ){
								$(grid).datagrid('load');
								console.log(data);
								$var = $(grid).datagrid('getChanges');
							}else{
								reject('#$id');
								alert('Error al guardar los datos');
							}
						}
					);
				
				
			}
		}
		
		function onClickRow(inx,row){
			
				
			if (editIndex != inx){
				if (endEditing()){
					$('#<?php echo $id ?>').datagrid('selectRow', inx)
							.datagrid('beginEdit', inx);
					 			 
					
					
					editIndex = inx;
				} else {
					$('#<?php echo $id ?>').datagrid('selectRow', editIndex);
				}
			}
			
		}
		
		function agregar(){
			if (endEditing()){
                $('#<?php echo $id ?>').datagrid('appendRow',{});
                editIndex = $('#<?php echo $id ?>').datagrid('getRows').length-1;
                $('#<?php echo $id ?>').datagrid('selectRow', editIndex)
                        .datagrid('beginEdit', editIndex);
            }
			
		}
		
		function getChanges(){
			var rows = $('#<?php echo $id ?>').datagrid('getChanges');
			alert(rows.length+' rows are changed!');
		}

</script>