<?php

namespace common\models\dux;

use Yii;

/**
 * This is the model class for table "Productos".
 *
 * @property integer $IdProducto
 * @property integer $IdMarca
 * @property integer $IdPresentacion
 * @property integer $IdAleacion
 * @property integer $IdProductoCasting
 * @property string $Identificacion
 * @property string $Descripcion
 * @property integer $PiezasMolde
 * @property integer $CiclosMolde
 * @property string $PesoCasting
 * @property string $PesoArania
 *
 * @property AlmacenesProducto[] $almacenesProductos
 * @property Programaciones[] $programaciones
 * @property ProduccionesDetalle[] $produccionesDetalles
 * @property Pedidos[] $pedidos
 * @property Almas[] $almas
 * @property Filtros[] $filtros
 * @property Camisas[] $camisas
 * @property Aleaciones $idAleacion
 * @property Marcas $idMarca
 * @property Presentaciones $idPresentacion
 * @property Productos $idProductoCasting
 * @property Productos[] $productos
 */
class Productos extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'Productos';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['IdMarca', 'IdPresentacion', 'IdAleacion', 'PiezasMolde', 'CiclosMolde', 'PesoCasting', 'PesoArania'], 'required'],
            [['IdMarca', 'IdPresentacion', 'IdAleacion', 'IdProductoCasting', 'PiezasMolde', 'CiclosMolde'], 'integer'],
            [['Identificacion', 'Descripcion'], 'string'],
            [['PesoCasting', 'PesoArania'], 'number']
        ];
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'IdProducto' => 'Id Producto',
            'IdMarca' => 'Id Marca',
            'IdPresentacion' => 'Id Presentacion',
            'IdAleacion' => 'Id Aleacion',
            'IdProductoCasting' => 'Id Producto Casting',
            'Identificacion' => 'Identificacion',
            'Descripcion' => 'Descripcion',
            'PiezasMolde' => 'Piezas Molde',
            'CiclosMolde' => 'Ciclos Molde',
            'PesoCasting' => 'Peso Casting',
            'PesoArania' => 'Peso Araña',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getAlmacenesProductos()
    {
        return $this->hasMany(AlmacenesProducto::className(), ['IdProducto' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getProgramaciones()
    {
        return $this->hasMany(Programaciones::className(), ['IdProducto' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getProduccionesDetalles()
    {
        return $this->hasMany(ProduccionesDetalle::className(), ['IdProductos' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getPedidos()
    {
        return $this->hasMany(Pedidos::className(), ['IdProducto' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getAlmas()
    {
        return $this->hasMany(Almas::className(), ['IdProducto' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getFiltros()
    {
        return $this->hasMany(Filtros::className(), ['IdProducto' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getCamisas()
    {
        return $this->hasMany(Camisas::className(), ['IdProducto' => 'IdProducto']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdAleacion()
    {
        return $this->hasOne(Aleaciones::className(), ['IdAleacion' => 'IdAleacion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdMarca()
    {
        return $this->hasOne(Marcas::className(), ['IdMarca' => 'IdMarca']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdPresentacion()
    {
        return $this->hasOne(Presentaciones::className(), ['IDPresentacion' => 'IdPresentacion']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getIdProductoCasting()
    {
        return $this->hasOne(Productos::className(), ['IdProducto' => 'IdProductoCasting']);
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getProductos()
    {
        return $this->hasMany(Productos::className(), ['IdProductoCasting' => 'IdProducto']);
    }
}
