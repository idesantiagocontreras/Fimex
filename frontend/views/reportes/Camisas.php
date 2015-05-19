<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

 $cantidad = 6;
 $semanas = date("W");

?>

    <table style="width:100%" id="ff" class="table table-striped">
    <!--<thead data-options="frozen:true">
        <tr>
             <th width="90" >Tamaño</th>
            <th width="100">Descripcion</th>
        </tr>
    </thead>-->    
    <thead>
        <tr>     
            <th>Tamaño</th>
            <th>Descripcion</th>             <?php 
                for ($i = 0; $i < $cantidad; $i++){
                    $sem = $semanas + $i;
                    
                    echo ' <th>Sem '.$sem.' </th>';
                    if( $i < 2 ){
                        echo ' <th>H Sem '.$sem.' </th>';
                    }
                    
                }
            ?>
            <th>Tot Prog</th>          
            <th>Tot Prog 2 Sem</th>
            <th>Existencias</th>
            <th>X Pedir</th>
            <th>Pza X Paq</th>
            <th>Paq X Pedir 2Sem</th>
            <th>MIN DLLS</th>
            <th>MAX DLLS</th>
            <th>MIN Pesos</th>
            <th>MAX Pesos</th>
            <th>Exist DLLS</th>
            <th>Exist P</th>
            <th>Scrap Vac</th>
            <th>Lleva Camisa</th>
            <th>Cod DLLS</th>
            <th>Cod Pesos</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
        </tr>
    </tbody>
</table>