<?php

namespace frontend\controllers;

use Yii;
use frontend\models\produccion\TiemposMuerto;
use frontend\models\produccion\Temperaturas;
use frontend\models\produccion\MaterialesVaciado;
use frontend\models\produccion\ProduccionesDetalle;
use frontend\models\produccion\ProduccionesDefecto;
use frontend\models\programacion\Programacion;
use frontend\models\produccion\Producciones;
use frontend\models\programacion\ProgramacionesDia;

use frontend\models\produccion\VCapturaExceleada;
use frontend\models\programacion\VProgramacionesDia;
use common\models\vistas\VAleaciones;
use common\models\catalogos\VDefectos;
use common\models\catalogos\VProduccion2;
use common\models\catalogos\Maquinas;
use common\models\catalogos\VMaquinas;
use common\models\catalogos\VEmpleados;
use common\models\catalogos\Areas;
use common\models\datos\Causas;
use common\models\catalogos\Materiales;
use common\models\catalogos\Lances;
use common\models\vistas\VLances;
use common\models\dux\Aleaciones;

class AngularController extends \yii\web\Controller
{
    protected $areas;
    
    public function init(){
        $this->areas = new Areas();
    }
    
    /************************************************************
     *                    RUTAS PARA LOS MENUS
     ************************************************************/
    
    public function actionIndex()
    {
        return $this->render('index',[
            'title' => 'Captura de Produccion',
        ]);
    }
    
    public function actionMoldeo()
    {
        return $this->CapturaProduccion(6,null);
    }
    
    public function actionAlmas()
    {
        return $this->CapturaProduccion(2,null);
    }
    
    public function actionVaciado()
    {
        return $this->CapturaProduccion(10,null);
    }
    
    public function actionLimpieza()
    {
        return $this->CapturaProduccion(12,null);
    }
    
    public function actionPintado()
    {
        return $this->CapturaProduccion(8);
    }
    
    public function actionCerrado()
    {
        return $this->CapturaProduccion(9);
    }
    
    public function actionEmpaque()
    {
        return $this->CapturaProduccion(16,null);
    }
    
    public function CapturaProduccion($subProceso,$IdEmpleado = ' ')
    {
        $this->layout = 'produccion';
        
        return $this->render('CapturaProduccion', [
            'title' => 'Captura de Produccion',
            'IdSubProceso'=> $subProceso,
            'IdArea'=> $this->areas->getCurrent(),
            'IdEmpleado' => $IdEmpleado == ' ' ? Yii::$app->user->getIdentity()->getAttributes()['IdEmpleado'] : $IdEmpleado,
        ]);
    }                                               
    
    /************************************************************
     *                    OBTENCION DE DATOS
     ************************************************************/
    
    public function actionEmpleados($depto=''){
        if($depto != ''){
            $depto = (strpos($depto,",") ? explode(",",$depto) : $depto);
            $depto = (is_array($depto) ? implode("','",$depto) : $depto);
            $depto = "AND IDENTIFICACION IN('$depto')";
        }
        $model = VEmpleados::find()->where("IdEmpleadoEstatus <> 2 $depto"  )->orderBy('NombreCompleto')->asArray()->all();
        
        return json_encode(
            $model
        );   
    }
    
    public function actionFallas(){
        $IdSubProceso = $_GET['IdSubProceso'];
        $model = \common\models\catalogos\CausasTipo::find()->with('causas')->asArray()->all();
        
        foreach($model as $key => $mod){
            if(count($mod['causas'])>0){
                foreach($mod['causas'] as $key2 => $causa){
                    if($causa['IdSubProceso'] != $IdSubProceso){
                        unset($model[$key]['causas'][$key2]);
                    }
                }
            }else{
                unset($model[$key]);
            }
        }
        return json_encode($model);
    }
    
