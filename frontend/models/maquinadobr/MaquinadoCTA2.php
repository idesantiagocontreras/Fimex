<?php

namespace frontend\Models\Maquinadobr;
use Yii;
use yii\base\Model;

Class MaquinadoCTA2 extends Model {

    public function GetInfo($semana) {
          $tmp = explode('-',$semana);
		  $tmp_s = substr($tmp[1],1);
		$se1 =  $tmp_s +0;
		$se2 =  $tmp_s +1;
		$se3 =  $tmp_s +2;
		$se4 =  $tmp_s +3;
		
        $command = \Yii::$app->db_mysql;
        $result =$command->createCommand("
 				
				select 
				prod.producto,
				
				CASE
					WHEN pdp_ctb.Maquina is null THEN pdp_maquina_piezabr.Maquina
					ELSE  pdp_ctb.Maquina
				END
				  as maquina1,
 				

 				
				pdp_maquina_piezabr.op as opx,
				
				CASE 
						WHEN get_programacion_cta_prio(prod.producto,$se1) is not null THEN get_programacion_cta_prio(prod.producto,$se1) 
						WHEN get_programacion_cta_prio(prod.producto,$se2) is not null THEN get_programacion_cta_prio(prod.producto,$se2) 
						WHEN get_programacion_cta_prio(prod.producto,$se3) is not null THEN get_programacion_cta_prio(prod.producto,$se3) 
						WHEN get_programacion_cta_prio(prod.producto,$se4) is not null THEN get_programacion_cta_prio(prod.producto,$se4) 
						ELSE '' 
				END 
				     as prioridad,
				
				IFNULL(almplb.existencia,0)+IFNULL(almplb2.existencia,0) as PLB,
				IFNULL(almpmb.existencia,0)+IFNULL(almpmb2.existencia,0) as PMB,
				IFNULL(almctb.existencia,0)+IFNULL(almctb2.existencia,0) as CTB,
				
				almptb.existencia as PTB,
							
				DATE_FORMAT( dux1.fechaemb ,'%U') as sem1entrega,
				DATE_FORMAT( dux2.fechaemb ,'%U') as sem12entrega,
				dux1.cantidad as sem1,
				dux2.cantidad as sem2,
				
				get_programacion_cta_cantidad(prod.producto,$se1,pdp_maquina_piezabr.op ) as s1,
				get_programacion_cta_cantidad(prod.producto,$se2,pdp_maquina_piezabr.op) as s2,
				get_programacion_cta_cantidad(prod.producto,$se3,pdp_maquina_piezabr.op) as s3,
				get_programacion_cta_cantidad(prod.producto,$se4,pdp_maquina_piezabr.op) as s4,
				maq_piezasbr.Hold
				
				
				
				from 
				(				select  distinct almprod.PRODUCTO 
								from almprod 
								 LEFT JOIN	producto as p on p.IDENTIFICACION = almprod.PRODUCTO 
								where almprod.ALMACEN = 'CTB' and almprod.EXISTENCIA <> 0 and p.PRESENTACION =  'ACE'
								
								Union 
								
								select DISTINCT pdp_ctb.Pieza 
								from pdp_ctb
								where pdp_ctb.Semana between $se1 and $se4  
								and hecho = 0
				) as prod
				
				
				LEFT JOIN maq_piezasbr on producto = maq_piezasbr.IDENTIFICACION
				
				 Left JOIN (
						SELECT pieza,maquina,op
						FROM 	pdp_maquina_piezabr
						GROUP BY pieza ,OP
						
							
						
				) AS	pdp_maquina_piezabr  on pdp_maquina_piezabr.Pieza = prod.PRODUCTO 
				
			
				
				
				LEFT JOIN(
						SELECT 
						 ALMPROD.producto,min(PAROEN.doctoadicionalfecha) as fechaemb, sum(CANTIDAD) as cantidad
						FROM ALMPROD
						LEFT JOIN PAROEN on ALMPROD.producto = PAROEN.PRODUCTO
						WHERE
						DATE_FORMAT( PAROEN.doctoadicionalfecha ,'%U') = $se1
						and almprod.ALMACEN = 'CTB'
						GROUP BY ALMPROD.producto
						order by ALMPROD.producto
				) as dux1 on prod.PRODUCTO = dux1.producto 

				LEFT JOIN(
						SELECT 
						 ALMPROD.producto,min(PAROEN.doctoadicionalfecha) as fechaemb, sum(CANTIDAD) as cantidad
						FROM ALMPROD
						LEFT JOIN PAROEN on ALMPROD.producto = PAROEN.PRODUCTO
						WHERE
						DATE_FORMAT( PAROEN.doctoadicionalfecha ,'%U') = $se2
						and almprod.ALMACEN = 'CTB'
						GROUP BY ALMPROD.producto
						order by ALMPROD.producto
				) as dux2 on prod.PRODUCTO = dux2.producto 

				

				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA, almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'CTB'
					GROUP BY almprod.producto
				) as almctb on prod.PRODUCTO = almctb.producto
				
				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA, almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'CTB2'
					GROUP BY almprod.producto
				) as almctb2 on prod.PRODUCTO = almctb2.producto

				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA , almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'PTB'
					GROUP BY almprod.producto
				) as almptb on prod.PRODUCTO = almptb.producto

				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA , almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'PLB'
					GROUP BY almprod.producto
				) as almplb on prod.PRODUCTO = almplb.producto

				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA, almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'PLB2'
					GROUP BY almprod.producto
				) as almplb2 on prod.PRODUCTO = almplb2.producto
	
				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA, almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'PMB'
					GROUP BY almprod.producto
				) as almpmb on prod.PRODUCTO = almpmb.producto

				LEFT JOIN(
					SELECT   
						sum(ALMPROD.EXISTENCIA) AS EXISTENCIA, almprod.producto
					FROM ALMPROD
					WHERE 
					ALMPROD.ALMACEN =   'PMB'
					GROUP BY almprod.producto
				) as almpmb2 on prod.PRODUCTO = almpmb2.producto
				
				LEFT JOIN pdp_ctb on pdp_ctb.Pieza = prod.producto and  pdp_ctb.semana = $se1 and pdp_ctb.op = pdp_maquina_piezabr.op
				 where prod.PRODUCTO  in (select pieza from pdp_maquinado_blbr)
				ORDER BY 

				Hold,
				
				pdp_maquina_piezabr.op asc,
				maquina1,
				prioridad desc,
				producto,						
				
				dux1.fechaemb,
 				dux2.fechaemb
				     
 
				
		")->queryAll();
        
        if(count($result)!=0){
			 $min = 0;
			
			 $ts1=0;
			 $ts2=0;
			 $ts3=0;
			 $ts4=0;
			 $cta=0;
			 $rows = 0;
				foreach($result as &$r){
					$maquina=explode('-',$r['maquina1']);
					$min =  $this->p1tiempos($r['producto'], $r['maquina1'],$r['opx']);
						//echo '('.$min.')     p'.$r['producto'].'   m'.$r['maquina1'].'  s'.$r["s1"].' ' .$r["s2"].' '.$r["s3"].' '.$r["s4"];			  
					
					$r['Minutos'] =  $this->p1tiempos($r['producto'], $r['maquina1'],$r['opx']);
					$r['op'] =  $this->p1ops($r['producto'], $r['maquina1']);
					
					$r['s1_min'] = $min * $r["s1"];
					$r['s2_min'] = $min * $r["s2"];
					$r['s3_min'] = $min * $r["s3"];
					$r['s4_min'] = $min * $r["s4"];
					
								
					$r['tot_pza'] =  $r["s1"]+$r["s2"]+$r["s3"]+$r["s4"];
					$r['tot_min'] =  $r["s1_min"]+$r["s2_min"]+$r["s3_min"]+$r["s4_min"] ;
					
					
				if ($r['opx'] == 10 ||  $r['maquina1'] == null){
				}else {
				 $r['PLB'] = '';	
				 $r['CTB'] = '';	
				 $r['PMB'] = '';	
				 $r['PTB'] = '';	

				}
					
					if ($min != 0 || $min != null || $min !=  '' || $r['maquina1'] != 0 || $r['maquina1'] != null || $r['maquina1'] !=  '' ){
						$ts1 +=  $r["s1"] * $min;
						$ts2 +=  $r["s2"] * $min;
						$ts3 +=  $r["s3"] * $min;
						$ts4 +=  $r["s4"] * $min;
						$cta +=  $r["CTB"] * $min;
					}
					
				if ($r['s4_min'] ==  0) $r['s4_min'] = ''; 
				if ($r['s3_min'] ==  0) $r['s3_min'] = ''; 
				if ($r['s2_min'] ==  0) $r['s2_min'] = ''; 
				if ($r['s1_min'] ==  0) $r['s1_min'] = ''; 
				if ($r['Minutos'] ==  0) $r['Minutos'] = ''; 
				if ($r['sem1'] ==  0) $r['sem1'] = ''; 
				if ($r['sem2'] ==  0) $r['sem2'] = ''; 
				if ($r['tot_pza'] ==  0) $r['tot_pza'] = ''; 
				if ($r['tot_min'] ==  0) $r['tot_min'] = ''; 
				if ($r['CTB'] ==  0) $r['CTB'] = ''; 
				if ($r['PLB'] ==  0) $r['PLB'] = ''; 
				if ($r['PMB'] ==  0) $r['PMB'] = ''; 
				if ($r['PTB'] ==  0) $r['PTB'] = ''; 
				 $rows++; 
				}
				
				$totales[0]['s1_min'] = $ts1;
				$totales[0]['s2_min'] = $ts2;
				$totales[0]['s3_min'] = $ts3;
				$totales[0]['s4_min'] = $ts4;
				$totales[0]['CTA'] = $cta;
			
				$totales[0]['maquina1'] = 'Minutos';
				
				$totales[1]['s1_min'] = $ts1 == 0 ? $ts1 : number_format($ts1/60) ;
				$totales[1]['s2_min'] = $ts2 == 0 ? $ts2 : number_format($ts2/60) ;
				$totales[1]['s3_min'] = $ts3 == 0 ? $ts3 : number_format($ts3/60) ;
				$totales[1]['s4_min'] = $ts4 == 0 ? $ts4 : number_format($ts4/60) ;
				$totales[1]['CTA'] = $cta == 0 ? $cta : number_format($cta/60) ;
		
				$totales[1]['maquina1'] = 'Horas';
				
				$totales[2]['s1_min'] = $ts1 == 0 ? $ts1 : number_format(($ts1/60)/8,2) ;
				$totales[2]['s2_min'] = $ts2 == 0 ? $ts2 : number_format(($ts2/60)/8,2) ;
				$totales[2]['s3_min'] = $ts3 == 0 ? $ts3 : number_format(($ts3/60)/8,2) ;
				$totales[2]['s4_min'] = $ts4 == 0 ? $ts4 : number_format(($ts4/60)/8,2) ;
				$totales[2]['CTA'] = $cta == 0 ? $cta : number_format(($cta/60)/8,2) ;
	
				$totales[2]['maquina1'] = 'Turno 8H';
				
				$totales[3]['s1_min'] = $ts1 == 0 ? $ts1 : number_format(($ts1/60)/9,2) ;
				$totales[3]['s2_min'] = $ts2 == 0 ? $ts2 : number_format(($ts2/60)/9,2) ;
				$totales[3]['s3_min'] = $ts3 == 0 ? $ts3 : number_format(($ts3/60)/9,2) ;
				$totales[3]['s4_min'] = $ts4 == 0 ? $ts4 : number_format(($ts4/60)/9,2) ;
				$totales[3]['CTA'] = $cta == 0 ? $cta : number_format(($cta/60)/9,2) ;
			
				$totales[3]['maquina1'] = 'Turno 9H';
	
			
		$datos['rows'] = $result;
		$datos['footer'] = $totales;
		$datos['total'] = $rows;
		
          return $datos;   
        }   
        
        return null;
    }
	public function GetInfo_Maquina($semana){
	
	 $tmp = explode('-',$semana);
		  $s = substr($tmp[1],1);
		  
	
	$sql = "
Select    
pdp_maquina_turnosbr.maquina,

pdp_maquina_turnosbr.Matutino,
pdp_maquina_turnosbr.Vespertino,
pdp_maquina_turnosbr.Nocturno,

pdp_maquina_turnosbr.Minutos as minutos_m,
(pdp_maquina_turnosbr.Minutos)/60  as horas_m,
((pdp_maquina_turnosbr.Minutos)/60)/8  as t8_m,
((pdp_maquina_turnosbr.Minutos)/60)/9  as t9_m,

t.turno as t8_o,
t.turno*8  as horas_o,
((t.turno)*8)*60  as minutos_o

from pdp_maquina_turnosbr 
LEFT JOIN 
		(	Select    
			ifnull( ifnull(pdp_maquina_turnosbr.Matutino,0)/ifnull(pdp_maquina_turnosbr.Matutino,0) ,0) +
			ifnull( ifnull(pdp_maquina_turnosbr.Vespertino,0)/ifnull(pdp_maquina_turnosbr.Vespertino ,0),0) +
			ifnull( ifnull(pdp_maquina_turnosbr.Nocturno,0)/ifnull(pdp_maquina_turnosbr.Nocturno,0) ,0)
			as turno,
			pdp_maquina_turnosbr.maquina

			from pdp_maquina_turnosbr
			where
			semana = $s
		) as T  on t.maquina =  pdp_maquina_turnosbr.maquina
where
semana = $s 
";

		$command = \Yii::$app->db_mysql;
        $result =$command
					->createCommand($sql)
					->queryAll();
		
		
		 $minutos_m = 0;
		 $horas_m = 0;
		 $t8_m = 0;
		 $rows = 0;
		foreach($result as &$r ){
			$mm = $r['minutos_m'];// problema ocn number format y suma
			$r['minutos_m']=number_format($r['minutos_m'],0);
			$r['horas_m']=number_format($r['horas_m'],2);
			$r['t8_m']=number_format($r['t8_m'],2);
			$r['t9_m']=number_format($r['t9_m'],2);
			$r['t8_o']=number_format($r['t8_o'],2);
			$r['horas_o']=number_format($r['horas_o'],2);
			$r['minutos_o']=number_format($r['minutos_o'],2);
			
			$minutos_m += $mm; 
			$horas_m +=$r['horas_m'] ;
			$t8_m+=$r['t8_m'] ;
									
			$rows++;
		}
		
		
		$totales[0]['minutos_m'] = number_format($minutos_m);
		$totales[0]['horas_m'] = number_format($horas_m);
		$totales[0]['t8_m'] = number_format($t8_m,2);
		$totales[0]['maquina'] = 'Totales';
		
		$datos['rows'] = $result;
		$datos['footer'] = $totales;
		$datos['total'] = $rows;
		
		
		
		return $datos;
 

} 

