<?php

namespace frontend\models\produccion;

use Yii;
use yii\data\ArrayDataProvider;
use common\models\dux\Productos;
use frontend\models\produccion\TiemposMuerto;


/**
 * This is the model class for table "ProduccionesDetalle".
 *
 * @property integer $IdProduccionDetalle
 * @property integer $IdProduccion
 * @property integer $IdProgramacion
 * @property integer $IdProductos
 * @property string $Inicio
 * @property string $Fin
 * @property integer $CiclosMolde
 * @property integer $PiezasMolde
 * @property integer $Programadas
 * @property integer $Hechas
 * @property integer $Rechazadas
 * @property string $Eficiencia 
 *
 * @property Producciones $idProduccion
 * @property Productos $idProductos
 * @property Programaciones $idProgramacion
 * @property SeriesDetalles[] $seriesDetalles
 * @property ProduccionesDefecto[] $produccionesDefectos
 */
class ProduccionesDetalle extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'ProduccionesDetalle';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['IdProduccion', 'IdProgramacion', 'IdProductos', 'Eficiencia'], 'required'],
            [['IdProduccion', 'IdProgramacion', 'IdProductos', 'CiclosMolde', 'PiezasMolde', 'Programadas', 'Hechas', 'Rechazadas'], 'integer'],
            [['Inicio', 'Fin'], 'safe'],
            [['Eficiencia'], 'number']
        ];
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'IdProduccionDetalle' => 'Id Produccion Detalle',
            'IdProduccion' => 'Id Produccion',
            'IdProgramacion' => 'Id Programacion',
            'IdProductos' => 'Id Productos',
            'Inicio' => 'Inicio',
            'Fin' => 'Fin',
            'CiclosMolde' => 'Ciclos Molde',
            'PiezasMolde' => 'Piezas Molde',
            'Programadas' => 'Programadas',
            'Hechas' => 'Hechas',
            'Rechazadas' => 'Rechazadas',
            'Eficiencia' => 'Eficiencia', 
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdProduccion()
    {
        return $this->hasOne(Producciones::className(), ['IdProduccion' => 'IdProduccion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdProductos()
    {
        return $this->hasOne(Productos::className(), ['IdProducto' => 'IdProductos']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdProgramacion()
    {
        return $this->hasOne(Programaciones::className(), ['IdProgramacion' => 'IdProgramacion']);
    }
    
    /** 
    * @return \yii\db\ActiveQuery 
    */ 
    public function getSeriesDetalles() 
   { 
       return $this->hasMany(SeriesDetalles::className(), ['IdProduccionDetalle' => 'IdProduccionDetalle']); 
   } 
 
    /**
     * @return \yii\db\ActiveQuery
     */
    public function getProduccionesDefectos()
    {
        return $this->hasMany(ProduccionesDefecto::className(), ['IdProduccionDetalle' => 'IdProduccionDetalle']);
    }
    
     /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdMaquina()
    {
        return $this->hasMany(Ma::className(), ['IdProduccionDetalle' => 'IdProduccionDetalle']);
    }
    
    public function getDetalle($produccion){
        /*$result = $this->find()->where("IdProduccionDetalle = 6")->all();
        var_dump($result);exit;*/
        $result = $this->find()->where("IdProduccion= $produccion")->asArray()->all();

        foreach ($result as &$res){
            $productos = Productos::findOne($res['IdProductos'])->Attributes;
            $res['Producto'] = $productos['Identificacion'];
            $res['Fin'] = date('H:i:s',strtotime($res['Fin']));
            $res['Inicio'] = date('H:i:s',strtotime($res['Inicio']));
        }

        if(count($result)!=0){
            return new ArrayDataProvider([
                'allModels' => $result,
                'id'=>'IdPedido',
                'sort'=>array(
                    'attributes'=> $result[0],
                ),
                'pagination'=>false,
            ]);
        }
        return [];
    }
    
    
    public function getDatos($maquina,$ini,$fin){
        
        if($ini == 0){
            $where  = "";
        }else{
            $where = "WHERE Inicio > "."'$ini' AND Fin <= "."'$fin' AND pr.IdMaquina = $maquina ";
        }
        
      
        $command = \Yii::$app->db;
        $result =$command->createCommand("SELECT  pd.IdProduccionDetalle, pd.Inicio, pd.Fin, pd.Hechas, pd.Rechazadas, 
                                                  p.Identificacion, p.MoldesHora, pr.IdMaquina 
                                          FROM ProduccionesDetalle AS pd
                                          LEFT JOIN Productos AS p ON pd.IdProductos = p.IdProducto
                                          LEFT JOIN Producciones AS pr ON pd.IdProduccion = pr.IdProduccion
                                          $where ")->queryAll();
        
        foreach ($result as &$key) {
            $TM=0;
            $tmuerto = TiemposMuerto::find()->where("Inicio > '".date('Y-m-d H:i',strtotime($key['Inicio'])).
                                                    "' AND Fin < '".date('Y-m-d H:i',strtotime($key['Fin']))."'"
                                            )->with("idCausa")->asArray()->all(); 
             
            //echo  date('Y-m-d H:i',strtotime($key['Inicio'])). '<br>'.date('Y-m-d H:i',strtotime($key['Fin'])).'<br>' ;  
            //var_dump($tmuerto);
            foreach ($tmuerto as $datostm) {
                          
                $Ti = date('H:i',strtotime($datostm['Inicio']));
                $Tf = date('H:i',strtotime($datostm['Fin']));
                                            
                $Ti = ( (date('H:i',strtotime($datostm['Inicio'])) * 60 ) + date('i',strtotime($datostm['Inicio'])) );
                $Tf = ( (date('H:i',strtotime($datostm['Fin'])) * 60 ) + date('i',strtotime($datostm['Fin'])) ) ;

                $TM = $TM + $Tf-$Ti;      
                
               $key['Causa'.$datostm['idCausa']['IdCausaTipo']] = $Tf-$Ti;
               
            }
            $key['TiempoMuerto'] =  $TM;
        }
       
        return $result;
        
    }
    
}