    public function actionAleaciones(){
       
        $model = VAleaciones::find()->where(['IdPresentacion' => $this->areas->getCurrent(),])->orderBy('Identificador')->asArray()->all();
        
        foreach($model as &$mod){
            $mod['IdAleacion'] *= 1;
            $mod['IdAleacionTipo'] *= 1;
            $mod['IdPresentacion'] *= 1;
        }
        
        return json_encode($model);
    }
    
    public function actionMaterial($IdSubProceso){
        $model = Materiales::find()->where([
            'IdSubProceso' => $IdSubProceso,
            'IdArea'=>$this->areas->getCurrent(),
        ])->asArray()->all();
        return json_encode($model);
    }
    
    public function actionMaquinas($IdSubProceso){
        $model = VMaquinas::find()->where([
            'IdSubProceso' => $IdSubProceso*1,
            'IdArea'=>$this->areas->getCurrent(),
        ])->asArray()->all();

        return json_encode($model);
    }
    
    public function actionDefectos($IdSubProceso){
        $model = VDefectos::find()->where([
            'IdSubProceso' => $IdSubProceso,
            'IdArea'=>$this->areas->getCurrent(),
        ])->asArray()->all();
        
        return json_encode($model);
    }
    
    public function actionProduccion(){
        $fecha = date('Y-m-d',strtotime($_GET['Fecha']));
        $IdSubProceso = $_GET['IdSubProceso'];
        $IdArea = $this->areas->getCurrent();

        $model = Producciones::find()->where("Fecha = '$fecha' AND IdArea = $IdArea AND IdSubProceso = $IdSubProceso")->with('lances')->asArray()->all();

        foreach ($model as &$val) {
            $val['Fecha'] = date('Y-m-d',strtotime($val['Fecha']));
        }
            
        return json_encode(
            $model
        );
    }
    
    public function actionDetalle(){
        $model = ProduccionesDetalle::find()->where($_GET)->with('idProductos')->asArray()->all();
        foreach($model as &$mod){
            $mod['Inicio'] = date('H:i',strtotime($mod['Inicio']));
            $mod['Fin'] = date('H:i',strtotime($mod['Fin']));
            $mod['Class'] = "";
        }
        return json_encode($model);
    }
    
    public function actionTemperaturas(){
        $model = Temperaturas::find()->where($_GET)->asArray()->all();
        return json_encode($model);
    }
    
    public function actionRechazos(){
        if(isset($_GET['IdProduccionDetalle'])){
            $model = ProduccionesDefecto::find()->where($_GET)->asArray()->all();
            foreach($model as &$mod){
                $mod['Rechazadas'] *= 1;
            }
            return json_encode($model);
        }
    }
    
    public function actionProgramacion(){
        $_GET['Dia'] = date('Y-m-d',strtotime($_GET['Dia']));
        if($_GET['IdSubProceso'] != 6){
            unset($_GET['IdMaquina']);
        }
        $model = VProgramacionesDia::find()->where($_GET)->asArray()->all();
        
        foreach($model as &$mod){
            $mod['Class'] = "";
        }
        
        return json_encode($model);
    }
    
    public function actionTiempos(){
        $_GET['Fecha'] = date('Y-m-d',strtotime($_GET['Fecha']));
        $model = TiemposMuerto::find()->where($_GET)->asArray()->all();
        
        foreach($model as &$mod){
            $mod['Inicio'] = date('H:i',strtotime($mod['Inicio']));
            $mod['Fin'] = date('H:i',strtotime($mod['Fin']));
        }
        
        return json_encode($model);
    }
    
    public function actionConsumo(){
        $model = MaterialesVaciado::find()->where($_GET)->asArray()->all();
        return json_encode($model);
    }
    
