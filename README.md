# API Control de Stock
A continuación de describen todas las operaciones que expone la API de control
de stock y la lista de argumentos que espera cada una de ellas.

A excepción del método de inicio de sesión, siempre es necesario
agregar un header especificando el **access-token del usuario actual**.

### Cómo se obtiene un access-token
Para obtener un access-token, es necesario iniciar sesión utilizando el método **session/new**.

**Párametros**
* email
* password

```
curl -H "Content-Type: application/json"   \
     -H "Accepts: application/json" -X POST \
     -d "{ \"email\":\"john@example.com\", \"password\":\"123\"}" \
     localhost:3000/session/new
```

### Cómo se importa una Packing List
Para importar una packing list y generar todas las transacciones de stock de forma automatica es necesario ejecutar el metodo **stock/import**.

**Párametros**
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

### Cómo se consulta el stock de un producto
El stock de un producto se calcula en base a la diferencia entre las transacciones de entrada y salida para la combinación **marca-sku** especificada.

**Párametros**
* brand_id
* style
* color
* size

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
    localhost:3000/stock/units
```

### Cómo se consultan los movimientos de stock por marca
El método **stock/by_brand** permite recuperar todos los movimientos de stock para
una marca determinada.

**Párametros**
* brand_id

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{ \"brand_id\": \"1\" }" \
     localhost:3000/stock/by_brand
```

### Cómo se realizan los ajustes de stock
Para genera una transacción de ajuste de stock es necesario invocar el método **stock/adjust**.
La *dirección* del movimiento (entrada/salida) se infiere en base a la 
cantidad de unidades especificadas en el movimiento. Si la cantidad es
negativa, se asume egreso de mercadería; si es positiva, se registra un ingreso.

**Párametros**
* brand_id
* style
* color
* size
* units
* comments

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"units\":"10", \"comments\":\"This is a comment.\" }" \
     localhost:3000/stock/adjust
```

### Cómo se registran las compra
Las tranascciones de compras se generan utilizando el método **stock/buy**.

**Parámetros**
* brand_id
* style
* color
* size
* units

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"units\":"10" }" \
     localhost:3000/stock/buy
```

### Cómo se registran las venta
Las tranascciones de ventas se generan utilizando el método **stock/sale**.

**Parámetros**
* brand_id
* style
* color
* size
* units

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"units\":"123" }" \
     localhost:3000/stock/sale
```

### Cómo se consulta el log de transacciones
Para obtener un listado con todas las transacciones de stock tenemos que utilizar el método **stock/log**.
(Tener en cuenta que este metodo retorna **todas** las transacciones, no filtra por fecha, ni marca, ni usuario,
ni nada por el estilo.

```
curl -H "Content-Type: multipart/mixed"   \
     -H "Accepts: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X GET \
     localhost:3000/stock/log
```

### Cómo se agrega una marca
Las marcas se puede registrar utilziando el metodo **brands/create**.

**Parametros**
* name

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"name\": \"Nike\" }" \
     localhost:3000/brands/create
```

### Cómo se generan los códigos QR
Para generar el código QR de un producto tenemos que ejecutar el método **qr/create**.

Al decodificar este código, se obtiene un string que contiene 
los campos **brand_id**, **style**, **color**, y **size** separados
por un tilde (**~**).

**Parámetros**
* brand_id
* style
* color
* size

_**Nota:** Tener en cuenta que a diferencia del resto de las operaciones de
esta API, el resultado de esta llamada es un fragmento de código HTML._

```
    curl -H "Content-Type: text/html" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
         localhost:3000/qr/create
```

### Cómo obtener todas las marcas
El método **brands/all** permite recuperar información de todas las marcas 
que maneja el sistema.

```
# GET
curl localhost:3000/brands/all
```








