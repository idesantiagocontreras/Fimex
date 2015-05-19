<?php

namespace frontend\models\produccion;

use Yii;
use common\models\catalogos\Lances;
/**
 * This is the model class for table "Producciones".
 *
 * @property integer $IdProduccion
 * @property integer $IdCentroTrabajo
 * @property integer $IdMaquina
 * @property integer $IdEmpleado
 * @property integer $IdProduccionEstatus
 * @property string $Fecha
 * @property integer $IdSubProceso
 * @property integer $IdArea
 *
 * @property AlmasProduccionDetalle[] $almasProduccionDetalles
 * @property Areas $idArea
 * @property CentrosTrabajo $idCentroTrabajo
 * @property Empleados $idEmpleado
 * @property Maquinas $idMaquina
 * @property ProduccionesEstatus $idProduccionEstatus
 * @property SubProcesos $idSubProceso
 * @property ProduccionesDetalle[] $produccionesDetalles
 * @property Lances[] $lances
 * @property MaterialesVaciado[] $materialesVaciados
 * @property Temperaturas[] $temperaturas
 */
class Producciones extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'Producciones';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['IdCentroTrabajo', 'IdMaquina', 'IdEmpleado', 'IdProduccionEstatus', 'IdSubProceso', 'IdArea'], 'required'],
            [['IdCentroTrabajo', 'IdMaquina', 'IdEmpleado', 'IdProduccionEstatus', 'IdSubProceso', 'IdArea'], 'integer'],
            [['Fecha'], 'safe']
        ];
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'IdProduccion' => 'Id Produccion',
            'IdCentroTrabajo' => 'Id Centro Trabajo',
            'IdMaquina' => 'Id Maquina',
            'IdEmpleado' => 'Id Empleado',
            'IdProduccionEstatus' => 'Id Produccion Estatus',
            'Fecha' => 'Fecha',
            'IdSubProceso' => 'Id Sub Proceso',
            'IdArea' => 'Id Area',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getAlmasProduccionDetalles()
    {
        return $this->hasMany(AlmasProduccionDetalle::className(), ['IdProduccion' => 'IdProduccion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdArea()
    {
        return $this->hasOne(Areas::className(), ['IdArea' => 'IdArea']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdCentroTrabajo()
    {
        return $this->hasOne(CentrosTrabajo::className(), ['IdCentroTrabajo' => 'IdCentroTrabajo']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdEmpleado()
    {
        return $this->hasOne(Empleados::className(), ['IdEmpleado' => 'IdEmpleado']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdMaquina()
    {
        return $this->hasOne(Maquinas::className(), ['IdMaquina' => 'IdMaquina']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdProduccionEstatus()
    {
        return $this->hasOne(ProduccionesEstatus::className(), ['IdProduccionEstatus' => 'IdProduccionEstatus']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdSubProceso()
    {
        return $this->hasOne(SubProcesos::className(), ['IdSubProceso' => 'IdSubProceso']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getProduccionesDetalles()
    {
        return $this->hasMany(ProduccionesDetalle::className(), ['IdProduccion' => 'IdProduccion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getLances()
    {
        return $this->hasOne(Lances::className(), ['IdProduccion' => 'IdProduccion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getMaterialesVaciados()
    {
        return $this->hasMany(MaterialesVaciado::className(), ['IdProduccion' => 'IdProduccion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getTemperaturas()
    {
        return $this->hasMany(Temperaturas::className(), ['IdProduccion' => 'IdProduccion']);
    }
    
    public function actualizaProduccion($data)
    {
        $command = \Yii::$app->db;
        $result =$command->createCommand("EXECUTE p_ActualizaTotalesSemana ".$data['IdProgramacionSemana'])->execute();
        $result =$command->createCommand("EXECUTE p_ActualizaTotalesPedido ".$data['IdProgramacion'])->execute();
    }
}