    /************************************************************
     *                    FUNCIONES EN GENERAL
     ************************************************************/
    public function actionSaveProduccion(){
        $data['Producciones'] = $_GET;

        if(!isset($data['Producciones']['IdArea'])){
            $data['Producciones']['IdArea'] = $this->areas->getCurrent();
        }

        if(!isset($data['Producciones']['Fecha'])){
            $data['Producciones']['Fecha'] = date('Y-m-d');
        }
        
        $data['Producciones']['Fecha'] = date('Y-m-d',strtotime($data['Producciones']['Fecha']));

        if(!isset($data['Producciones']['IdCentroTrabajo'])){
            $data['Producciones']['IdCentroTrabajo'] = VMaquinas::find()->where(['IdMaquina'=>$data['Producciones']['IdMaquina']])->one()->IdCentroTrabajo;
        }
        
        if(!isset($data['Producciones']['IdProduccionEstatus'])){
            $data['Producciones']['IdProduccionEstatus'] = 1;
        }
        
        if(!isset($data['Producciones']['IdEmpleado'])){
            $data['Producciones']['IdEmpleado'] = Yii::$app->user->getIdentity()->getAttributes()['IdEmpleado'];
        }
        
        $model = new Producciones();
        $model->load($data);
        if(!$model->save()){
            return false;
        }
        
        if($model->IdSubProceso == 10){
            $this->SaveLance($data['Producciones'],$model);
        }
        
        $model = Producciones::find()->where(['IdProduccion'=>$model->IdProduccion])->with('lances')->asArray()->one();
        
        $model['Fecha'] = date('Y-m-d',strtotime($model['Fecha']));
        return json_encode($model);
    }
    
    function SaveLance($data,$produccion){
        
        $model = VLances::find()->where([
            'IdArea' => $this->areas->getCurrent()
        ])->orderBy('Colada Desc')->asArray()->one();
        
        $model['Fecha'] = date('Y-m-d',strtotime($model['Fecha']));
        $data['Fecha'] = date('Y-m-d',strtotime($data['Fecha']));
        
        if(is_null($model)){
            $colada = 1;
            $lance = 1;
        }else{
            $colada = date('Y',strtotime($data['Fecha'])) != date('Y',strtotime($model['Fecha'])) ? 1 : $model['Colada'] + 1;
            $lance = date('Y-m-d',strtotime($data['Fecha'])) != date('Y-m-d',strtotime($model['Fecha'])) ? 1 : $model['Lance'] + 1;
        }

        $maq = Maquinas::findOne($produccion['IdMaquina']);
        
        $dat =[
            'Lances'=>[
                'IdAleacion' => json_decode($data['lances'])->IdAleacion * 1,
                'IdProduccion' => $produccion['IdProduccion'] *1,
                'HornoConsecutivo' => $maq->Consecutivo * 1,
                'Colada' => $colada,
                'Lance' => $colada,
            ]
        ];
        $lances = new Lances();
        $lances->load($dat);
        $lances->save();
        
        $maq->Consecutivo++;
        $maq->save();
    }
    
    function actionSaveDetalle(){
        $_GET['Fecha'] = date('Y-m-d',strtotime($_GET['Fecha']));
        $_GET['Inicio'] = $_GET['Fecha'] . " " . $_GET['Inicio'];
        $_GET['Fin'] = ($_GET['Fin'] < $_GET['Inicio'] ? $_GET['Fecha'] : date('Y-m-d',strtotime( '+1 day' ,strtotime($_GET['Fecha'])))) . " " . $_GET['Fin'];
        $_GET['Eficiencia'] = isset($_GET['Eficiencia']) ? $_GET['Eficiencia'] : 1;
        //var_dump($_GET);exit;
        $model = new ProduccionesDetalle();
        $IdDetalle = 'ProduccionesDetalle';
        
        if(!isset($_GET['IdProduccionDetalle'])){
            $model->load([
                "$IdDetalle"=>$_GET
            ]);
        }else{
            $model = $model::findOne($_GET['IdProduccionDetalle']);
            $model->load([
                "$IdDetalle"=>$_GET
            ]);
        }
        
        $model->save();
        $model = ProduccionesDetalle::find()->where(["IdProduccionDetalle" => $model->IdProduccionDetalle])->with('idProductos')->with('idProduccion')->asArray()->one();
        $model['Inicio'] = date('H:i',strtotime($model['Inicio']));
        $model['Fin'] = date('H:i',strtotime($model['Fin']));
        
        $this->actualizaHechas($model);

        return json_encode(
            $model
        );
    }
    
