# API Control de Stock
A continuacion de describen todas las operaciones que expone la API de control
de stock y la lista de argumentos que espera cada una de estas operacion.

A excepcion del metodo de inicio de sesion, en todos los casos es necesario
agregar un header especificando el access-token del usuario actual.

### Como obtener un access-token
Retorna el access token necesario para consultar cualquiera de los metodos que
expone la API.

**Parametros**
* email
* password

```
curl -H "Content-Type: application/json"   \
     -H "Accepts: application/json" -X POST \
     -d "{ \"email\":\"user@example.com\", \"password\":\"123\"}" \
     localhost:3000/session/new
```

### Importar Packing List
Genera todas las transacciones de stock necesarias para ingresar los productos
especificados en la packing list (Archivo Excel.)

**Parametros**
* file (Archivo Excel que contiene el detalle de la packing list.)
* brand_id

```
curl -H "Content-Type: multipart/mixed"   \
     -H "Accepts: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -F "file=@../../data/pl1.xlsx" \
     -F "brand_id=1" \
     localhost:3000/stock/import
```

### Consultar stock
Retorna la cantidad de unidades en stock para la combinacion **marca-sku**
especificada.

**Parametros**
* brand_id
* style
* color
* size

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X GET \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
    localhost:3000/stock/units
```

### Ajustes de stock
Genera una transaccion de ajuste de stock.
La *direccion* del movimiento (entrada/salida) se infiere en base a la 
cantidad de unidades especificadas en el movimiento. Si la cantidad es
negativa, se asume egreso de mercaderia; si es positiva, ingreso.

**Parametros**
* brand_id
* style
* color
* size
* user_id
* units
* comments

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"user_id\": \"1\", \"units\":"10", \"comments\":\"This is a comment.\" }" \
     localhost:3000/stock/adjust
    ```

### Compras
Genera una transaccion de stock para registrar una compra de mercaderia.

**Parametros**
* brand_id
* style
* color
* size
* user_id
* units

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"user_id\": \"1\", \"units\":"10" }" \
     localhost:3000/stock/buy
```

### Ventas
Genera una transaccion de stock para registrar una venta de mercaderia.

**Parametros**
* brand_id
* style
* color
* size
* user_id
* units

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"user_id\": \"1\", \"units\":"123" }" \
     localhost:3000/stock/sale
```

### Log de transacciones
Esta operacion permite visualizar todas las transacciones de stock.

```
curl -H "Content-Type: multipart/mixed"   \
     -H "Accepts: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X GET \
     localhost:3000/stock/log
```

### Crear una marca
Registra una nueva marca.

**Parametros**
* name

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"name\": \"Nike\" }" \
     localhost:3000/brands/create
```



