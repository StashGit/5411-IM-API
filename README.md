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

### Cómo se eliminan todas las transacciones generadas por una Packing List
Si luego de importar una lista el usuario quiere eliminar todas las transacciones
que acaba de generar, podemos ofrecerles esa posibilidad utilizando el metodo
**stock/delete_packing_list** especificando el **id** de la lista que
queremos eliminar.
(El id de la lista se puede recuperar utilizando el metodo **stock/packing_lists**.)

**Párametros**
* packing_list_id

```
curl -H "Content-Type: multipart/mixed"   \
     -H "Accepts: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -F "packing_list_id=$PLID" \
     $HOST/stock/delete_packing_list
```

**Resultado**

```
{ "message": "OK" }
```

### Cómo recuperar todas las packing lists
El metodo **stock/packing_lists** permite recuperar todas las packing lists
"activas" que tenemos en el sistema.
Este metodo puede ser util en los casos donde queremos mostrar el nomrbe de la
lista y utilizar su ID para realizar alguna operacion con la API.

**Párametros**
* brand_id

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X GET \
     $HOST/stock/packing_lists?brand_id=$BRAND_ID
```

**Resultado**
```
[
  { id: 1, brand: { id: 1, name: "Nike" }, path: "pl1.xlsx },
  { id: 2, brand: { id: 1, name: "Nike" }, path: "pl2.xlsx },
  { id: 3, brand: { id: 1, name: "Nike" }, path: "pl3.xlsx }
]
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

Resultado:

```
[{
  style: "LYNETTE DRESS",
  code: 1201,
  color: "245",
  status: null,
  kind: 1,
  sizes: [{
    size: "L",
    size_order: 5,
    total_units: 12,
    boxes: [{
        box_id: "BOX 1",
        units: 2
      },{
        box_id: "BOX 4",
        units: 10
      }
    ]
    }, {
      size: "M",
      size_order: 4,
      total_units: 8,
      boxes: [...]
   }]
},
{ ... }]
```
### Cómo se realizan los movimientos de stock
El método **stock/move** permite mover mercaderia de un box a otro.

Tener en cuenta que este metodo **no** valida la cantidad de unidades en stock.
Desde el punto de vista de la API es posible mover 200 unidades de un SKU incluso
en los casos donde no tenemos ninguna en stock.

**Párametros**
* brand_id
* sku_from
* sku_to
* units
* user
* commenmts

```
curl -H "Content-Type: application/json" \
         -H "Access-Token: $TOKEN" \
         -X POST \
         -d "{ \"brand_id\": \"$BRAND_ID\",
                \"sku_from\": {
                    \"style\": \"SS200105S\",
                    \"color\": \"MIDNIGHT\",
                    \"size\": \"AU6 US2\",
                    \"code\":\"test-code\",
                    \"reference_id\":\"ref-1\",
                    \"box_id\":\"box-1\"
                },
                \"sku_to\": {
                    \"style\": \"SS200105S\",
                    \"color\": \"MIDNIGHT\",
                    \"size\": \"AU6 US2\",
                    \"code\":\"test-code\",
                    \"reference_id\":\"ref-2\",
                    \"box_id\":\"box-2\"
                },
                \"units\":"$UNITS",
                \"comments\":\"This is a comment.\" }" \
                localhost:3000/stock/move

```


### Cómo consultar el stock de productos dañados
El método **stock/damaged_by_brand** retorna únicamente los productos que fueron
descontados del stock por medio de una ajuste por mercaderia dañada.

**Párametros**
* brand_id

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{ \"brand_id\": \"$BRAND_ID\" }" \
     localhost:3000/stock/damaged_by_brand
```

Resultado:

```
[{
  style: "TROUSERS",
  code: 1012,
  color: 250,
  sizes: [{
    size: "XS",
    size_order: 2,
    total_units: 2,
    boxes: [{
      reference_id: "PO123",
      box_id: "BOX 4",
      units: 2
    }]
  }]
},
...
]
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
* code
* box_id
* reference_id
* units
* comments
* reason

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{
        \"brand_id\":     \"$BRAND_ID\",
        \"style\":        \"SS200105S\",
        \"color\":        \"MIDNIGHT\",
        \"size\":         \"AU6 US2\",
        \"code\":         \"test-code\",
        \"box_id\":       \"random_box_id\",
        \"reference_id\": \"random_reference_id\",
        \"units\":        "$UNITS",
        \"comments\":     \"This is a comment.\",
        \"reason\":       \"$REASON\"
     }" \
     $HOST/stock/adjust
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
  DAMAGED    = 8
end
```

### Cómo deshacer una transaccion de stock
Si contamos con el ID de una transaccion, podemos deshacer los cambios utilizando
el metodo **stock/undo_transaction**

**Parámetros**
id

```
{ "message": "Success" }
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

Parametros Opcionales:

* brand_id

```
curl -H "Content-Type: multipart/mixed"   \
     -H "Accepts: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X GET \
      $HOST/stock/log?brand_id=$BRAND_ID
```

### Cómo se ocualtan las transacciones de stock
Este metodo permite lograr el efecto de archivar packing lists marcando las transacciones como "ocultas."

Parametros requeridos:

* brand_id
* style (array)
* color (array)

```
curl -H "Content-Type: application/json" \
     -H "Accepts: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{
          \"brand_id\": \"$BRAND_ID\",
          \"style\":    [ \"$STYLE\" ],
          \"color\":    [ \"$COLOR\" ]
        }" \
     localhost:3000/stock/hide
```

Resultado

```
{ affected_transactions_count: 4 }
```

### Restaurar transacciones de Stock
Este metodo permite restaurar packing lists archivadas.

Parametros requeridos:

* brand_id
* style (array)
* color (array)

```
curl -H "Content-Type: application/json" \
     -H "Accepts: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{
          \"brand_id\": \"$BRAND_ID\",
          \"style\":    [ \"$STYLE\" ],
          \"color\":    [ \"$COLOR\" ]
        }" \
     localhost:3000/stock/restore
```

## Usuarios

### Como crear un usuario
La API permite crear usuario emitiendo comandos de tipo POST contra el endoint **users**.

**Parametros Requeridos**
* email
* password
* password_confirmation

**Parametros Opcionales**
* first_name
* last_name
* pic_url
* is_admin

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -d "{
        user: {
            email: $EMAIL,
            first_name: $FIRST,
            last_name: $LAST ,
            password: $PWD ,
            password_confirmation: $PWD_CONFIRM
        }
    }" \
     $HOST/users
```

### Como ver los detalles de un usuaio
El metodo **users/by_email** permite recuperar todos los datos de un usuario en
base al email especificado.

**Parametros Requeridos**
* email

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     $HOST/users/by_email?email=$EMAIL
```

Resultado:

```
{
    id:2
    email:"jane@example.com",
    first_name:"jane",
    last_name:"doe",
    pic_url:null,
    is_admin:null,
    created_at:"2020-10-25T23:27:06.762Z",
    updated_at:"2020-10-25T23:27:06.762Z",
    deleted:false
}
```

### Como Elminar un usuario
Es posible realizar bajas "logicas" emitiendo un comando de tipo **delete**
contra el endpoint **users** especificando el ID del usuario que queremos eliminar.

**Parametros Requeridos**
* email

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X DELETE \
     $HOST/users/$ID
```

Resultado:

```
{"message":"Success"}
```


### Como actualizar los datos de un usuario
A excepcion del **email**  todos los atributos de los usuarios puden ser modificando
emitiendo un commando **put** contra el endpoint **users**.

**Parametros Requeridos**
* id

**Parametros Opcionales**
* first_name
* last_name
* pic_url
* is_admin
* password
* password_confirmation

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: $TOKEN" \
     -X PUT \
     -d "{
        \"user\": {
            \"first_name\": \"$FIRST\",
            # etc ...
        }
    }" \
     $HOST/users/$ID
```

Resultado:

```
{
    "first_name":"jane",
    "id":1,
    "password_digest":"$2a$12$948mUOUMhfnL.DBYEi1tseox.55FktuezDqOQAmlMAEZPDRTkMBYS",
    "email":"john@example.com",
    "last_name":"Doe",
    "pic_url":null,
    "is_admin":null,
    "created_at":"2020-03-11T18:31:36.767Z",
    "updated_at":"2020-10-26T00:57:11.519Z",
    "deleted":false
}
```

### Cómo se agrega una marca
Las marcas se pueden registrar utilziando el metodo **brands/create**.

**Parametros**
* name

**Parametros Opcionales**
* logo_url

```
curl -H "Content-Type: application/json" \
     -H "Access-Token: e2aeb1977588a26b878a7b9d44b25caf" \
     -X POST \
     -d "{
        \"name\": \"Nike\",
        \"logo_url\": \"host/logo.png\"
    }" \
     localhost:3000/brands/create
```

### Cómo se modifica una marca
Las marcas se pueden modificar utilziando el metodo **brands/update**.

**Parametros**
* id
* name

**Parametros Opcionales**
* logo_url

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

### Como subir images
El metodo **utils/upload_image** permite subir imagenes al servidor. (Por ejemplo,
el logo de una marca.)

```
curl -H "Content-Type: multipart/mixed"   \
     -H "Accepts: application/json" \
     -H "Access-Token: $TOKEN" \
     -X POST \
     -F "image=@$FILE" \
     localhost:3000/utils/upload_image
```

Resultado:
```
{ img_id: 4, img: "http://localhost:3000/logo.png" }
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