    function actionSaveAlmasDetalle(){
        $_GET['Fecha'] = date('Y-m-d',strtotime($_GET['Fecha']));
        $_GET['Inicio'] = $_GET['Fecha'] . " " . $_GET['Inicio'];
        $_GET['Fin'] = ($_GET['Fin'] < $_GET['Inicio'] ? $_GET['Fecha'] : date('Y-m-d',strtotime( '+1 day' ,strtotime($_GET['Fecha'])))) . " " . $_GET['Fin'];
        $_GET['Eficiencia'] = isset($_GET['Eficiencia']) ? $_GET['Eficiencia'] : 1;
        //var_dump($_GET);exit;
        $model = new AlmasProduccionDetalle();
        $IdDetalle = 'AlmasProduccionDetalle';
        
        if(!isset($_GET[$IdDetalle])){
            $model->load([
                "$IdDetalle"=>$_GET
            ]);
        }else{
            $model = $model::findOne($_GET[$IdDetalle]);
            $model->load([
                "$IdDetalle"=>$_GET
            ]);
        }
        
        $model->save();
        $model = ProduccionesDetalle::find()->where(["IdAlmaProducciones" => $model->IdAlmaProducciones])->with('idProductos')->with('idProduccion')->asArray()->one();
        $model['Inicio'] = date('H:i',strtotime($model['Inicio']));
        $model['Fin'] = date('H:i',strtotime($model['Fin']));
        
        //$this->actualizaHechas($model);

        return json_encode(
            $model
        );
    }
    
    function actionDeleteDetalle(){
        $model2 = ProduccionesDetalle::find()->where(['IdProduccionDetalle' => $_GET['IdProduccionDetalle']])->with('idProductos')->with('idProduccion')->asArray()->one();
        //var_dump($model2);exit;
        $model = ProduccionesDetalle::findOne($_GET['IdProduccionDetalle'])->delete();
        $this->actualizaHechas($model2);
    }
    
    function actionDeleteAlmasDetalle(){
        $model2 = AlmasProduccionDetalle::find()->where(['IdAlmaProduccion' => $_GET['IdAlmaProduccion']])->with('idProductos')->with('idProduccion')->asArray()->one();
        //var_dump($model2);exit;
        $model = AlmasProduccionDetalle::findOne($_GET['IdAlmaProduccion'])->delete();
        //$this->actualizaHechas($model2);
    }
    
    function actualizaHechas($produccion){
        $programacionDia = VProgramacionesDia::find()->where([
            'IdProgramacion' => $produccion['IdProgramacion'],
            'Dia' => date('Y-m-d',strtotime($produccion['idProduccion']['Fecha']))
        ])->asArray()->all();
        $diario = $programacionDia[0];
        $programacionDia = ProgramacionesDia::findOne($programacionDia[0]['IdProgramacionDia']);
        
        $hechas = 0;
        $ProduccionesDetalle = VProduccion2::find()->where([
            'Fecha'=> date('Y-m-d',strtotime($produccion['idProduccion']['Fecha'])),
            'IdProgramacion' => $produccion['IdProgramacion'],
            'IdSubProceso' => $produccion['idProduccion']['IdSubProceso'],
        ])->asArray()->all();
        
        //var_dump($programacionDia);exit;
        foreach($ProduccionesDetalle as $detalle){
            $hechas += $detalle['Hechas'];
            $hechas -= $produccion['idProduccion']['IdSubProceso'] == 6 ? 0 : $detalle['Rechazadas'];
        }
        
        if($produccion['idProduccion']['IdSubProceso'] == 6){
            $programacionDia->Llenadas = $hechas;
        }
        
        if($produccion['idProduccion']['IdSubProceso'] == 10){
            $programacionDia->Vaciadas = $hechas;
            $programacionDia->Hechas = $hechas * $produccion['PiezasMolde'];
        }
        
        $programacionDia->save();
        $produccion = new Producciones();
        $produccion->actualizaProduccion($diario);
        
    }
    