public function GetInfo_programacion($semana){
	
	 $tmp = explode('-',$semana);
		  $s = substr($tmp[1],1);
		  
	//falta condicionar con semana en cta para query
	
	
	$sql = "
		
	
		select 
			cta.maquina,
			cta.pieza, 
			cta.cantidad, 
			cta.prioridad,
			pdp.hechas as buenas ,
			pdp.rechazo as malas,
			cta.minutos,
			cta.minutos/60 as horas,
			(cta.minutos/60)/8 as t8,
			(cta.minutos/60)/9 as t9
		from mysqlloc...pdp_cta as cta   
		left join pdp on pdp.producto = cta.pieza
	
	";
	
	$command = \Yii::$app->db_ete;
        $result =$command
					->createCommand($sql)
					->queryAll();
	
	
	 $minutos_m = 0;
		 $horas_m = 0;
		 $t8_m = 0;
		 $rows = 0;
		 $cantidad = 0;
		foreach($result as $r ){
			$minutos_m += $r['minutos']; 
			$horas_m +=$r['horas'] ;
			$cantidad += $r['cantidad'];
			$t8_m+=$r['t8'] ;
			$rows++;
		}
		
		$totales[0]['minutos'] =  number_format($minutos_m);
		$totales[0]['horas'] =  number_format($horas_m);
		$totales[0]['t8'] = $t8_m;
		$totales[0]['cantidad'] = $cantidad;
		$totales[0]['maquina'] = 'Totales';
		
		$datos['rows'] = $result;
		$datos['footer'] = $totales;
		$datos['total'] = $rows;
		

		return $datos;
	
}

