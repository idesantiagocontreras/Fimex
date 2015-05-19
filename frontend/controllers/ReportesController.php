<?php

namespace frontend\controllers;

use yii;
use frontend\models\produccion\TiemposMuerto;
use frontend\models\produccion\ProduccionesDetalle;
use frontend\models\produccion\ProduccionesDefecto;
use frontend\models\produccion\Producciones;
use frontend\models\produccion\MaterialesVaciado;
use frontend\models\vistas\VCamisasAcero;
use common\models\catalogos\Materiales;
use common\models\catalogos\Maquinas;
use common\models\vistas\VMaterialArania;
use common\models\datos\Cajas;


use yii\data\ActiveDataProvider;
use yii\web\Controller;
use yii\web\NotFoundHttpException;
use yii\filters\VerbFilter;

class ReportesController extends Controller
{
    
    public function behaviors()
    {
        return [
            'verbs' => [
                'class' => VerbFilter::className(),
                'actions' => [
                    'delete' => ['post'],
                ],
            ],
        ];
    }

    /**
     * Lists all Productos models.
     * @return mixed
     */
    public function actionIndex()
    {
        return $this->render('index');
    }
    
    public function actionMoldeo()
    {
        $model = ProduccionesDetalle::find()
                ->joinWith('idProductos')
                ->joinWith('idProduccion')
                ->asArray()->all();
        //var_dump($model);exit;
        return $this->render('index', [
            'model' => $model,
        ]);
    }
    
    public function actionTiemposmuertos($ini,$fin){
        //$this->layout = 'JSON';
        $dataProvider = $this->Data_tiemposmuertos($ini, $fin);
       
        foreach ($dataProvider as &$value) {
             $minutos = $this->calcular_tiempo($value['Inicio'],$value['Fin']);
             $value['Minutos'] = $minutos;
        }
        
                   
        return $this->render('tiemposmuertos', [
            'model' => $dataProvider,
        ]);

        
       /* return json_encode([
                'total'=>count($model),
                'rows'=>$model,
        ]);*/
        
    }
    
    public function actionPiezascajas(){
       
        $command = \Yii::$app->db;
        
        if(isset($_GET['semana_ini'])){
            $semana1 = explode('-W',$_GET['semana_ini']);
            $semana2 = explode('-W',$_GET['semana_fin']);
            
            $anio1 = $semana1[0];
            $semana_ini = $semana1[1];
            
            $anio2 = $semana2[0];
            $semana_fin = $semana2[1];
        }else{
            $semana_ini = date("W");
            $anio1 = date("Y");
            
            $semana_fin = date("W");
            $anio2 = date("Y");
        }
        
        $model = new Cajas();
        $datos_cajas = $model->getDetalleCajas($semana_ini,$anio1,$semana_fin,$anio2);      
        $datos_pcajas = array();
    
        foreach ($datos_cajas as $key => $value) {
            if(!isset($datos_pcajas[$value['Tamano']]['Requerido'])){
                $datos_pcajas[$value['Tamano']]['Requerido'] = 0;
            }

            $datos_pcajas[$value['Tamano']]['Tamano'] = $value['Tamano'];
            $datos_pcajas[$value['Tamano']]['Requerido'] += $value['Requiere'];
            $datos_pcajas[$value['Tamano']]['CodigoDll'] = $value['CodDlls'];
            $datos_pcajas[$value['Tamano']]['CodigoPesos'] = $value['CodPesos'];
            $datos_pcajas[$value['Tamano']]['ExitTot'] = $value['CodPesos']+$value['CodDlls'];
        }
        
       // var_dump($datos_cajas);
        
        return $this->render('piezascajas', [
           'model' => $datos_pcajas,
           'detalle' => $datos_cajas,
        ]);

        
    }
    
    
    public function actionVaciado(){
        
        $model = MaterialesVaciado::find()
                ->joinWith('idMaterial')
                ->joinWith('idProduccion')
                ->asArray()->all();
        //var_dump($model);exit;
        
        return $this->render('MaterialVaciado', [
            'model' => $model,
        ]);
    }

    