    function actionSaveTiempo(){
        $_GET['Inicio'] = $_GET['Fecha'] . " " . $_GET['Inicio'];
        $_GET['Fin'] = ($_GET['Fin'] < $_GET['Inicio'] ? $_GET['Fecha'] : date('Y-m-d',strtotime( '+1 day' ,strtotime($_GET['Fecha'])))) . " " . $_GET['Fin'];
        
        if(!isset($_GET['IdTiempoMuerto'])){
            $model = new TiemposMuerto();
            $model->load([
                'TiemposMuerto'=>$_GET
            ]);
        }else{
            $model = TiemposMuerto::findOne($_GET['IdTiempoMuerto']);
            $model->load([
                'TiemposMuerto'=>$_GET
            ]);
        }

        $model->save();
        $model = TiemposMuerto::find()->where(['IdProduccionDetalle' => $model->IdTiempoMuerto])->with('idCausa')->asArray()->one();
        $model['Inicio'] = date('H:i',strtotime($model['Inicio']));
        $model['Fin'] = date('H:i',strtotime($model['Fin']));
        
        return json_encode(
            $model
        );
    }
    
    function actionDeleteTiempo(){
        $model = TiemposMuerto::findOne($_GET['IdTiempoMuerto'])->delete();
    }
    
    function actionSaveProgramacion(){
        $IdProgramacion = $_GET['IdProgramacion'];
        $IdProgramacionSemana = $_GET['IdProgramacionSemana'];
        $IdProgramacionDia = $_GET['IdProgramacionDia'];
        $Fecha = $_GET['Fecha'];
        
        $Programacion = new Programacion();
        $ProduccionesDetalle = ProduccionesDetalle::find()->where(['IdProgramacion'=>$IdProgramacion,])->with('idProduccion')->asArray()->all();
        
        var_dump($ProduccionesDetalle);exit;
        foreach($ProduccionesDetalle as $detalle){
            
        }
        var_dump($totales);exit;
    }
    
    function actionSaveRechazo(){
        if(!isset($_GET['IdProduccionDefecto'])){
            $model = new ProduccionesDefecto();
            $model->load([
                'ProduccionesDefecto'=>$_GET
            ]);
        }else{
            $model = ProduccionesDefecto::findOne($_GET['IdProduccionDefecto']);
            $model->load([
                'ProduccionesDefecto'=>$_GET
            ]);
        }
        $model->save();
        $totalRechazo = ProduccionesDefecto::find()->select('sum(Rechazadas) AS Rechazadas')->where(['IdProduccionDetalle'=>$model->IdProduccionDetalle])->asArray()->one();
        $detalle = ProduccionesDetalle::findOne($model->IdProduccionDetalle);
        $detalle->load([
            'ProduccionesDetalle'=>$totalRechazo
        ]);
        $detalle->save();
        return json_encode(
            $model->Attributes
        );
    }
    
    function actionSaveConsumo(){
        if(!isset($_GET['IdMaterialVaciado'])){
            $model = new MaterialesVaciado();
            $model->load([
                'MaterialesVaciado'=>$_GET
            ]);
        }else{
            $model = MaterialesVaciado::findOne($_GET['IdMaterialVaciado']);
            $model->load([
                'MaterialesVaciado'=>$_GET
            ]);
        }
        $model->save();
    }
    
    function actionSaveTemperatura(){
        if(!isset($_GET['IdTemperatura'])){
            $model = new Temperaturas();
            $model->load([
                'Temperaturas'=>$_GET
            ]);
        }else{
            $model = Temperaturas::findOne($_GET['IdTemperatura']);
            $model->load([
                'Temperaturas'=>$_GET
            ]);
        }
        $model->save();
    }
    
    function actionDelete(){
        
    }
}

