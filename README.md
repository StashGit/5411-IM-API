# API Control de Stock
A continuación de describe como instalar y cuales son las operaciones que 
expone la API para el control de stock.

### Instalación
Los componentes de base que necesitamos para instalar la API, son:
* Ruby
* Rails
* Postgres

Si bien la mayoría de los sistemas cuentan con alguna version de Ruby, 
suele ser la version incorrecta. Por lo tanto, el primer paso es instalar
Ruby.

En OSX, la forma mas sencilla de hacerlo es utilizando **rbenv**.
Esta herramienta se puede instalar via **homebrew** siguiendo las instrucciones 
detalladas en su pagina de github: https://github.com/rbenv/rbenv#homebrew-on-macos

Luego de instalar y configurar **rbenv**, tenemos que ejecutar:

```
$ rbenv install 2.6.3
$ cd <path_repo>
$ rbenv local 2.6.3
$ ruby --version
```

Si la salida del ultimo comando es `2.6.3[algo...]` podemos continuar.

Antes de pasar a la instalacion de Rails, vamos a instalar y configurar **postgres**.
El mecanismo mas rápido para instalar y configurar esta base de datos, es 
utilizando **homebrew**.

```
$ brew install postgresql
$ brew services start postgresql
```

Una vez que contamos con la base de datos, pasamos a instalar Rails y 
todas las librerias que utiliza la API.

```
$ gem install bundler
$ bundle install
```

En este punto contamos con Ruby, Rails y todas las gems requeridas por la API.

El ultimo paso de la instalacion, es crear la base de datos y correr las 
migraciones. Para completar este paso, vamos a utilzar **rake**.

```
$ rake db:create
$ rake db:migrate
$ rake db:seed
```

Si todos los comandos finalizaron correctamente, podemos iniciar el servicio
ejecutando:

```
$ rails s
```

_(\*) Por default la API  corre en http://localhost:3000_


## Sobre los metodos que expone la API
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

Si la operacion finaliza correctamente, la respuesta de la llamada contiene 
un "token de impresion." 

Utilizando ese token, podemos invocar el metodo **stock/print\_labels** e 
imprimir todas las etiquetas con los codigos QR para el lote que acabamos de 
importar. 

```
{ "ok": true, "errors": [], "token": "8a5ca2e830f7b381ede318b871a4253e" }
```

### Cómo se consulta el stock de un producto
El stock de un producto se calcula en base a la diferencia entre las 
transacciones de entrada y salida para la combinación **marca-sku** 
especificada.

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
* reason

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" , \"units\":"10", \"comments\":\"This is a comment.\", "reason" : \"4\" }" \
     localhost:3000/stock/adjust
```

Las razones posibles para realizar ajustes de stock, son:

``` ruby
module Reason
  BUY        = 1
  SALE       = 2
  ADJUSTMENT = 3
  IN         = 4
  OUT        = 5
  RETURN     = 6
  OTHER      = 7
end
```

### Cómo se registran las compras
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

### Cómo se registran las ventas
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
Las marcas se pueden registrar utilziando el metodo **brands/create**.

**Parametros**
* name

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{ \"name\": \"Nike\" }" \
     localhost:3000/brands/create
```


### Cómo se modifica una marca
Las marcas se pueden modificar utilziando el metodo **brands/update**.