public function GetInfo_Operador($semana){

	 $tmp = explode('-',$semana);
		  $s = substr($tmp[1],1);
		  
	
	$sql = "
	
		select turnos.*,empleado.NOMBRECOMPLETO as nombre
		from (
			select maquina,minutos_o as minutos,minutos_o/60 as horas,(minutos_o/60)/8 as t8,
			'Mat' as titulo,Matutino as turno from pdp_maquina_turnosbr
				where semana = $s  AND Matutino is not null
		UNION
			select maquina,minutos_o as minutos,minutos_o/60 as horas,(minutos_o/60)/8 as t8,
			'Ves' as titulo,Vespertino as turno from pdp_maquina_turnosbr
				where semana = $s AND Vespertino is not null
		UNION
			select maquina,minutos_o as minutos, minutos_o/60 as horas,(minutos_o/60)/8 as t8,
			'Noc' as titulo ,Nocturno as turno from pdp_maquina_turnosbr
				where semana = $s AND Nocturno is not null
		) as turnos
		JOIN empleado where turnos.turno = empleado.CODIGOANTERIOR
	
	";
	
	$command = \Yii::$app->db_mysql;

	$result =$command
					->createCommand($sql)
					->queryAll();
	

	return $result;
}


public function  GetInfo_pza_op($semana){

	 $tmp = explode('-',$semana);
		  $s = substr($tmp[1],1);
		  
	
	$sql = "
	
		select 
		pdp_ctb.maquina,pdp_ctb.op,pdp_ctb.Pieza,pdp_ctb.Cantidad,pdp_ctb.semana,pdp_ctb.op,
		CONCAT(emat.CODIGOANTERIOR+0 ,'-', emat.NOMBRECOMPLETO) as m,
		CONCAT(eves.CODIGOANTERIOR+0 ,'-', eves.NOMBRECOMPLETO) as v,
		CONCAT(enoc.CODIGOANTERIOR+0 ,'-', enoc.NOMBRECOMPLETO) as n
		from pdp_ctb
		JOIN pdp_maquina_turnosbr on  pdp_maquina_turnosbr.semana = pdp_ctb.semana and pdp_maquina_turnos.maquina = pdp_ctb.Maquina
		left join empleado as emat on emat.CODIGOANTERIOR = Matutino   
		left join empleado as eves on eves.CODIGOANTERIOR = Vespertino
		left join empleado as enoc on enoc.CODIGOANTERIOR = Nocturno 
		where pdp_ctb.Semana = $s 
		ORDER BY pdp_ctb.Maquina
	
	";
	
	$command = \Yii::$app->db_mysql;

	$result =$command
					->createCommand($sql)
					->queryAll();
	

	return $result;
}
   
   // public function p1minutos($maq,$pieza) {
    // $command = \Yii::$app->db_mysql;
	// $sql = "Select min(minutos) as min from pdp_maquina_pieza where pieza ='$pieza' and maquina = '$maq' and op = 10";
	// $result =$command
					// ->createCommand($sql)
					// ->queryAll();
		
		// return $result[0]['min'];
   
   // }
   public function hold($data){
   
	$command = \Yii::$app->db_mysql;
	
	$hold = $data->{'Hold'};
	$prod =  $data->{'producto'};
	

	
	 $result =$command->createCommand()->update('maq_piezasbr',[
												'Hold' => $hold
												], 	[
												'IDENTIFICACION' => $prod
												]
								)->execute();
	
	
	
   }
   
   
   public function getOperaciones(){
	   
	   $command = \Yii::$app->db_mysql;
	   
	   
	 $result =$command->createCommand("Select  op 
					from pdp_ops
					")
					->queryAll();

	return $result;   
	   
   }
   
   public function p1tiempos($pieza, $maquina,$op){
	   
				
				$m =    $this->maquinapiezamin($pieza,$op,$maquina);
			
	   
	   return $m; 
	   
   }   
   
   public function p1tiemposgrupo($pieza, $maquina){
	   
	   $command = \Yii::$app->db_mysql;
			$op = $this->getOperaciones();
			
			$minpieza = null;
			
			foreach($op as $o ){
				
				$m =    $this->maquinapiezamin($pieza,$o['op'],"");
			
			  if($m != null)
				  $minpieza += $m;
				 
//				 $minpieza .= " ".$m;
			
			}
	   
	   
	   return $minpieza; 
	   
   }
   
    
   
   // public function p2exist($maquina,$semana){
		
		// $command = \Yii::$app->db_mysql;
		
		// $result =$command
					// ->createCommand("
					
					// Select  count(Maquina) as maq 
					// from pdp_maquina_turnos
					// where maquina = '$maquina' and semana = '$semana'
					
					// ")
					// ->queryAll();
					
		// regresa mayor a 0 si existe			
		// return $result[0]['maq'] >  0 ? true : false;
	// }

	public function p1exist($pieza,$semana,$op){
		
		$command = \Yii::$app->db_mysql;
		
		$sql = "
					
					Select  count(Maquina) as min 
					from pdp_ctb 
					where pieza ='$pieza'  and semana = '$semana' and op = $op 
					
					";
		
		$result =$command->createCommand($sql)->queryAll();
		$res =$command->createCommand($sql)->getRawSql();
					print_r($res);
					print_r($result);
					
		
		return $result[0]['min'] >  0 ? true : false;
	}
	
	public function p2Turnos($maq,$sem){
		$command = \Yii::$app->db_mysql;
		$sql= "
		
		Select  Matutino,Vespertino,Nocturno
					from pdp_maquina_turnosbr
					where maquina = '$maq' and semana = $sem
		
		";
		$result =$command
					->createCommand($sql)->queryAll();
		
	return $result[0];
	}
	
	public function p2minutos($maquina,$semana){
		$command = \Yii::$app->db_mysql;
		$sql = "
		
					Select  minutos as min 
					from pdp_maquina_turnosbr
					where maquina = '$maquina' and semana = '$semana'
		";
		
		$result =$command
					->createCommand($sql)->queryAll();
					
		//return $result[0]['min'];
		
	}
	
	public function p2save($data) {
		
			$command = \Yii::$app->db_mysql;
		
		$semana  =$data['semana']  ;
		
		$tmp = explode('-',$semana);
		  $semana = substr($tmp[1],1);
				
				$data['minutos_m'] = str_replace(',','',$data['minutos_m']);
				if ($data['Matutino'] == 0) $data['Matutino'] = "";
				if ($data['Vespertino'] == 0) $data['Vespertino'] = "";
				if ($data['Nocturno'] == 0) $data['Nocturno'] = "";
	
			print_r($data);
		$min = $this->p2minutos($data['maquina'], $semana);
		
		// $turnosActual = $this->p2Turnos($data['maquina'],$semana);
		 // $turnoCapturado = array(  'Matutino'   => $data['Matutino'],
								  // 'Vespertino' => $data['Vespertino'],
								  // 'Nocturno'   => $data['Nocturno']
								// );
		 // $diff = array_diff_assoc($turnosActual,$turnoCapturado);
		// $arregloSize = count($diff);
		$turnos = 0; 
		if ($data['Matutino'] != null || $data['Matutino'] != '') $turnos ++;
		if ($data['Vespertino'] != null || $data['Vespertino'] != '') $turnos ++;
		if ($data['Nocturno'] != null || $data['Nocturno'] !=  '') $turnos ++;
	
		if($turnos > 0 )
			$minutos = $data['minutos_m']/$turnos;
		else 
			$minutos = $data['minutos_m'];
		
		
			 $result =$command->createCommand()->update('pdp_maquina_turnosbr',[
									'Matutino' => $data['Matutino'],
									'Vespertino' => $data['Vespertino'],
									'Nocturno' => $data['Nocturno'], 
									'minutos_o' => $minutos
									
									], 	[
									'maquina' => $data['maquina'],
									'semana' => $semana
									]
								)->execute();
		
		
	}
	
	public function p1save($data) {
		$command = \Yii::$app->db_mysql;
		
		$fsemana  =$data['semana']  ;
						
		$maq_pieza = $this->maquinapieza_todo($data['producto']);
		
		if (!$this->p1exist($data['producto'],$data['semana'],$data['opx']) ){
			if ($data['cantidad'] == 0) return ;
			
			$result =$command->createCommand()->insert('pdp_ctb',[

									'pieza' => $data['producto'], //captura row
									'maquina' => $data['maquina'], // captura row  maquina1 maquina2 maquina3
									'cantidad' => $data['cantidad'],// captura row s1 s2 s3 s4
									'minutos' => $data['minutos'], // hacer funcion para sacar de maquina_pieza
									'semana' => $data['semana'], // de inpul cal
									'aio' => $data['aio'],// scaar año de sem actual
									'semEntrega' => $fsemana,
									'prioridad' => $data['prioridad'],
									'programado' => $data['programado'],
									'op' => $data['opx'],
									//'semana_q' => $data['semana_q']
			])->execute();
			// ])->getRawSql();
			//se llena pdp_maquina turnos
			$this->maquinaturnossemana( $data );
		}else{
		  //echo ' existe se actualiza';
		  
			  if($data['cantidad'] == 0  ){
					
				$result =$command->createCommand()->delete('pdp_ctb',[
														
														'semana' => $data['semana'],
														'op' => $data['opx'],
														'pieza' => $data['producto']
																					])->execute();
																					// ])->getRawSql();
																					// print_r($result);
				//se llena pdp_maquina turnos
				$this->maquinaturnossemana( $data );																	
				
												return true; //corta ejecucion y sale
				}
			  
			  $result =$command->createCommand()->update('pdp_ctb',[
										'maquina' => $data['maquina'],
										'prioridad' => $data['prioridad'],
										'cantidad' => $data['cantidad'] 
										], 	[
										
										'pieza' => $data['producto'],
										'op' => $data['opx'],
										'semana' => $data['semana']
										]
									)->execute();
								// )->getRawSql();
				//se llena pdp_maquina turnos
				$this->maquinaturnossemana( $data );
			
									
		  }
		echo "query: $result \n";	

		
		
	
	}
	
	// public function maquinaturno_todo($maquina,$semana){
		// $command = \Yii::$app->db_mysql;
		// $sql = "
			// Select * from pdp_maquina_turnos 
					// where  maquina = '$maquina' and semana = $semana
		
		// ";
		// $result =$command
					// ->createCommand($sql)
					// ->queryAll();
	
		// return $result;
	// }
	
	public function MaquinaSemanaCtaexist($maquina,$semana){
		
		$command = \Yii::$app->db_mysql;
		
		$sql = 
		"Select  count(Maquina) as turno 
					from pdp_ctb
					where  maquina = '$maquina' and semana = $semana";
		
		$result =$command
					->createCommand($sql)
					->queryAll();
		
		// regresa mayor a 0 si existe		
		return $result[0]['turno'] >  0 ? true : false;
		
		
	}
		
		
		
		
	
	public function maquinaturnosexist($maquina,$semana){
		
		$command = \Yii::$app->db_mysql;
		
		$sql = 
		"Select  count(Maquina) as turno 
					from pdp_maquina_turnosbr
					where  maquina = '$maquina' and semana = $semana";
		
		$result =$command
					->createCommand($sql)
					->queryAll();
		
		// regresa mayor a 0 si existe			
		return $result[0]['turno'];
	
	}
	
	
	
	public function calMaquinaSemana($maquina,$semana){
		
		$command = \Yii::$app->db_mysql;
		
		$sql = 
		"Select  sum(Minutos*Cantidad) as min  
			from pdp_ctb
			where maquina = '$maquina' and semana = $semana";
		
		$result =$command
					->createCommand($sql)
					->queryAll();
		
		// regresa mayor a 0 si existe			
		return $result[0]['min'];
		
	}
	
	public function maquinaturnossemana($data){
		$command = \Yii::$app->db_mysql;
	
		$pieza = $data['producto']; 
		$maquina = $data['maquina'];
		$cantidad = $data['cantidad'];
		$semana = $data['semana'];
			
			$minutos =  $this->calMaquinaSemana($maquina,$semana);
	   
		if($this->maquinaturnosexist($maquina,$semana)){
			// update o delete
		
			//si no existe en cta la maquina con ninguna pieza en la semana especificada
			if( !$this->MaquinaSemanaCtaexist($maquina,$semana)){	
					  	
						$result =$command->createCommand()->delete('pdp_maquina_turnosbr',[
																	'maquina' => $maquina,
																	'semana' => $semana
																	])->execute();
																	// ])->getRawSql();
																	// print_r($result);
						return true; //corta ejecucion y sale
			}
			 
						$result =$command->createCommand()->update('pdp_maquina_turnosbr',[
												'minutos' => $minutos
												], 	[
												'maquina' => $maquina,
												'semana' => $semana
												]
											)->execute();
											 // )->getRawSql();
											 // print_r($result);
			
			
		}else{
			
				
			$result =$command->createCommand()->insert('pdp_maquina_turnosbr',[
									'minutos' => $minutos,
									'maquina' => $maquina,
									'semana' => $semana
									]
								) ->execute();
								// )->getRawSql();
							 // print_r($result);
								
		}
		
			
	}
	
	public function maquinapieza($pieza,$op){
		$command = \Yii::$app->db_mysql;
		$result =$command
					->createCommand("
							Select distinct maquina 
							from pdp_maquina_piezabr 
							where pieza ='$pieza' and op = $op 
							order by minutos ASC
							")
					->queryAll();
		
		return $result;
	}
	
	public function maquinapiezamin($pieza,$op,$maquina){
		$command = \Yii::$app->db_mysql;
		$sql = "
				Select minutos
					from pdp_maquina_piezabr where pieza ='$pieza' and op = $op
				";
		
		if ($maquina != "")
			$sql .= " and maquina = '$maquina' ";
		
		if ($op == null || $maquina == null ){
			return 0;
			
		}
		
		$result =$command
					->createCommand($sql)
					->queryAll();
		
		return $result ? $result[0]['minutos'] : null;
	}

	
	public function maquinaoperador($maquina){
		$command = \Yii::$app->db_mysql;
		$r1 =$command
					->createCommand("
					select operador , empleado.NOMBRECOMPLETO
					from maquina_operadorbr
					left join  Empleado  on empleado.CODIGOANTERIOR = maquina_operadorbr.operador
					where maquina = '". $maquina."'
					
					")
					->queryAll();
		$r0 =[ "-1" => ["operador"=>"---","NOMBRECOMPLETO"=>"---"]];
		$result = array_merge($r0,$r1);
		return $result;
	}
	
	public function maquinapieza_todo($pieza){
		$command = \Yii::$app->db_mysql;
		$result =$command
					->createCommand("Select * from pdp_maquina_piezabr where pieza ='". $pieza."'")
					->queryAll();
		
		return $result;
	}
	
	//operaciones amarillo
	
	public function maquinapieza_todo_mp($pieza){
		$command = \Yii::$app->db_mysql;
		$result =$command
					->createCommand("Select maquina,op from pdp_maquina_piezabr where pieza ='$pieza' ORDER BY maquina,op asc")
					->queryAll();
		
		return $result;
	}
	
	
	public function operacionesPieza($pieza){
		$command = \Yii::$app->db_mysql;
		$result =$command
					->createCommand("Select MAX(op) as op from pdp_maquina_piezabr where pieza = '$pieza'")
					->queryAll();
		
		$ops = $result[0]['op'];
		$ops = $ops /10;

		return $ops;
	}
	
	
	  public function p1ops($pieza){
	   				
		$res= $this->maquinapieza_todo_mp($pieza);
		// $ops= $this->operacionesPieza($pieza);
		$maq = null;
		// $i = 1;
			foreach ($res as $mp){
				
				// if ($maq == null){
					// $maq = $mp['maquina'];
				// }
				
				// if ($i == $ops &&  $maq !=  $mp['maquina']){
					// $maq = $mp['maquina'] ;
				// }
				
				// if( $maq !=  $mp['maquina'] && ($i*10 != $mp['op'])  ){
					// return 0;
				// } 

				
			 	// if ($i < $ops ){
					// $i++;
				// }else{
					// $i=1;
				// }
				
				
				if ( $maq !=  $mp['maquina']){
					$maq = $mp['maquina'] ;
					$i = 1;
				 }
				 
				 if( $maq !=  $mp['maquina'] || ($i*10 != $mp['op'])  ){
					return 0;
				} 
				$i++;
				
			}
			

		return 1;
		}
	
}