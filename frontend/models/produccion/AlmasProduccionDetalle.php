<?php

namespace frontend\models\produccion;

use Yii;
use common\models\catalogos\AlmasTipo;
use common\models\dux\Productos;

/**
 * This is the model class for table "AlmasProduccionDetalle".
 *
 * @property integer $IdAlmaProduccion
 * @property integer $IdProduccion
 * @property integer $IdProgramacionAlma
 * @property integer $AlmasTipo
 * @property string $Inicio
 * @property string $Fin
 * @property integer $Programadas
 * @property integer $Hechas
 * @property integer $Rechazadas
 * @property integer $PiezasCaja
 * @property integer $PiezasMolde
 *
 * @property AlmasProduccionDefecto[] $almasProduccionDefectos
 * @property AlmasTipo $almasTipo
 * @property Producciones $idProduccion
 * @property ProgramacionesAlma $idProgramacionAlma
 */
class AlmasProduccionDetalle extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'AlmasProduccionDetalle';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['IdProduccion', 'IdProgramacionAlma', 'AlmasTipo', 'Inicio', 'Fin', 'Programadas', 'Hechas', 'Rechazadas', 'PiezasCaja', 'PiezasMolde'], 'required'],
            [['IdProduccion', 'IdProgramacionAlma', 'AlmasTipo', 'Programadas', 'Hechas', 'Rechazadas', 'PiezasCaja', 'PiezasMolde'], 'integer'],
            [['Inicio', 'Fin'], 'safe']
        ];
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'IdAlmaProduccion' => 'Id Alma Produccion',
            'IdProduccion' => 'Id Produccion',
            'IdProgramacionAlma' => 'Id Programacion Alma',
            'AlmasTipo' => 'Almas Tipo',
            'Inicio' => 'Inicio',
            'Fin' => 'Fin',
            'Programadas' => 'Programadas',
            'Hechas' => 'Hechas',
            'Rechazadas' => 'Rechazadas',
            'PiezasCaja' => 'Piezas Caja',
            'PiezasMolde' => 'Piezas Molde',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getAlmasProduccionDefectos()
    {
        return $this->hasMany(AlmasProduccionDefecto::className(), ['IdAlmaProduccionDetalle' => 'IdAlmaProduccion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getAlmasTipo()
    {
        return $this->hasOne(AlmasTipo::className(), ['IdAlmaTipo' => 'AlmasTipo']);
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
    public function getIdProgramacionAlma()
    {
        return $this->hasOne(ProgramacionesAlma::className(), ['IdProgramacionAlma' => 'IdProgramacionAlma']);
    }
}