**Parametros**
* id
* name

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{ \"id\": \"1\", \"name\": \"Nuevo Nombre\" }" \
     localhost:3000/brands/update
```

### Cómo se elimina una marca
Las marcas se pueden eliminar utilziando el metodo **brands/delete**.
Tener en cuenta que no es un delete efectivo. Lo unico que hace este 
metodo es marcar la marca como borrada.

**Parametros**
* id

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{ \"id\": \"1\" }" \
     localhost:3000/brands/delete
```

### Cómo visualizar los datos de una marca
Las marcas se pueden visualizar utilziando el metodo **brands/show**.

```
    curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X GET \
         localhost:3000/brands/show/1
```

### Cómo se generan los códigos QR - OBSOLETO!
_**Si bien este metodo sigue funcionando se recomienda utilizar QRs basados en
  IDs.**_

Para generar el código QR de un producto tenemos que ejecutar el método **qr/create**.

Al decodificar este código, se obtiene un string que contiene 
los campos **brand_id**, **style**, **color**, y **size** separados
por un tilde (**~**).

**Parámetros**
* brand_id
* style
* color
* size

```
    curl -H "Content-Type: text/html" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
         localhost:3000/qr/create
```

### Cómo se generan los códigos QR basados en IDs
Para generar el código QR de un producto tenemos que ejecutar el método **qr/encode**.

Este metodo genera un registro con los datos del producto, le asigna un ID, y
produce un codigo QR en base a ese ID.

Es importante tener en cuenta que la unica informacion que contiene el QR es el
ID del registro generado. Si queremos recuperar los datos del producto, tenemos
que hacer un request adicional al metodo **qr/decode** utilizando ese ID.

**Parámetros**
* brand_id
* style
* color
* size

```
    curl -H "Content-Type: text/html" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
         localhost:3000/qr/encode
```

Respuesta:

```
{"id":2,"path":"http://localhost:3000/qr/0000000002.png","base_64":"..."}

```

### Cómo se recuperan los datos de productos cuando utilizamos QRs basados en IDs
Para obtener la informacion de un producto partiendo de un QR basado en ID
tenemos que hacer un request al metodo **qr/decode** utilizando el ID del QR.

**Parámetros**
* id

```
curl -H "Content-Type: application/json"   \
     -H "Access-Token: $TOKEN" \
     -H "Accepts: application/json" -X POST \
     -d "{ \"id\":\"2\" }" \
        localhost:3000/qr/decode
```

Respuesta:

```
{"id":2,"brand_id":2,"style":"GRACE STYLE","color":"RED","size":"S"}
```


### Cómo crear una etiqueta
Para crear una etiqueta tenemos que especificar los mismos parametros que
utilizamos para generar un codigo QR.

_Nota: Este metodo **solo genera la etiqueta**. No inicia el proceso de impresion
ni nada por el estilo._

**Parámetros**
* brand_id
* style
* color
* size

```
    curl -H "Content-Type: text/html" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"1\", \"style\": \"SS200105S\", \"color\": \"MIDNIGHT\", \"size\": \"AU6 US2\" }" \
         localhost:3000/stock/create_label
```

Tener en cuenta que la creacion de etiquetas corre en un background job. Esto
quiere decir que el request retorna de forma instantanea mientras que la
impresion puede demorar. (Este tipo de request no son bloqueantes.)

### Cómo imprimir etiquetas
El nuevo mecanimos de impresion divide el proceso en dos etapas. Por un lado
tenemos el metodo **print/enqueue** que tienen que utilizar los clientes de la
API para encolar trabajos de impresion. Y por el otro, el metodo
**print/pending** que utiliza el servicio de impresion para recuperar los
trabajos encolados y mandarlos a imprimir desde una maquina contectada a una
impresora.

**Parámetros obligatorios**
* jobs

Jobs es una coleccion de items donde cada elemento tiene el id del codigo QR
que queremos imprimir y la cantidad de copias que queremos para ese elemento.

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{\"jobs\": [{ 
         \"qr_id\": \"$QR_ID\", 
         \"copies\": \"$COPIES\" }]}" \
     "localhost:3000/print/enqueue"
```

Resultado:

```
{"message":"Success!"}
```

### Cómo obtener items de la cola de impresion
Para obtener la lista de las etiquetas que tenemos que imprimir tenemos que 
utilizar el metodo **print/pending**.

El resultado de este metodo nos permite generar e imprimir las etiquetas en la
maquina que se encuentra conectada a la impresora.

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X GET \
     "localhost:3000/print/pending"
```

Resultado:
```
{
  jobs:[
    { 
      qr:{id:305,brand_id:1,style:"GRACE",color:"RED",size:"M",path":null}, 
      copies:2,
      job_id:53
    }
  ]
}
```

### Cómo quitar items de la cola de impresion
Si la impresion finaliza correctamente tenemos que eilimnar los items de la
cola de impresion utilizando el metodo **print/dequeue** especificando la lista
de trabajos de impresion que queremos remover.

**Parámetros obligatorios**
* jobs_ids

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{\"jobs_ids\": [ \"$JOB_ID\" ]}" \
     "localhost:3000/print/dequeue"
```

_Los jobs_ids los obtenemos cuando ejecutamos el metodo **print/pending**._

### Cómo quitar todos los items de la cola de impresion
Si por algun motivo tenemos que eliminar todos los items de la cola de
impresion, podemos hacerlo utilizando el metodo **print/dequeue_all**

En este caso, no es necesario especificar ningun argumento.

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     "localhost:3000/print/dequeue_all"
```

### Cómo obtener todas las marcas
El método **brands/all** permite recuperar información de todas las marcas 
que maneja el sistema.

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X GET \
     stock-api-5411.herokuapp.com/brands/all
```


### Como se configura el servicio de impresion
Para configurar el daemon que utilizamos para imprimir las etiquetas tenemos
que configurar las variables de entorno:

```
* PRINT_ROOT (directorio donde se encuentra el servicio.)
* HOST       (URL raiz de la API.)
* TOKEN      (Token de autenticacion.)
```

De forma opcional podemos especificar el nombre de la impresora por medio de la
variable "LBL_PRINTER".

El servicio de impresion esta dividido en dos archivos. Uno contiene el codigo
propio del servicio y otro que se utiliza para iniciar el servicio, detenerlo,
consultar el estado, y demas.

```
$ 5411-IM-API/services/label_printer.rb
$ 5411-IM-API/services/printer_control.rb
```

Tener en cuenta que antes de iniciar el servicio es necesario instalar todas
las depenencias utilizando el comando `gem install`:

* 'httparty'
* 'json'
* 'rqrcode'
* 'prawn'
* 'fileutils'

Una vez que instalamos todas las dependencias en nuestro sistema, podemos
probar el servicio ejecutando:

```
$ ruby printer_control.rb run
```

Una vez que verificamos que el servicio funciona correctamente, podemos
ejecutarlo como un proceso daemon utlizando el comando:

```
$ ruby printer_control.rb start
```

Para detener el servicio:
```
$ ruby printer_control.rb stop
```

Y para consultar el estado del servicio:
```
$ ruby printer_control.rb stat
```