    public function Data_tiemposmuertos($ini, $fin){

        if($ini == 0){
            $where  = "";
        }else{
            $where = "WHERE tm.Inicio BETWEEN '$ini' AND '$fin' ";
        }
        //echo $where;
        
        //Pasar al modelo
        $command = \Yii::$app->db;
        $model =$command->createCommand("
            SELECT 
                tm.IdTiempoMuerto, 
                tm.IdCausa, 
                tm.Inicio, 
                tm.Fin, 
                tm.Descripcion, 
                m.Identificador AS Maquina, 
                c.Indentificador AS Causa , 
                ct.Identificador AS TipoCausa
            FROM TiemposMuerto AS tm                                
            LEFT JOIN Maquinas AS m ON tm.IdMaquina = m.IdMaquina 
            LEFT JOIN Causas AS c ON tm.IdCausa = c.IdCausa 
            LEFT JOIN CausasTipo AS ct ON c.IdCausaTipo=ct.IdCausaTipo $where ")->queryAll();
        return $model;
    }
            
    
    public function actionEte(){
        
        //$produccion = $_GET['subProceso'];
        $maquina = 0;
        $ini = 0;
        $fin = 0;
        
        if(isset($_GET['maquina'])){ 
            $maquina = $_GET['maquina'];
            $ini = $_GET['ini'];
            $fin = $_GET['fin'];
        }
        
        //$data['Rechazadas'] = $dat->Rechazadas == '' ? 0 : $dat->Rechazadas;
        //$_GET['ini'] =
        //$_GET['fin'] =0
        $model = new ProduccionesDetalle();
        $datos_ete = $model->getDatos($maquina,$ini,$fin);      
       
        foreach ($datos_ete as &$key) {
                           
            $Ti = ( ( date('H:i',strtotime($key['Inicio'])) * 60 ) + date('i',strtotime($key['Inicio'])) );
            $Tf = ( (date('H:i',strtotime($key['Fin'])) * 60 ) + date('i',strtotime($key['Fin'])) ) ;
            
            $efic_moldeadora = 0.86;
            
            $Producesperada = (($key['MoldesHora']*$efic_moldeadora)/60);
            $ttot = $Tf - $Ti;
            $tdispo = $ttot - $key['TiempoMuerto'];
            $dispo = ($tdispo / $ttot)*100;
            $pesperado = $Producesperada*$tdispo;
            $preal = ($key['Hechas']/$pesperado)*100;
            $ok = $key['Hechas']-$key['Rechazadas'];
            
            $key['PRODUCESPERADO'] = $Producesperada; 
            $key['TTOT'] = $ttot;
            $key['TDISPO'] = $tdispo;
            $key['DISPO'] = $dispo;
            $key['PESPERADO'] =  $pesperado;
            $key['PREAL'] = $key['Hechas'];
            $key['EFICIENCIA'] = $preal;
            $key['OK'] = $ok;
            $key['CALIDAD'] = ($ok/$key['Hechas'])*100;
            $key['ETE'] = ((($key['DISPO']/100)*($key['EFICIENCIA']/100)*($key['CALIDAD']/100))*100);
                
        } 
        
        //var_dump($datos_ete);
        return $this->render('Ete', [
            'model' => $datos_ete,
        ]);
        
        
    }
    
    
    public function actionMaquinas(){
        $maquinas =Maquinas::find()->asArray()->all();
         
        return json_encode(
           $maquinas
        );   
    }

    
    public function actionMaterial(){
        
        $semanas = '';
        if(isset($_GET['semana'])){
           $semana = explode('-W',$_GET['semana']);
           $cantidad = $_GET['cantidad'];
           $anio = $semana[0];
           $semana = $semana[1];
        }  else { 
            $cantidad = 4;
            $semana = date("W");
            $anio = date("Y");
        }
        
        for ($i = 0; $i < $cantidad; $i++){
            $sem = $semana + $i;
            $semanas .= "[".$sem."],";
        } 
        
        $model = VMaterialArania::find()->asArray()->all();
        $commad = new VMaterialArania();
        $Material = $commad->getMaterial(substr($semanas,0,-1),$anio,$cantidad,$semana);
       
        //var_dump($Material);
        return $this->render('Material',['model'=>$Material,]);
        
    }
    
    
    public function actionCamisas(){
        $sem="";
        echo $week = date("W");
        
        if ($sem){
            $where = "WHERE Semana IN($week,$week+1,$week+2,$week+3,$week+4,$week+5) ";
        }else{
            $where = "WHERE Semana IN($week,$week+1,$week+2,$week+3,$week+4,$week+5)";
        }
        
        $camisas = new VCamisasAcero();
        $result = $camisas->find()->where($where)->asArray()->all();
        
        print_r($result);
        
        return $this->render('Camisas');
    }
            
    function calcular_tiempo($hora1,$hora2){
        
        $tiempo1 = date('H:i:s',strtotime($hora1));
        $fecha1 = date('Y-m-d',strtotime($hora1));
        
        $tiempo2 = date('H:i:s',strtotime($hora2));
        $fecha2 = date('Y-m-d',strtotime($hora2));
        
        $horas[1]=explode(':',$tiempo1);
        $fecha[1]=explode('-',$fecha1);
        
        $horas[2]=explode(':',$tiempo2);
        $fecha[2]=explode('-',$fecha2);
        
        //                 horas       minutos     segundos        mes          dia          año
        $fecha1=mktime($horas[1][0],$horas[1][1],$horas[1][2],$fecha[1][1],$fecha[1][2],$fecha[1][0]);
        $fecha2=mktime($horas[2][0],$horas[2][1],$horas[2][2],$fecha[2][1],$fecha[2][2],$fecha[2][0]);
        
        $segundos=$fecha2-$fecha1;
        $minutos=$segundos/60;  
        
      return $minutos;
    }
    
    
    
    
    

}